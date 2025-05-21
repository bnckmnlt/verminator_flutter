import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/success_page.dart';
import 'package:google_fonts/google_fonts.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({super.key});

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage>
    with SingleTickerProviderStateMixin {
  final List<String> loadingTips = [
    "Avoid placing plastic wrappers or utensils on the conveyor — they are not compostable.",
    "Add food waste one item at a time for accurate sorting and classification.",
    "Did you know? Citrus peels and onions are valid — but too much can slow down composting!",
    "Never throw glass, metal, or rubber items — these are harmful to the worms.",
    "Cut large scraps (like melon rinds) into smaller pieces for faster breakdown.",
    "Reminder: Do not stack food waste — multiple items at once may lead to misclassification.",
    "Paper towels and napkins are compostable if they’re not soaked in chemicals.",
    "Coffee grounds and filters are great for worm bins, but the system doesn't support them yet. :(",
    "Plastics, styrofoam, and foil should never go into the compost stream.",
    "Always check your food waste for stray non-organic packaging before loading."
  ];

  late AnimationController _controller;
  late Animation<Alignment> _tlAlignAnim;
  late Animation<Alignment> _brAlignAnim;

  int _currentTipIndex = 0;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    _tipTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        _currentTipIndex = ((_currentTipIndex + 1) % loadingTips.length) as int;
      });
    });

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _tlAlignAnim = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topRight),
          weight: 1),
    ]).animate(_controller);

    _brAlignAnim = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
    ]).animate(_controller);

    _controller.repeat();
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
        body: Padding(
          padding: EdgeInsets.all(deviceHeight * 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "May Cycle",
                      style: GoogleFonts.electrolize(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: deviceWidth * 0.1, child: Divider()),
                    Text(
                      "Awaiting food waste to be loaded...",
                      style: GoogleFonts.electrolize(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipPath(
                        clipper: _CenterCutPath(
                          radius: 164,
                          thickness: 1,
                        ),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return Container(
                              height: 164,
                              width: 164,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(164)),
                                gradient: LinearGradient(
                                  begin: _tlAlignAnim.value,
                                  end: _brAlignAnim.value,
                                  colors: [
                                    Colors.lightBlueAccent,
                                    Colors.indigoAccent
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 64),
                      ClipPath(
                        clipper: _CenterCutPath(
                          radius: 164,
                          thickness: 1,
                        ),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return Container(
                              height: 164,
                              width: 164,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(164)),
                                gradient: LinearGradient(
                                  begin: _tlAlignAnim.value,
                                  end: _brAlignAnim.value,
                                  colors: [
                                    Colors.lightBlueAccent,
                                    Colors.indigoAccent
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 24, width: 24, child: Loader()),
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
                                builder: (context) => SuccessPage(),
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
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            loadingTips[_currentTipIndex],
                            key: ValueKey(_currentTipIndex),
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              letterSpacing: 0.025,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _CenterCutPath extends CustomClipper<Path> {
  final double radius;
  final double thickness;

  _CenterCutPath({
    this.radius = 0,
    this.thickness = 1,
  });

  @override
  Path getClip(Size size) {
    final rect = Rect.fromLTRB(
        -size.width, -size.width, size.width * 2, size.height * 2);
    final double width = size.width - thickness * 2;
    final double height = size.height - thickness * 2;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(thickness, thickness, width, height),
          Radius.circular(radius - thickness),
        ),
      )
      ..addRect(rect);

    return path;
  }

  @override
  bool shouldReclip(covariant _CenterCutPath oldclipper) {
    return oldclipper.radius != radius || oldclipper.thickness != thickness;
  }
}
