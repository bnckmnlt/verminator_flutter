import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:mqtt_client/mqtt_client.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  late MqttService _mqttService;
  TextEditingController weightInputController = TextEditingController();

  Key animationKey = UniqueKey();

  int currentScaleSelected = 1;

  int currentStepWidget = 0;

  List<String> selectedScale = ["COMPOST", "RESERVOIR", "VERMITEA"];

  @override
  void initState() {
    super.initState();

    _mqttService = GetIt.instance<MqttService>();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stepsWidgetList = [
      _scaleSelectionStepWidget(context, _mqttService),
      _removeAllWeightStepWidget(context, _mqttService),
      _setWeightStepWidget(context, _mqttService, weightInputController),
      _saveToMemoryStepWidget(context, _mqttService),
    ];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(44, 0, 0, 24),
                child: Text(
                  "Container Calibration Setup",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(44, 0, 12, 0),
                        child: GridView.count(
                          crossAxisCount: 1,
                          childAspectRatio: 5,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          children:
                              List.generate(stepsWidgetList.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: index < currentStepWidget
                                    ? Colors.greenAccent.withAlpha(14)
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withAlpha(64),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: index < currentStepWidget
                                      ? Colors.greenAccent.withAlpha(124)
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  width: 1.5,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(24, 12, 24, 12),
                              child: stepsWidgetList[index],
                            );
                          }),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 3,
                        child: currentStepWidget == 4
                            ? Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 44, 0),
                                child: BounceWithFadeAnimation(
                                  key: animationKey,
                                  delay: 1.5,
                                  child: AnimatedContainer(
                                    height: MediaQuery.of(context).size.height *
                                        0.785,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 12, 24, 12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Lottie.asset(
                                          'assets/animations/success-animate.json',
                                          repeat: false,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                        ),
                                        Text(
                                          "Successfully calibrated!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.025,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Your container is now calibrated and ready. All calibration\nsteps were completed without issues.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withAlpha(124),
                                            letterSpacing: 0.025,
                                          ),
                                        ),
                                        const SizedBox(height: 36),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                14, 8, 10, 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Return to settings",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  letterSpacing: 0.025,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                FluentIcons
                                                    .chevron_right_24_filled,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scaleSelectionStepWidget(
      BuildContext context, MqttService mqttService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Text(
              "Assign the container type you wish to calibrate using the load cell and HX711 module."
              "\nFollow the instructions on the next screen to complete the calibration process accurately.",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                letterSpacing: 0.025,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  "Select Container Scale",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.025,
                  ),
                ),
                DropdownMenu<int>(
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 14),
                  initialSelection: currentScaleSelected,
                  onSelected: (value) {
                    setState(() {
                      refreshAnimations();
                      currentScaleSelected = value!;
                    });
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 1, label: 'Compost Container'),
                    DropdownMenuEntry(value: 2, label: 'Reservoir Container'),
                    DropdownMenuEntry(value: 3, label: 'Vermitea Container'),
                  ],
                  menuStyle: MenuStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withAlpha(230),
                    ),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                    ),
                    padding: MaterialStatePropertyAll(
                      const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    constraints: const BoxConstraints(
                      minHeight: 32,
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(124),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        currentStepWidget == 0
            ? _stepNavigationControls(
                () => mqttService.publish(
                  "control/scale",
                  "${selectedScale[currentScaleSelected]}:BEGIN",
                  qos: MqttQos.atLeastOnce,
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  Widget _removeAllWeightStepWidget(
      BuildContext context, MqttService mqttService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Please remove all weight from the container or platform connected to the load cell. Press"
              "\n'Continue' once the scale is completely unloaded to record the baseline reading.",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                letterSpacing: 0.025,
                height: 1.4,
              ),
            ),
          ],
        ),
        currentStepWidget == 1
            ? _stepNavigationControls(
                () => mqttService.publish(
                  "control/scale",
                  "${selectedScale[currentScaleSelected]}:CONTINUE",
                  qos: MqttQos.atLeastOnce,
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  Widget _setWeightStepWidget(BuildContext context, MqttService mqttService,
      TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Text(
              "Tare complete. Place a known mass on the container or platform connected to the load cell",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                letterSpacing: 0.025,
                height: 1.4,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  "Enter Known Weight Value (grams)",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.025,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withAlpha(124),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(
                          minHeight: 48,
                          minWidth: 200,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary, // Or another color
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
        currentStepWidget == 2
            ? _stepNavigationControls(
                () => mqttService.publish(
                  "control/scale",
                  "${selectedScale[currentScaleSelected]}:${controller.text.trim()}",
                  qos: MqttQos.atLeastOnce,
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  Widget _saveToMemoryStepWidget(
      BuildContext context, MqttService mqttService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            Text(
              "Save calibration values to EEPROM memory? This will finalize the configuration for this\ncontainer",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                letterSpacing: 0.025,
                height: 1.4,
              ),
            ),
          ],
        ),
        currentStepWidget == 3
            ? _stepNavigationControls(
                () => mqttService.publish(
                  "control/scale",
                  "${selectedScale[currentScaleSelected]}:SAVE",
                  qos: MqttQos.atLeastOnce,
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  void refreshAnimations() {
    setState(() {
      animationKey = UniqueKey();
    });
  }

  void navigatePreviousStep() {
    setState(() {
      refreshAnimations();
      currentStepWidget--;
    });
  }

  void navigateNextStep() {
    setState(() {
      refreshAnimations();
      currentStepWidget++;
    });
  }

  Widget _stepNavigationControls(Function buttonBehavior) {
    return BounceWithFadeAnimation(
      key: animationKey,
      delay: 1.5,
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          currentStepWidget != 0
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.fromLTRB(44, 10, 44, 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: navigatePreviousStep,
                  child: Text(
                    "Go back",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.025,
                    ),
                  ),
                )
              : SizedBox.shrink(),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.fromLTRB(44, 10, 44, 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                navigateNextStep();
                buttonBehavior();
              },
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.025,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
