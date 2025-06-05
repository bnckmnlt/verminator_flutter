import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphic_card_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/status_card_widget.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';

import 'initialization_waiting_screen.dart';

class InitializationFailedScreen extends StatefulWidget {
  final List<bool> errorStatusList;

  const InitializationFailedScreen({
    super.key,
    required this.errorStatusList,
  });

  @override
  State<InitializationFailedScreen> createState() =>
      _InitializationFailedScreenState();
}

class _InitializationFailedScreenState
    extends State<InitializationFailedScreen> {
  int? _expandedIndex;

  void _toggleExpand(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ProcessInformation> informationItemList = [
      ProcessInformation(
        icon: FluentIcons.food_20_regular,
        title: "No valid food waste is loaded to the machine",
        message:
            "The system was unable to detect any valid food waste during the loading process. Please ensure only acceptable materials are placed onto the conveyor. Refer to the approved material guide to avoid misclassification.",
        currentError: widget.errorStatusList[0],
      ),
      ProcessInformation(
        icon: FluentIcons.hourglass_24_regular,
        title: "User doesn't load valid materials during the duration",
        message:
            "No valid items were detected within the required loading time window. This may result in skipped compost cycles. Load materials promptly once the system prompts for input to avoid delays.",
        currentError: widget.errorStatusList[1],
      ),
      ProcessInformation(
        icon: FluentIcons.globe_error_24_regular,
        title: "Something went wrong during the process",
        message:
            "An unexpected error occurred while processing the input materials. Please restart the operation and monitor the loading steps. Ensure that the sensors and mechanical components are not obstructed or overloaded.",
        currentError: widget.errorStatusList[2],
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final double deviceHeight = MediaQuery.of(context).size.height;
      final double deviceWidth = MediaQuery.of(context).size.width;

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: StatusCardWidget(
                  iconSrc: 'assets/animations/error-animate.json',
                  title: "Initialization failed",
                  message:
                      "The compost schedule setup didn’t go through due to an issue.\nPlease click the button below to restart the process",
                  buttonLabel: "RESTART PROCESS",
                  buttonColor: Colors.redAccent,
                  buttonBehavior: () {},
                  deviceHeight: deviceHeight,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _processInformationComponent(informationItemList),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _processInformationComponent(
      List<ProcessInformation> informationItemList) {
    return GlassmorphicCardWidget(
      child: Column(
        children: [
          _infoCard(context),
          const SizedBox(height: 24),
          Column(
            children: List<Widget>.generate(
              informationItemList.length,
              (index) {
                final item = informationItemList[index];
                final isExpanded = _expandedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _accordionItem(
                    index,
                    item.icon,
                    item.title,
                    item.message,
                    item.currentError,
                    isExpanded,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 192,
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 192,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withAlpha(8),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FluentIcons.info_24_filled,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Additional information",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Before processing food waste, it is strongly recommended to verify whether the materials belong to the system's list of valid or invalid items. \n\nPlease also review the operational instructions displayed prior to starting to prevent potential issues. You may return to the instruction guide by clicking the button below.",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.025,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.white60),
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const InitializationWaitingScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Review instructions",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              FluentIcons.open_24_regular,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accordionItem(
    int index,
    IconData icon,
    String title,
    String message,
    bool currentError,
    bool isExpanded,
  ) {
    return GestureDetector(
      onTap: () => _toggleExpand(index),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withAlpha(
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? 164
                  : 64),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              offset: const Offset(0, 1),
              blurRadius: 2,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        grade: 100.0,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.025,
                        ),
                      ),
                    ],
                  ),
                  currentError
                      ? const Icon(
                          FluentIcons.error_circle_24_filled,
                          color: Colors.redAccent,
                          grade: 100.0,
                        )
                      : const Icon(
                          FluentIcons.checkmark_circle_24_filled,
                          color: Colors.greenAccent,
                          grade: 100.0,
                        ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: isExpanded ? null : 0,
                padding: isExpanded
                    ? const EdgeInsets.fromLTRB(24, 16, 24, 6)
                    : EdgeInsets.zero,
                child: isExpanded
                    ? Text(
                        message,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(186),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
