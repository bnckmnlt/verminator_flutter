import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart' hide Threshold;
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/sensor_readings_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorReadingCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<ChartData> readingValueList;
  final int realtimeValue;

  const SensorReadingCard({
    super.key,
    required this.item,
    required this.readingValueList,
    required this.realtimeValue,
  });

  @override
  State<SensorReadingCard> createState() => _SensorReadingCardState();
}

class _SensorReadingCardState extends State<SensorReadingCard> {
  late int currentValue;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      currentValue = widget.readingValueList.first.y.toInt();
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(covariant SensorReadingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_initialized && oldWidget.realtimeValue != widget.realtimeValue) {
      setState(() {
        currentValue = widget.realtimeValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackballBehavior = TrackballBehavior(
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
            children: [
              Text(
                widget.item['reading_key'].toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Zenbones Mono",
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(widget.item["icon"], size: 18),
            ],
          ),
          Align(
            alignment: const Alignment(0, -0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getSensorValueIcon(getSensorStatus(
                  type: widget.item['reading_key'],
                  value: currentValue.toString(),
                )),
                Text(
                  "$currentValue${widget.item["unit"]}",
                  style: GoogleFonts.inter(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.025,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 64,
              child: SfCartesianChart(
                trackballBehavior: trackballBehavior,
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(isVisible: false),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Icon getSensorValueIcon(SensorStatus status) {
  switch (status) {
    case SensorStatus.bad:
      return const Icon(
        FluentIcons.warning_24_filled,
        color: Colors.orange,
      );
    case SensorStatus.good:
      return const Icon(
        FluentIcons.checkmark_circle_24_filled,
        color: Colors.greenAccent,
      );
    default:
      return const Icon(
        FluentIcons.subtract_circle_24_filled,
        color: Colors.white,
      );
  }
}
