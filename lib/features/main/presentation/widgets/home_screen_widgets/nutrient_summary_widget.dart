import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NutrientSummaryWidget extends StatefulWidget {
  const NutrientSummaryWidget({super.key});

  @override
  State<NutrientSummaryWidget> createState() => _NutrientSummaryWidgetState();
}

class _NutrientSummaryWidgetState extends State<NutrientSummaryWidget> {
  final List<ChartData> _nitrogenChartData = <ChartData>[
    ChartData('May 5', 58),
    ChartData('May 10', 37),
    ChartData('May 15', 32),
    ChartData('May 20', 28),
    ChartData('May 25', 22),
    ChartData('May 30', 27),
  ];

  final List<ChartData> _phosphorusChartData = <ChartData>[
    ChartData('May 5', 23),
    ChartData('May 10', 24),
    ChartData('May 15', 45),
    ChartData('May 20', 32),
    ChartData('May 25', 58),
    ChartData('May 30', 21),
  ];

  final List<ChartData> _potassiumChartData = <ChartData>[
    ChartData('May 5', 66),
    ChartData('May 10', 32),
    ChartData('May 15', 12),
    ChartData('May 20', 42),
    ChartData('May 25', 52),
    ChartData('May 30', 61),
  ];

  final List<ChartData> chartColorList = [
    ChartData(
      "Nitrogen",
      0,
      Color(0xff2563EB),
    ),
    ChartData(
      "Phosphorus",
      0,
      Color(0xff3B86F7),
    ),
    ChartData(
      "Potassium",
      0,
      Color(0xff90C7FE),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<List<ChartData>> data = [
      _nitrogenChartData,
      _phosphorusChartData,
      _potassiumChartData
    ];

    return BounceWithFadeAnimation(
      delay: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nutrient Level Summary",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "The nutrient readings recorded throughout the month",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
                ),
              ),
            ],
          ),
          const SizedBox(height: 44),
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
                      for (int i = 0; i < data.length; i++) ...[
                        SplineSeries<ChartData, String>(
                          color:
                              chartColorList[i % chartColorList.length].color,
                          width: 2,
                          dataSource: data[i],
                          xValueMapper: (ChartData d, _) => d.x,
                          yValueMapper: (ChartData d, _) => d.y,
                        ),
                        SplineAreaSeries<ChartData, String>(
                          gradient: LinearGradient(
                            colors: [
                              chartColorList[i % chartColorList.length]
                                  .color!
                                  .withOpacity(0.25),
                              chartColorList[i % chartColorList.length]
                                  .color!
                                  .withOpacity(0.15),
                              chartColorList[i % chartColorList.length]
                                  .color!
                                  .withOpacity(0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          dataSource: data[i],
                          xValueMapper: (ChartData d, _) => d.x,
                          yValueMapper: (ChartData d, _) => d.y,
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: chartColorList.map((item) {
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
    );
  }
}
