import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart' hide Threshold;
import 'package:flutter_vermicomposting/core/constants/constants.dart';
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
    if (!_initialized && widget.readingValueList.isNotEmpty) {
      currentValue = widget.readingValueList.first.y.toInt();
      _initialized = true;
    } else {
      currentValue = 0;
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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
          widget.readingValueList.isNotEmpty
              ? Align(
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
                )
              : SizedBox.shrink(),
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

SensorStatus getSensorStatus({
  required String type,
  required String? value,
}) {
  if (value == null) return SensorStatus.bad;

  double? numValue = double.tryParse(value);
  if (numValue == null) return SensorStatus.bad;

  switch (type) {
    case 'temperature':
      if (numValue >= 20 && numValue <= 28) return SensorStatus.good;
      if (numValue >= 10 && numValue < 15 || numValue > 30 && numValue <= 35) {
        return SensorStatus.fair;
      }
      return SensorStatus.bad;
    case 'humidity':
      if (numValue >= 70 && numValue <= 80) return SensorStatus.good;
      if ((numValue >= 60 && numValue < 70) ||
          (numValue > 80 && numValue <= 85)) {
        return SensorStatus.fair;
      }
      return SensorStatus.bad;
    case 'soilMoisture':
      if (numValue >= 65 && numValue <= 80) return SensorStatus.good;
      if ((numValue >= 60 && numValue < 65) ||
          (numValue > 80 && numValue <= 90)) {
        return SensorStatus.fair;
      }
      return SensorStatus.bad;
    case 'nitrogen':
      if (numValue >= 20 && numValue <= 40) return SensorStatus.good;
      if (numValue >= 15 && numValue < 20 || numValue > 40 && numValue <= 50) {
        return SensorStatus.fair;
      }
      return SensorStatus.bad;
    case 'phosphorus':
      if (numValue >= 10 && numValue <= 30) return SensorStatus.good;
      if ((numValue >= 5 && numValue < 10) ||
          (numValue > 30 && numValue <= 40)) {
        return SensorStatus.fair;
      }
      return SensorStatus.bad;
    case 'potassium':
      if (numValue >= 15 && numValue <= 30) return SensorStatus.good;
      if ((numValue >= 10 && numValue < 15) ||
          (numValue > 30 && numValue <= 35)) {
        return SensorStatus.fair;
      }
      return SensorStatus.bad;
    case 'compost':
      if (numValue >= 1 && numValue <= 10) return SensorStatus.good;
      return SensorStatus.fair;
    case 'vermijuice':
      if (numValue >= 1 && numValue <= 10) return SensorStatus.good;
      return SensorStatus.fair;
    case 'reservoir':
      if (numValue > 1) return SensorStatus.good;
      return SensorStatus.bad;
    default:
      return SensorStatus.bad;
  }
}
