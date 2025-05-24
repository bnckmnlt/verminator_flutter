import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MaterialsProcessedWidget extends StatefulWidget {
  const MaterialsProcessedWidget({super.key});

  @override
  State<MaterialsProcessedWidget> createState() =>
      _MaterialsProcessedWidgetState();
}

class _MaterialsProcessedWidgetState extends State<MaterialsProcessedWidget> {
  final List<ChartData> data = [
    ChartData('Fruit', 20, Color(0xff2563EB)),
    ChartData('Vegetable', 10, Color(0xff3B86F7)),
    ChartData('Grain', 4, Color(0xff60A8FB)),
    ChartData('Invalid', 14, Color(0xff90C7FE)),
  ];

  @override
  Widget build(BuildContext context) {
    return BounceWithFadeAnimation(
      delay: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Food Waste Processed",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Overview of recent food waste processed during initialization.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: SfCircularChart(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  annotations: <CircularChartAnnotation>[
                    CircularChartAnnotation(
                      widget: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data
                                  .fold<num>(0, (sum, item) => sum + item.y)
                                  .toInt()
                                  .toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.025,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'Processed',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(164),
                                fontSize: 12,
                                letterSpacing: 0.025,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                  series: <CircularSeries<ChartData, String>>[
                    DoughnutSeries(
                        innerRadius: '65%',
                        explode: true,
                        explodeIndex: 3,
                        explodeOffset: '8%',
                        dataSource: data,
                        pointColorMapper: (ChartData data, _) => data.color,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y)
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: data.map((item) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.x,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(164),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.025,
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
