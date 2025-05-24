import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/bedding_condition_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/materials_processed_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/nutrient_summary_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/sensor_readings_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/system_information_widget.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final DateTime now = DateTime.now();

  int _currentTab = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final formattedDate = DateFormat('d, MMMM y').format(now);
    final formattedTime = DateFormat('HH:mm').format(now);

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
                              child: SensorReadingsWidget(),
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
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SystemInformationWidget(),
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
      ],
    );
  }
}
