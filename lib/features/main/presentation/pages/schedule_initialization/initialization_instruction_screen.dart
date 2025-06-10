import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/common/widgets/app_background.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_waiting_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/schedule_initialization_widgets/onboarding_display_widget.dart';
import 'package:onboarding/onboarding.dart';

// TODO: [✅] DONEEEEEEEE

class InitializationInstructionScreen extends StatefulWidget {
  const InitializationInstructionScreen({super.key});

  @override
  State<InitializationInstructionScreen> createState() =>
      _InitializationInstructionScreenState();
}

class _InitializationInstructionScreenState
    extends State<InitializationInstructionScreen> {
  Key animationKey = UniqueKey();

  late int index;

  final activePainter = Paint();
  final inactivePainter = Paint();

  @override
  void initState() {
    super.initState();

    index = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    activePainter.color = Colors.white;
    activePainter.strokeWidth = 6;
    activePainter.strokeCap = StrokeCap.round;
    activePainter.style = PaintingStyle.stroke;

    inactivePainter.color = Theme.of(context).colorScheme.surfaceContainerHigh;
    inactivePainter.strokeWidth = 6;
    inactivePainter.strokeCap = StrokeCap.round;
    inactivePainter.style = PaintingStyle.fill;

    final List<String> assets = [
      'assets/images/onboarding_first_page.png',
      'assets/images/onboarding_second_page.png',
      'assets/images/onboarding_third_page.png',
    ];

    final List<Widget> pageMainWidgets = <Widget>[
      _firstPageWidget(),
      _secondPageWidget(),
      _thirdPageWidget(),
    ];

    void refreshAnimations() {
      setState(() {
        animationKey = UniqueKey();
      });
    }

    return SafeArea(
        child: Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Glassmorphism(
        blur: 64,
        opacity: 0.3,
        child: AppBackground(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 44),
            child: Center(
              child: Onboarding(
                animationInMilliseconds: 300,
                swipeableBody: List.generate(3, (index) => index).map((item) {
                  return BounceWithFadeAnimation(
                    key: animationKey,
                    delay: 1.5,
                    child: OnboardingDisplayWidget(
                      assetSrc: assets[index],
                      displayBody: Column(
                        spacing: 32,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              Text(
                                Constants.titleDescriptionPlaceholder[index]
                                    ['title'],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.025,
                                ),
                              ),
                              Text(
                                Constants.titleDescriptionPlaceholder[index]
                                    ['description'],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(124),
                                  fontSize: 16,
                                  letterSpacing: 0.025,
                                ),
                              ),
                            ],
                          ),
                          pageMainWidgets[index],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 20,
                            children: [
                              Container(
                                height: 24,
                                width: 6,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh),
                              ),
                              Text(
                                Constants.titleDescriptionPlaceholder[index]
                                    ['note'],
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                startIndex: 0,
                onPageChanges: (_, __, currentIndex, sd) {
                  setState(() {
                    index = currentIndex;
                  });
                },
                buildFooter: (context, dragDistance, pagesLength, currentIndex,
                    setIndex, slideDirection) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                    child: Row(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Indicator<LinePainter>(
                          painter: LinePainter(
                            currentPageIndex: currentIndex,
                            pagesLength: pagesLength,
                            netDragPercent: dragDistance,
                            activePainter: activePainter,
                            inactivePainter: inactivePainter,
                            lineWidth: 20,
                            translate: false,
                            slideDirection: slideDirection,
                          ),
                        ),
                        currentIndex == pagesLength - 1
                            ? ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            InitializationWaitingScreen()),
                                  );
                                },
                                child: const Text("Continue"),
                              )
                            : IconButton.outlined(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                                  ),
                                ),
                                onPressed: () {
                                  if (currentIndex < pagesLength - 1) {
                                    setState(() {
                                      index = currentIndex + 1;
                                    });
                                    setIndex(index);
                                    refreshAnimations();
                                  }
                                },
                                icon: Icon(
                                  FluentIcons.chevron_right_28_filled,
                                  size: 32,
                                ),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _firstPageWidget() {
    return Column(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Accepted Materials",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: Constants.validMaterialsPlaceholder.map((label) {
                return Row(
                  spacing: 6,
                  children: [
                    Icon(
                      FluentIcons.checkmark_24_regular,
                      size: 18,
                      color: Colors.greenAccent,
                    ),
                    Text(
                      label,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rejected Materials",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: Constants.invalidMaterialsPlaceholder.map((label) {
                return Row(
                  spacing: 6,
                  children: [
                    Icon(
                      FluentIcons.prohibited_24_regular,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    Text(
                      label,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _secondPageWidget() {
    return Column(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "System Setup",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...Constants.systemSetupPlaceholder.map((label) {
                  return Row(
                    spacing: 14,
                    children: [
                      Icon(
                        FluentIcons.circle_24_filled,
                        size: 8,
                      ),
                      Text(
                        label,
                      ),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                  child: Row(
                    children: [
                      Icon(
                        FluentIcons.circle_24_filled,
                        size: 8,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Accepted",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " and sorted into the bedding layer",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                  child: Row(
                    children: [
                      Icon(
                        FluentIcons.circle_24_filled,
                        size: 8,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Ejected",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " via servo arm if classified as invalid",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _thirdPageWidget() {
    return Column(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...Constants.systemHealthPlaceholder.map((label) {
                  return Row(
                    spacing: 14,
                    children: [
                      Icon(
                        FluentIcons.circle_24_filled,
                        size: 8,
                      ),
                      Text(
                        label,
                      ),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "TIP:",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text:
                              "  Use the dashboard to monitor real-time stats and camera feed",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
