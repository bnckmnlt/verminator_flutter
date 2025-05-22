import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vermicomposting/core/common/widgets/app_background.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/configurations_page.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/list_item_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  final List<ClassListItem> validMaterials = const [
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Fruits_5123512.jpg",
      iconColor: Colors.indigo,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Vegetable_23232362.jpg",
      iconColor: Colors.green,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Vegetable_736234.jpg",
      iconColor: Colors.green,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Grain_2342623.jpg",
      iconColor: Colors.amber,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Fruits_482341.jpg",
      iconColor: Colors.indigo,
    ),
    ClassListItem(
      icon: FluentIcons.food_apple_24_regular,
      text: "Grain_981300.jpg",
      iconColor: Colors.amber,
    ),
  ];

  final List<ClassListItem> invalidMaterials = const [
    ClassListItem(
      icon: FluentIcons.prohibited_24_regular,
      text: "Invalid_5123512.jpg",
      iconColor: Colors.red,
    ),
    ClassListItem(
      icon: FluentIcons.prohibited_24_regular,
      text: "Invalid_23232362.jpg",
      iconColor: Colors.red,
    ),
    ClassListItem(
      icon: FluentIcons.prohibited_24_regular,
      text: "Invalid_736234.jpg",
      iconColor: Colors.red,
    ),
    ClassListItem(
      icon: FluentIcons.prohibited_24_regular,
      text: "Invalid_4826712.jpg",
      iconColor: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  void dispose() {
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Glassmorphism(
                  blur: 64,
                  opacity: 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          width: 1,
                        )),
                    child: ClipPath(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 44.0, horizontal: 44.0),
                        child: AppBackground(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Summary",
                                          style: GoogleFonts.manrope(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.025,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Badge(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 10),
                                          backgroundColor:
                                              Colors.amberAccent.withAlpha(44),
                                          label: Text(
                                            "ID - 1",
                                            style: GoogleFonts.notoSans(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 65,
                                          height: 40,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors
                                                        .lightBlueAccent
                                                        .withAlpha(44),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                    child: const Glassmorphism(
                                                      blur: 20,
                                                      opacity: 0.2,
                                                      child: Center(
                                                        child: Icon(
                                                          FluentIcons
                                                              .food_20_regular,
                                                          color: Colors
                                                              .lightBlueAccent,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 25,
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.redAccent
                                                        .withAlpha(44),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                    child: const Glassmorphism(
                                                      blur: 20,
                                                      opacity: 0.2,
                                                      child: Center(
                                                        child: Icon(
                                                          FluentIcons
                                                              .prohibited_multiple_24_regular,
                                                          color:
                                                              Colors.redAccent,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Materials loaded and validated",
                                          style: GoogleFonts.manrope(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.025,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _classList(validMaterials),
                                          const SizedBox(width: 20),
                                          _classList(invalidMaterials),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white60.withAlpha(44),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            child: const Glassmorphism(
                                              blur: 20,
                                              opacity: 0.2,
                                              child: Center(
                                                child: Icon(
                                                  FluentIcons
                                                      .settings_24_regular,
                                                  color: Colors.white60,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Configurations",
                                          style: GoogleFonts.manrope(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.025,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 20),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHigh,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Invalid",
                                              style: GoogleFonts.manrope(
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.025,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHigh),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                child: Text(
                                  "Initial configuration uses recommended defaults. All parameters can be modified post-setup.",
                                  style: GoogleFonts.manrope(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 12,
                                    letterSpacing: 0.025,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
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
          borderRadius: const BorderRadius.all(
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
              "Successfully saved!",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.025,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "System configuration complete and ready for vermiculture operations.",
              style: GoogleFonts.manrope(
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfigurationsPage(),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "RETURN HOME",
                    style: GoogleFonts.manrope(
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

  Widget _classList(List<ClassListItem> items) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        child: ListView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          itemBuilder: (_, index) => ClassListItem(
            icon: items[index].icon,
            text: items[index].text,
            iconColor: items[index].iconColor,
          ),
        ),
      ),
    );
  }
}
