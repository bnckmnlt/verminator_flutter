import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double deviceHeight = MediaQuery.of(context).size.height;
      final double deviceWidth = MediaQuery.of(context).size.width;
      final bool isDarkMode =
          MediaQuery.of(context).platformBrightness == Brightness.dark;

      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                      border: Border.all(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        width: 1,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 44.0, horizontal: 44.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Summary",
                                style: GoogleFonts.quicksand(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.025,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "ID: 1",
                                style: GoogleFonts.quicksand(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(124),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.025,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh,
                                )),
                            child: Column(
                              children: [
                                const Text("Center"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh,
                                )),
                            child: Column(
                              children: [
                                const Text("Footer"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              _successColumn(deviceHeight),
            ],
          ),
        ),
      );
    });
  }

  Widget _successColumn(double deviceHeight) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/success-animate.json',
              repeat: false,
              height: deviceHeight * 0.25,
            ),
            Text(
              "Successfully loaded!",
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.025,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "System configuration complete and ready for vermiculture operations",
              style: GoogleFonts.quicksand(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
                letterSpacing: 0.025,
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {},
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "RETURN HOME",
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.025,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
