import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_schedule/app_schedule_cubit.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_settings/app_settings_cubit.dart';
import 'package:flutter_vermicomposting/core/common/widgets/app_background.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/models/food_waste_model.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_failed_screen.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final AppSettingsCubit _appSettingsCubit = GetIt.I<AppSettingsCubit>();
  late final FlutterTts flutterTts;

  bool _hasInitialized = false;

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

    _start = _appSettingsCubit.state.feedingTimer;

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
                speak("Valid material detected. Proceeding to bedding layer.");
              } else if (item.materialStatus.name == 'invalid') {
                speak("Invalid material detected. Redirecting for disposal.");
              } else if (item.materialStatus.name == 'controlled') {
                speak(
                    "Controlled material detected. Handle feeding with caution.");
              }
            }

            _latestTimestamp = newEntries
                .map((e) => DateTime.parse(e.createdAt))
                .reduce((a, b) => a.isAfter(b) ? a : b);
          });
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

    if (!_hasInitialized) {
      startTimer();
      _hasInitialized = true;
    }
  }

  @override
  void dispose() {
    _foodWasteSubscription.cancel();
    _tipTimer?.cancel();
    _timer.cancel();
    _hasInitialized = false;
    isProcessing = false;
    _currentTipIndex = 0;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final deviceHeight = MediaQuery.of(context).size.height;
      final deviceWidth = MediaQuery.of(context).size.width;

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
                    final settingsPayload = {
                      "status": "idle",
                      "id": widget.scheduleId.toString(),
                      "reading_interval": "15",
                      "refresh_rate": "2",
                    };

                    _mqttService.publish(
                      "system/settings",
                      jsonEncode(settingsPayload),
                      qos: MqttQos.atLeastOnce,
                      retain: true,
                    );
                    _mqttService.publish(
                        "control/monitoring/camera", "inactive",
                        qos: MqttQos.atLeastOnce, retain: true);
                    _mqttService.publish(
                      "control/conveyor",
                      "Stop",
                      qos: MqttQos.atLeastOnce,
                      retain: true,
                    );

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
    final settingsPayload = {
      "status": "feeding",
      "id": widget.scheduleId.toString(),
      "reading_interval": "15",
      "refresh_rate": "2",
    };

    _mqttService.publish(
      "system/settings",
      jsonEncode(settingsPayload),
      qos: MqttQos.atLeastOnce,
      retain: true,
    );
    _mqttService.publish("control/monitoring/camera", "active",
        qos: MqttQos.atLeastOnce, retain: true);
    _mqttService.publish(
      "control/conveyor",
      "Continuous",
      qos: MqttQos.atLeastOnce,
      retain: true,
    );

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
            }

            const validClasses = [
              FoodWasteClassname.fruitWaste,
              FoodWasteClassname.vegetableWaste,
              FoodWasteClassname.paperCardboard,
              FoodWasteClassname.leavesDryMaterial,
            ];

            const controlledClasses = [
              FoodWasteClassname.onionGarlic,
              FoodWasteClassname.spicyMaterial,
              FoodWasteClassname.eggshellsCoffeeGrounds,
              FoodWasteClassname.grainsAndBread,
            ];

            final acceptedClasses = [...validClasses, ...controlledClasses];

            final hasAccepted = wasteList.any(
              (waste) => acceptedClasses.contains(waste.classname),
            );

            if (!hasAccepted) {
              errorList[0] = true;
            }
          }

          isError = errorList.contains(true);

          timer.cancel();
          _tipTimer?.cancel();

          Future.delayed(const Duration(milliseconds: 500), () async {
            if (!mounted) return;

            if (isError) {
              final settingsPayload = {
                "status": "idle",
                "id": widget.scheduleId.toString(),
                "reading_interval": "15",
                "refresh_rate": "2",
              };

              _mqttService.publish(
                "system/settings",
                jsonEncode(settingsPayload),
                qos: MqttQos.atLeastOnce,
                retain: true,
              );
              _mqttService.publish("control/monitoring/camera", "inactive",
                  qos: MqttQos.atLeastOnce, retain: true);
              _mqttService.publish(
                "control/conveyor",
                "Stop",
                qos: MqttQos.atLeastOnce,
                retain: true,
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InitializationFailedScreen(
                    errorStatusList: errorList,
                    scheduleId: widget.scheduleId,
                  ),
                ),
              );
              return;
            }

            Future<void> fail(String title, String message) async {
              if (!mounted) return;
              Navigator.pop(context);
              toastHelper.show(
                  title: title, description: message, isError: true);
            }

            try {
              await _supabaseClient
                  .from("status_records")
                  .update({
                    'is_completed': true,
                    'remarks': "none",
                  })
                  .eq('status_schedule_id', widget.scheduleId)
                  .eq("status", "initial");

              if (!mounted) return;

              final result = await _supabaseClient
                  .from("status_records")
                  .select("is_completed")
                  .eq('status_schedule_id', widget.scheduleId)
                  .eq("status", "initial")
                  .maybeSingle();

              if (!mounted) return;

              final isCompleted =
                  result != null && result['is_completed'] == true;

              if (!isCompleted) {
                await fail(
                  "Updating schedule status failed",
                  "An error has occurred while processing the records",
                );
                return;
              }

              final settingsPayload = {
                "status": "active",
                "id": widget.scheduleId.toString(),
                "reading_interval": "15",
                "refresh_rate": "2",
              };

              _mqttService.publish(
                "system/settings",
                jsonEncode(settingsPayload),
                qos: MqttQos.atLeastOnce,
                retain: true,
              );
              _mqttService.publish("control/monitoring/camera", "inactive",
                  qos: MqttQos.atLeastOnce, retain: true);
              _mqttService.publish(
                "control/conveyor",
                "Stop",
                qos: MqttQos.atLeastOnce,
                retain: true,
              );
              _mqttService.publish(
                "control/rake",
                "Process:15",
                qos: MqttQos.atLeastOnce,
                retain: true,
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InitializationSuccessScreen(
                    scheduleId: widget.scheduleId,
                  ),
                ),
              );
              return;
            } catch (e) {
              await fail("Unexpected Error", e.toString());
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
