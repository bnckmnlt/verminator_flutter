import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_schedule/app_schedule_cubit.dart';
import 'package:flutter_vermicomposting/core/common/widgets/app_background.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/models/food_waste_model.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_failed_screen.dart';
import 'package:flutter_vermicomposting/main.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'initialization_success_screen.dart';

// TODO: [✅] DONEEEEEE

enum TtsState { playing, stopped, paused, continued }

class InitializationWaitingScreen extends StatefulWidget {
  final int scheduleId;

  const InitializationWaitingScreen({
    super.key,
    required this.scheduleId,
  });

  static MaterialPageRoute route(int scheduleId) => MaterialPageRoute(
        builder: (_) => InitializationWaitingScreen(
          scheduleId: scheduleId,
        ),
      );

  @override
  State<InitializationWaitingScreen> createState() =>
      _InitializationWaitingScreenState();
}

class _InitializationWaitingScreenState
    extends State<InitializationWaitingScreen> {
  late final FlutterTts flutterTts;

  DateTime? _latestTimestamp;

  late MqttService _mqttService;
  late SupabaseClient _supabaseClient;

  late final StreamSubscription<List<Map<String, dynamic>>>
      _foodWasteSubscription;

  late CompostSchedule currentSchedule;

  bool isProcessing = false;
  int _currentTipIndex = 0;

  late Timer _timer;
  int _start = 120;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();

    flutterTts = FlutterTts();
    _initializeFlutterTTS();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    _mqttService = GetIt.I<MqttService>();
    _supabaseClient = GetIt.I<SupabaseClient>();

    final appState = context.read<AppScheduleCubit>().state;

    if (appState case AppScheduleActive(:final compostSchedule)) {
      currentSchedule = compostSchedule;

      final nowIso = DateTime.now().toUtc().toIso8601String();

      _foodWasteSubscription = _supabaseClient
          .from('food_waste')
          .stream(primaryKey: ['id'])
          .gte('created_at', nowIso)
          .order('created_at')
          .listen((rawData) {
            final newEntries =
                rawData.map(FoodWasteModel.fromJsonRealtime).where((item) {
              final created = DateTime.tryParse(item.createdAt);
              return item.foodWasteScheduleId == widget.scheduleId &&
                  created != null &&
                  (_latestTimestamp == null ||
                      created.isAfter(_latestTimestamp!));
            }).toList();

            if (newEntries.isEmpty) return;

            for (final item in newEntries) {
              if (item.materialStatus.name == 'valid') {
                speak(
                    "Valid material detected. Proceeding to the bedding layer.");
              } else if (item.materialStatus.name == 'invalid') {
                speak("Invalid material identified. Redirecting for disposal.");
              }
            }

            _latestTimestamp = newEntries
                .map((e) => DateTime.parse(e.createdAt))
                .reduce((a, b) => a.isAfter(b) ? a : b);
          });
    }

    if (MqttConnectionState == MqttConnectionState.connected) {
      _mqttService.publish("system/status", "feeding",
          qos: MqttQos.atLeastOnce, retain: true);
      _mqttService.publish("system/feeding/id", "1",
          qos: MqttQos.atLeastOnce, retain: true);
      _mqttService.publish("control/monitoring/camera", "active",
          qos: MqttQos.atLeastOnce, retain: true);
    }

    _tipTimer = Timer.periodic(
      const Duration(seconds: 6),
      (_) {
        setState(() {
          _currentTipIndex =
              (_currentTipIndex + 1) % Constants.loadingTips.length;
        });
      },
    );

    startTimer();
  }

  @override
  void dispose() {
    _foodWasteSubscription.cancel();
    _tipTimer?.cancel();
    _timer.cancel();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final deviceHeight = MediaQuery.of(context).size.height;
      final deviceWidth = MediaQuery.of(context).size.width;
      final isDarkMode =
          MediaQuery.of(context).platformBrightness == Brightness.dark;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }

          showDialog(
              context: context,
              builder: (context) {
                return GeneralDialog(
                  title: "Cancel Feeding",
                  description: "Do you want to cancel this process?",
                  confirmButtonLabel: "Cancel Process",
                  approvedFunction: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                );
              });
        },
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Glassmorphism(
            blur: 64,
            opacity: 0.3,
            child: AppBackground(
              child: Padding(
                padding: EdgeInsets.all(deviceHeight * 0.10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _scheduleDetailsSection(
                      deviceWidth: deviceWidth,
                      scheduleIdentifier: currentSchedule.scheduleName,
                      response: "Awaiting food waste to be loaded...",
                    ),
                    !isProcessing
                        ? Text(
                            '${(_start ~/ 60).toString().padLeft(1, '0')}:${(_start % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 164,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Column(
                            spacing: 24,
                            children: [
                              SizedBox(
                                  height: 248,
                                  width: 248,
                                  child: Lottie.asset(
                                      "assets/animations/processing.json")),
                              Text(
                                "PROCESSING RECORDS...",
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.025,
                                ),
                              )
                            ],
                          ),
                    !isProcessing
                        ? _bottomInformationSection()
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void startTimer() {
    final toastHelper = ToastHelper(context);

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (_start == 0) {
          setState(() {
            isProcessing = true;
          });

          final foodWasteBloc = context.read<FoodWasteBloc>();
          foodWasteBloc.add(FoodWasteList());

          final state = await foodWasteBloc.stream.firstWhere(
            (state) =>
                state is FoodWasteListSuccess || state is FoodWasteFailure,
          );

          List<bool> errorList = [false, false, false];
          bool isError = false;

          if (state is FoodWasteFailure) {
            errorList[2] = true;
            isError = true;
          } else if (state is FoodWasteListSuccess) {
            final wasteList = state.foodWaste
                .where(
                    (waste) => waste.foodWasteScheduleId == widget.scheduleId)
                .toList();

            if (wasteList.isEmpty) {
              errorList[1] = true;
              isError = true;
            } else {
              const validClassNames = ['fruit', 'vegetable', 'grains'];
              final hasValid = wasteList.any((waste) {
                return validClassNames
                    .contains(waste.classname.name.toLowerCase());
              });

              if (!hasValid) {
                errorList[0] = true;
                isError = true;
              }
            }
          }

          timer.cancel();
          _tipTimer?.cancel();

          Future.delayed(const Duration(milliseconds: 500), () async {
            if (!mounted) return;

            if (isError) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InitializationFailedScreen(
                    errorStatusList: errorList,
                    scheduleId: widget.scheduleId,
                  ),
                ),
              );
            } else {
              _mqttService.publish("system/status", "idle",
                  qos: MqttQos.atLeastOnce, retain: true);
              _mqttService.publish("control/monitoring/camera", "inactive",
                  qos: MqttQos.atLeastOnce, retain: true);

              Future<void> fail(String title, String message) async {
                Navigator.pop(context);
                toastHelper.show(
                    title: title, description: message, isError: true);
              }

              try {
                final patched = await _supabaseClient
                    .from("status_records")
                    .update({
                      'is_completed': true,
                      'remarks': "none",
                    })
                    .eq('status_schedule_id', widget.scheduleId)
                    .eq("status", "initial")
                    .select();

                log.severe(patched);

                // if (!patched.isCompleted) {
                //   await fail(
                //     "Updating schedule status failed",
                //     "An error has occurred while processing the records",
                //   );
                //   return;
                // }

                final statusResp = await http.post(
                  Uri.parse("https://verminator.thinkio.me/status"),
                  headers: {'Content-Type': 'application/json; charset=UTF-8'},
                  body: jsonEncode({
                    "statusScheduleId": widget.scheduleId,
                    "status": "active",
                    "remarks": null
                  }),
                );

                if (statusResp.statusCode != 200) {
                  await fail("Status update failed",
                      statusResp.body.parseErrorMessage());
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InitializationSuccessScreen(
                      scheduleId: widget.scheduleId,
                    ),
                  ),
                );
              } catch (e) {
                await fail("Unexpected Error", e.toString());
              }
            }
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Widget _scheduleDetailsSection({
    required double deviceWidth,
    required String scheduleIdentifier,
    required String response,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            scheduleIdentifier,
            style: GoogleFonts.electrolize(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          Container(
            width: deviceWidth * 0.1,
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
            child: Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          Text(
            response,
            style: GoogleFonts.electrolize(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _materialIndicatorWidget({
    required int value,
    required String label,
    required Color chipColor,
  }) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 164,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
        Chip(
          backgroundColor: chipColor.withAlpha(16),
          side: BorderSide(
            color: chipColor,
          ),
          label: Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _materialsListSection({
    required String listLabel,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          listLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.025,
          ),
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh),
              ),
              child: const Text("Valid Materiales"),
            )
          ],
        ),
      ],
    );
  }

  Widget _bottomInformationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: Colors.amberAccent,
                label: Text(
                  "TIP",
                  style: GoogleFonts.notoSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: Text(
                  Constants.loadingTips[_currentTipIndex],
                  key: ValueKey(_currentTipIndex),
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: const SizedBox(height: 24, width: 24, child: Loader())),
        ],
      ),
    );
  }

  Future<void> _initializeFlutterTTS() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(0.8);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

  Future<void> pause() async {
    await flutterTts.pause();
  }
}
