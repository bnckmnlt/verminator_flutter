import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/popup_selection_widget.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:mqtt_client/mqtt_client.dart';

class CalibrationWidget extends StatefulWidget {
  const CalibrationWidget({super.key});

  @override
  State<CalibrationWidget> createState() => _CalibrationWidgetState();
}

class _CalibrationWidgetState extends State<CalibrationWidget> {
  late MqttService _mqttService;

  final TextEditingController _knownWeightController = TextEditingController();
  Key _animationKey = UniqueKey();

  int _currentStep = 0;
  int _scaleSelected = 0;

  @override
  void initState() {
    _mqttService = GetIt.instance<MqttService>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    final double horizontalPadding = deviceWidth * 0.05;
    final double verticalPadding = deviceHeight * 0.03;

    Widget scaleSelectionDropdown = SizedBox(
      width: deviceWidth * 0.135,
      child: PopupSelectionWidget(
        label: "${Constants().scaleSelection[_scaleSelected]} CONTAINER",
        selectedFunction: (value) => setState(() {
          _scaleSelected = value;
        }),
        popupKeys: Constants()
            .scaleSelection
            .map((item) => "$item Container")
            .toList(),
        trailingIcon: Icon(
          FluentIcons.caret_down_24_filled,
          size: 14,
        ),
      ),
    );

    final List<CalibrationCardData> calibrationStepsData = [
      CalibrationCardData(
          label: "Select Scale",
          description:
              "Assign the container type you wish to calibrate using the load cell and HX711 module. Follow the instructions on the next screen to complete the calibration process accurate",
          imageSrc: "assets/images/select_scale.png",
          childWidget: scaleSelectionDropdown,
          buttonOnPressed: () => _publishCommand("BEGIN")),
      CalibrationCardData(
          label: "Clear the Scale",
          description:
              "Please remove all weight from the container or platform connected to the load cell. Press 'Continue' once the scale is completely unloaded to record the baseline reading",
          imageSrc: "assets/images/clear_scale.png",
          buttonOnPressed: () => _publishCommand("CONTINUE")),
      CalibrationCardData(
          label: "Calibrate and Tare",
          description:
              "Tare complete. Place a known mass on the container or platform connected to the load cell",
          imageSrc: "assets/images/calibrate_and_tare.png",
          childWidget: _setKnownMassWidget(),
          buttonOnPressed: () =>
              _publishCommand(_knownWeightController.text.trim())),
      CalibrationCardData(
          label: "Save Calibration",
          description:
              "Save calibration values to EEPROM memory? This will finalize the configuration for this container",
          imageSrc: "assets/images/save_in_memory.png",
          buttonOnPressed: () => _publishCommand("SAVE")),
      CalibrationCardData(
          label: "Successfully calibrated!",
          description:
              "Your container is now calibrated and ready. All calibration steps were completed without issues.",
          imageSrc: "assets/animations/success-animate.json",
          isAnimated: true,
          buttonOnPressed: () => Navigator.pop(context)),
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
        child: Container(
          height: deviceHeight,
          width: deviceWidth,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          child: Column(
            spacing: 18,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Container Calibration Setup",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      spacing: 14,
                      children: calibrationStepsData
                          .asMap()
                          .entries
                          .where((entry) =>
                              entry.key != calibrationStepsData.length - 1)
                          .map((entry) {
                        final int index = entry.key;
                        final data = entry.value;

                        final bool isDone = index < _currentStep;
                        final Color color = isDone
                            ? Colors.greenAccent.withAlpha(32)
                            : Colors.white;
                        final IconData iconData = isDone
                            ? FluentIcons.checkmark_circle_24_filled
                            : FluentIcons.circle_hint_24_regular;

                        return Glassmorphism(
                          blur: 12,
                          opacity: 0.2,
                          child: AnimatedContainer(
                            height: deviceHeight * 0.1,
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding * 0.3),
                            curve: Curves.easeInOut,
                            duration: const Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh
                                    .withAlpha(64),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDone ? color : color.withAlpha(10),
                                  width: 1.5,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    color.withAlpha(28),
                                    color.withAlpha(24),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Step ${index + 1}:\t\t${data.label}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: "Zenbones Mono",
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.025,
                                  ),
                                ),
                                Icon(
                                  iconData,
                                  color: color.withAlpha(255),
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(64),
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: deviceHeight * 0.75,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLow
                              .withAlpha(124),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            width: 2,
                          )),
                      child: BounceWithFadeAnimation(
                        key: _animationKey,
                        delay: 1.5,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: deviceHeight * 0.05,
                            horizontal: deviceWidth * 0.05,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: deviceWidth * 0.3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 14,
                                    children: [
                                      SizedBox(
                                        height: deviceHeight * 0.3,
                                        child:
                                            calibrationStepsData[_currentStep]
                                                        .isAnimated !=
                                                    null
                                                ? Lottie.asset(
                                                    calibrationStepsData[
                                                            _currentStep]
                                                        .imageSrc,
                                                    repeat: false,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.2,
                                                  )
                                                : ShaderMask(
                                                    shaderCallback: (bounds) =>
                                                        RadialGradient(
                                                      center: Alignment.center,
                                                      radius: 1.0,
                                                      colors: [
                                                        Colors.white,
                                                        Colors.transparent
                                                      ],
                                                      stops: [0.2, 1.0],
                                                    ).createShader(bounds),
                                                    blendMode: BlendMode.dstIn,
                                                    child: Image.asset(
                                                      calibrationStepsData[
                                                              _currentStep]
                                                          .imageSrc,
                                                      fit: BoxFit.fill,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24),
                                        child: Column(
                                          spacing: 8,
                                          children: [
                                            Text(
                                              calibrationStepsData[_currentStep]
                                                  .label,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: "Zenbones Mono",
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.025,
                                              ),
                                            ),
                                            Text(
                                              calibrationStepsData[_currentStep]
                                                  .description,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700],
                                                letterSpacing: 0.025,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child:
                                            calibrationStepsData[_currentStep]
                                                    .childWidget ??
                                                SizedBox.shrink(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _currentStep != 0 && _currentStep != 4
                                      ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                32, 10, 32, 10),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          onPressed: () => setState(() {
                                            _currentStep--;
                                          }),
                                          child: Text(
                                            "Go back",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.fromLTRB(
                                          32, 10, 32, 10),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shadowColor: Colors.grey.shade500,
                                    ),
                                    onPressed:
                                        calibrationStepsData[_currentStep]
                                            .buttonOnPressed,
                                    child: Text(
                                      _currentStep < 4
                                          ? "Continue"
                                          : "Return to Settings",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _setKnownMassWidget() {
    return Column(
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
          height: 40,
          width: MediaQuery.of(context).size.width * 0.15,
          child: TextFormField(
              keyboardType: TextInputType.number,
              controller: _knownWeightController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withAlpha(124),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                constraints: BoxConstraints(
                  minHeight: 32,
                  minWidth: 200,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              )),
        ),
      ],
    );
  }

  void _publishCommand(String command) {
    refreshAnimations();

    setState(() {
      _currentStep < 4 ? _currentStep++ : null;
    });

    _mqttService.publish("control/scale",
        "${Constants().scaleSelection[_scaleSelected]}:$command",
        qos: MqttQos.atLeastOnce);
  }

  void refreshAnimations() {
    setState(() {
      _animationKey = UniqueKey();
    });
  }
}

class CalibrationCardData {
  final String label;
  final String description;
  final String imageSrc;
  final bool? isAnimated;
  final Widget? childWidget;
  final void Function() buttonOnPressed;

  CalibrationCardData({
    required this.label,
    required this.description,
    required this.imageSrc,
    this.isAnimated,
    this.childWidget,
    required this.buttonOnPressed,
  });
}
