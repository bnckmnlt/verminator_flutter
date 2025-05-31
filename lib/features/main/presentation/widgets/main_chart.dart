import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainChart extends StatefulWidget {
  final List<ChartData> sensorChart;
  final double chartSize;
  final bool showAxisLine;
  final double mainWidth;
  final Color color;

  const MainChart({
    super.key,
    required this.sensorChart,
    required this.chartSize,
    this.showAxisLine = false,
    this.mainWidth = 0.0,
    required this.color,
  });

  @override
  State<MainChart> createState() => _MainChartState();
}

class _MainChartState extends State<MainChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.chartSize,
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
        primaryYAxis: NumericAxis(
          isVisible: widget.showAxisLine ?? false,
          axisLine: AxisLine(width: 0),
          majorGridLines: MajorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
        ),
        series: <CartesianSeries<ChartData, String>>[
          SplineSeries<ChartData, String>(
            color: widget.color,
            width: widget.mainWidth,
            dataSource: widget.sensorChart,
            xValueMapper: (ChartData d, _) => d.x,
            yValueMapper: (ChartData d, _) => d.y,
          ),
          SplineAreaSeries<ChartData, String>(
            gradient: LinearGradient(
              colors: [
                widget.color.withAlpha(64),
                widget.color.withAlpha(38),
                widget.color.withAlpha(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            dataSource: widget.sensorChart,
            xValueMapper: (ChartData d, _) => d.x,
            yValueMapper: (ChartData d, _) => d.y,
          ),
        ],
      ),
    );
  }
}
