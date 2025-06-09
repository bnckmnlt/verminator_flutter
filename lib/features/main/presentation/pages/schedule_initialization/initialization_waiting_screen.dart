import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vermicomposting/core/common/widgets/app_background.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';

import 'initialization_success_screen.dart';

class InitializationWaitingScreen extends StatefulWidget {
  const InitializationWaitingScreen({super.key});

  @override
  State<InitializationWaitingScreen> createState() =>
      _InitializationWaitingScreenState();
}

class _InitializationWaitingScreenState
    extends State<InitializationWaitingScreen> {
  int _currentTipIndex = 0;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    _tipTimer = Timer.periodic(Duration(seconds: 6), (timer) {
      setState(() {
        _currentTipIndex =
            ((_currentTipIndex + 1) % Constants.loadingTips.length);
      });
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final deviceHeight = MediaQuery.of(context).size.height;
      final deviceWidth = MediaQuery.of(context).size.width;
      final isDarkMode =
          MediaQuery.of(context).platformBrightness == Brightness.dark;

      return Scaffold(
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
                    scheduleIdentifier: "May Cycle",
                    response: "Awaiting food waste to be loaded...",
                  ),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _materialsListSection(
                            listLabel: "Valid Materials",
                          ),
                          _materialIndicatorWidget(
                            value: 8,
                            label: "Valid Materials",
                            chipColor: Colors.blueAccent,
                          ),
                          _materialIndicatorWidget(
                              value: 12,
                              label: "Invalid Materials",
                              chipColor: Colors.redAccent),
                          _materialsListSection(
                            listLabel: "Invalid Materials",
                          ),
                        ],
                      ),
                    ],
                  ),
                  _bottomInformationSection(),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
    return Column(
      children: [
        const SizedBox(height: 24, width: 24, child: Loader()),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InitializationSuccessScreen(),
                    ),
                  );
                },
                child: Badge(
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
        ),
      ],
    );
  }
}
