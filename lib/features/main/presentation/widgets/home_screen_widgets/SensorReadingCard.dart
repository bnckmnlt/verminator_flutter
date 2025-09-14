import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../core/constants/constants.dart';

class SensorReadingCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<ChartData> readingValueList;

  const SensorReadingCard({
    super.key,
    required this.item,
    required this.readingValueList,
  });

  @override
  State<SensorReadingCard> createState() => _SensorReadingCardState();
}

class _SensorReadingCardState extends State<SensorReadingCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TrackballBehavior trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipSettings: InteractiveTooltip(
        enable: true,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        format: 'point.y${widget.item["unit"]}',
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );

    int currentValue = widget.readingValueList.first.y.toInt();

    return Container(
      height: 324,
      width: 324,
      padding: EdgeInsets.symmetric(vertical: 34, horizontal: 24),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainer,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.item['reading_key'].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                widget.item["icon"],
                size: 24,
              )
            ],
          ),
          Align(
            alignment: Alignment(0, -0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.arrow_trending_24_filled,
                  grade: 100,
                  size: 38,
                  color: Colors.greenAccent.shade700,
                ),
                Text(
                  "$currentValue ${widget.item["unit"]}",
                  style: GoogleFonts.inter(
                    fontSize: 58,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 124,
              child: SfCartesianChart(
                trackballBehavior: trackballBehavior,
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  isVisible: false,
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                ),
                series: <CartesianSeries>[
                  AreaSeries<ChartData, String>(
                    sortingOrder: SortingOrder.ascending,
                    dataSource: widget.readingValueList,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Colors.white,
                    borderColor: Colors.white,
                    borderWidth: 3,
                    borderDrawMode: BorderDrawMode.all,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white54.withAlpha(58),
                        Colors.white54.withAlpha(24),
                        Colors.white54.withAlpha(0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
