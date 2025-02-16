import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_page_sections/live_monitoring_section.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_page_sections/sensor_reading_section.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_page_sections/summary_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceHeight = constraints.maxHeight;
        final deviceWidth = constraints.maxWidth;
        bool isDark =
            MediaQuery.of(context).platformBrightness == Brightness.dark;

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: SizedBox(
            height: deviceHeight,
            width: deviceWidth,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    color: isDark
                        ? Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withAlpha(124)
                        : Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello Admin,",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(168),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.025,
                              ),
                            ),
                            Text(
                              "Good Morning!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: deviceWidth * 0.05,
                          ),
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onSurface,
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                label: const Text(
                                  "Export data (*.xlsx)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.025,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.download_rounded,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Data Summary
                  Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(124),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 1st Section
                        SummarySection(),

                        const SizedBox(height: 24),
                        // 2nd Section
                        SensorReadingSection(),

                        const SizedBox(height: 24),
                        // 3rd Section
                        LiveMonitoringSection(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
