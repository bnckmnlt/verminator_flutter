import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/error_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/bedding_condition_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/materials_processed_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/nutrient_summary_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/sensor_readings_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/system_information_widget.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final DateTime now = DateTime.now();
  late MqttService _mqttService;

  int _currentTab = 0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    _mqttService = GetIt.I<MqttService>();
    _mqttService.connect();
  }

  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<CompostScheduleBloc>().add(CompostScheduleList());
      context.read<FoodWasteBloc>().add(FoodWasteList());
      context.read<SensorReadingBloc>().add(SensorReadingList());
      _hasLoaded = true;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final formattedDate = DateFormat('d, MMMM y').format(now);
    final formattedTime = DateFormat('HH:mm').format(now);

    final toastHelper = ToastHelper(context);

    final List<Widget> _cardSections = [
      MaterialsProcessedWidget(),
      NutrientSummaryWidget(),
      BeddingConditionWidget(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double deviceHeight = MediaQuery.of(context).size.height;
        final double deviceWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Container(
            height: deviceHeight,
            width: deviceWidth,
            padding: const EdgeInsets.fromLTRB(44, 44, 44, 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _homeScreenHeaderSection(
                  formattedDate: formattedDate,
                  formattedTime: formattedTime,
                ),
                const SizedBox(height: 44),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // TODO:
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    width: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0),
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: SingleChildScrollView(
                                          child: _cardSections[_currentTab],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Row(
                                        children: List.generate(
                                                3, (int index) => index,
                                                growable: false)
                                            .map((item) {
                                          return Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                item == 0 ? 0 : 6, 0, 0, 0),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _currentTab = item;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 12),
                                                decoration: BoxDecoration(
                                                  color: item == _currentTab
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .surfaceContainerHigh
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                    color: item == _currentTab
                                                        ? Color(0xFF27272a)
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .surfaceContainerHigh,
                                                  ),
                                                ),
                                                child: Text(
                                                  "${item + 1}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              flex: 2,
                              child: SensorReadingsWidget(
                                mqttService: _mqttService,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  // TODO: Camera + YOLO inference window
                                  Container(
                                    height: 320,
                                    width: 320,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh,
                                      ),
                                    ),
                                    // child: const VideoFeedWidget(
                                    //   cameraChannel:
                                    //       "http://192.168.1.22:8080/video_feed",
                                    // ),
                                  ),
                                  const SizedBox(height: 16),
                                  // TODO: Worm monitoring window
                                  Container(
                                    height: 320,
                                    width: 320,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh,
                                      ),
                                    ),
                                    // child: const VideoFeedWidget(
                                    //   cameraChannel:
                                    //       "http://192.168.1.22:5000/",
                                    // ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: BlocConsumer<CompostScheduleBloc,
                                  CompostScheduleState>(
                                listener: (context, state) {
                                  if (state is CompostScheduleFailure) {
                                    toastHelper.show(
                                      title: "An error has occurred",
                                      description: state.error,
                                      isError: true,
                                    );
                                  }
                                },
                                builder: (context, compostScheduleState) {
                                  if (compostScheduleState
                                      is CompostScheduleLoading) {
                                    return const Loader();
                                  }
                                  if (compostScheduleState
                                      is CompostScheduleFailure) {
                                    return Center(
                                      child: GeneralErrorWidget(
                                        errorTitle:
                                            "An error has occurred during fetching",
                                        errorMessage:
                                            compostScheduleState.error,
                                      ),
                                    );
                                  }
                                  if (compostScheduleState
                                      is CompostScheduleListSuccess) {
                                    return BlocConsumer<FoodWasteBloc,
                                        FoodWasteState>(
                                      listener: (context, state) {
                                        if (state is FoodWasteFailure) {
                                          toastHelper.show(
                                            title: "An error has occurred",
                                            description: state.error,
                                            isError: true,
                                          );
                                        }
                                      },
                                      builder: (context, foodWasteState) {
                                        if (foodWasteState
                                            is FoodWasteLoading) {
                                          return const Loader();
                                        }
                                        if (foodWasteState
                                            is FoodWasteFailure) {
                                          return Center(
                                            child: GeneralErrorWidget(
                                              errorTitle:
                                                  "An error has occurred during fetching",
                                              errorMessage:
                                                  foodWasteState.error,
                                            ),
                                          );
                                        }
                                        if (foodWasteState
                                            is FoodWasteListSuccess) {
                                          return SystemInformationWidget(
                                            scheduleData: compostScheduleState
                                                .compostScheduleList,
                                            foodWasteData:
                                                foodWasteState.foodWaste,
                                          );
                                        }
                                        return const Loader();
                                      },
                                    );
                                  }
                                  return const Loader();
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _homeScreenHeaderSection({
    required String formattedDate,
    required String formattedTime,
  }) {
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good Morning!';
      } else if (hour < 18) {
        return 'Good Afternoon!';
      } else {
        return 'Good Evening!';
      }
    }

    List<ButtonList> buttonList = [
      ButtonList(
          icon: FluentIcons.document_bullet_list_24_regular,
          onPressedFunction: () {
            Navigator.pushNamed(context, '/schedule');
          }),
      ButtonList(
          icon: FluentIcons.toggle_multiple_24_regular,
          onPressedFunction: () {
            Navigator.pushNamed(context, '/controls');
          }),
      ButtonList(
          icon: FluentIcons.text_bullet_list_ltr_24_filled,
          onPressedFunction: () {
            Navigator.pushNamed(context, '/logs');
          }),
      ButtonList(
          icon: FluentIcons.settings_24_regular,
          onPressedFunction: () {
            Navigator.pushNamed(context, '/settings');
          }),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "The following summary reflects system conditions as of ${formattedDate} at ${formattedTime}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
              ),
            ),
          ],
        ),
        Row(
          children: buttonList.asMap().entries.map((entry) {
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.fromLTRB(entry.key == 0 ? 0 : 4, 0, 0, 0),
              child: OutlinedButton(
                onPressed: item.onPressedFunction,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: Size.zero,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    width: 1,
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}

class ButtonList {
  final IconData icon;
  final VoidCallback onPressedFunction;

  ButtonList({
    required this.icon,
    required this.onPressedFunction,
  });
}
