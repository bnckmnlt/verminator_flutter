import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BeddingConditionWidget extends StatefulWidget {
  const BeddingConditionWidget({super.key});

  @override
  State<BeddingConditionWidget> createState() => _BeddingConditionWidgetState();
}

class _BeddingConditionWidgetState extends State<BeddingConditionWidget> {
  final List<ChartData> _temperatureChartData = <ChartData>[
    ChartData('May 5', 36),
    ChartData('May 10', 32),
    ChartData('May 15', 28),
    ChartData('May 20', 27),
    ChartData('May 25', 29),
    ChartData('May 30', 30),
  ];

  final List<ChartData> _humidityChartData = <ChartData>[
    ChartData('May 5', 48),
    ChartData('May 10', 52),
    ChartData('May 15', 47),
    ChartData('May 20', 64),
    ChartData('May 25', 58),
    ChartData('May 30', 54),
  ];

  final List<ChartData> _soilMoistureChartData = <ChartData>[
    ChartData('May 5', 59),
    ChartData('May 10', 52),
    ChartData('May 15', 53),
    ChartData('May 20', 53),
    ChartData('May 25', 52),
    ChartData('May 30', 56),
  ];

  int selectedChart = 0;

  @override
  Widget build(BuildContext context) {
    final List<SelectedChart> beddingConditionCharts = [
      SelectedChart(
          label: 'Temperature',
          color: Color(0xff2563EB),
          data: _temperatureChartData),
      SelectedChart(
          label: 'Humidity',
          color: Color(0xff3B86F7),
          data: _humidityChartData),
      SelectedChart(
          label: 'Soil Moisture',
          color: Color(0xff90C7FE),
          data: _soilMoistureChartData),
    ];

    return BounceWithFadeAnimation(
      delay: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bedding Condition Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "The bedding condition recorded throughout the month",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 164,
                  child: SfCartesianChart(
                    margin: const EdgeInsets.all(0),
                    plotAreaBorderWidth: 0,
                    plotAreaBackgroundColor: Colors.transparent,
                    primaryXAxis: const CategoryAxis(
                      axisLine: AxisLine(width: 0),
                      labelPlacement: LabelPlacement.onTicks,
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      majorGridLines: MajorGridLines(width: 0),
                      majorTickLines: MajorTickLines(width: 0),
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.025,
                      ),
                    ),
                    primaryYAxis: const NumericAxis(
                      isVisible: false,
                    ),
                    series: <CartesianSeries<ChartData, String>>[
                      SplineSeries<ChartData, String>(
                        color: beddingConditionCharts[selectedChart].color,
                        width: 2,
                        dataSource: beddingConditionCharts[selectedChart].data,
                        xValueMapper: (ChartData d, _) => d.x,
                        yValueMapper: (ChartData d, _) => d.y,
                      ),
                      SplineAreaSeries<ChartData, String>(
                        gradient: LinearGradient(
                          colors: [
                            beddingConditionCharts[selectedChart]
                                .color
                                .withAlpha(64),
                            beddingConditionCharts[selectedChart]
                                .color
                                .withAlpha(38),
                            beddingConditionCharts[selectedChart]
                                .color
                                .withAlpha(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        dataSource: beddingConditionCharts[selectedChart].data,
                        xValueMapper: (ChartData d, _) => d.x,
                        yValueMapper: (ChartData d, _) => d.y,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: beddingConditionCharts.map((item) {
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
                          item.label,
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
              PopupMenuButton(
                onSelected: (value) => setState(() {
                  selectedChart = value;
                }),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 0,
                    child: Text('Temperature'),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Text('Humidity'),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text('Soil Moisture'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 8, 16, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        beddingConditionCharts[selectedChart].label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        FluentIcons.chevron_down_24_filled,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectedChart {
  final String label;
  final Color color;
  final List<ChartData> data;

  SelectedChart({
    required this.label,
    required this.color,
    required this.data,
  });
}
