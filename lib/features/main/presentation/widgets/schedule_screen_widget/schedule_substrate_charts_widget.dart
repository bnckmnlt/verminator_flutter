import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/common/widgets/spline_area_chart_widget.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/sensor_reading_to_daily_avg.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/home_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/composting_performance_overview_widget.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ScheduleSubstrateChartsWidget extends StatefulWidget {
  final List<SensorReading> sensorReadingList;

  const ScheduleSubstrateChartsWidget({
    super.key,
    required this.sensorReadingList,
  });

  @override
  State<ScheduleSubstrateChartsWidget> createState() =>
      _ScheduleSubstrateChartsWidgetState();
}

class _ScheduleSubstrateChartsWidgetState
    extends State<ScheduleSubstrateChartsWidget> {
  late List<SensorReading> _sensorReadingList;

  bool _sidebarActive = false;
  int _selectedChart = 0;
  String _currentChartLabel = "Temperature";
  int _selectedTime = 0;

  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    super.initState();

    _sensorReadingList = widget.sensorReadingList;

    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
      markerSettings: const TrackballMarkerSettings(
        markerVisibility: TrackballVisibilityMode.visible,
        height: 6,
        width: 6,
      ),
      builder: (BuildContext context, TrackballDetails trackballDetails) {
        final dateTime = DateTime.parse(trackballDetails.point!.x.trim());
        final formatted = ChartAxisConfig._formatLabel(
            dateTime, getTimeGrouping(_selectedTime));

        return Container(
          height: 72,
          width: 186,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatted.toString(),
                style: GoogleFonts.spaceMono(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Text(
                        _currentChartLabel,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(164),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                    child: Text(
                      trackballDetails.point!.y!.toStringAsFixed(2),
                      style: GoogleFonts.spaceMono(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: chartColumns()),
        if (_sidebarActive)
          Expanded(flex: 1, child: detailsSideBar())
              .animate()
              .fade(duration: 700.ms, curve: Curves.easeOut)
              .slideX(
                begin: 0.15,
                end: 0.0,
                duration: 750.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(
                begin: const Offset(0.98, 0.98),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
      ],
    );
  }

  Widget chartColumns() {
    return Column(
      children: [
        _buildChartHeader(),
        Expanded(flex: 4, child: _buildCharts()),
      ],
    );
  }

  Widget detailsSideBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    TextStyle parameterTextStyle() {
      return TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 0.025,
      );
    }

    TextStyle parameterTextStyleMuted() {
      return TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
        letterSpacing: 0.025,
        height: 1.1,
      );
    }

    String getChartLabel(int index) {
      const labels = [
        'Temperature',
        'Humidity',
        'Soil Moisture',
        'Nitrogen',
        'Phosphorus',
        'Potassium',
      ];
      return labels[index];
    }

    TextStyle dropdownButtonTextStyle() {
      return GoogleFonts.spaceMono(
        fontSize: 14,
        letterSpacing: 0.025,
      );
    }

    return Container(
      height: 68,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(18, 8, 64, 8),
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Constants.parametersToMonitorList[_selectedChart]
                      ['icon']),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getChartLabel(_selectedChart),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: parameterTextStyle(),
                    ),
                    Text(
                      "Substrate Condition",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: parameterTextStyleMuted(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 36,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButton<int>(
                      value: _selectedChart,
                      underline: SizedBox.shrink(),
                      icon: Icon(Icons.unfold_more, size: 16),
                      borderRadius: BorderRadius.circular(6),
                      items: List.generate(
                        6,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(
                            getChartLabel(index),
                            style: dropdownButtonTextStyle(),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _selectedChart = value!);
                      },
                    ),
                  ),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(4),
                    borderColor:
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                    selectedBorderColor: Theme.of(context).colorScheme.outline,
                    color: Theme.of(context).colorScheme.onSurface,
                    selectedColor: Theme.of(context).colorScheme.onSurface,
                    fillColor: Colors.transparent,
                    splashColor:
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                    highlightColor: Theme.of(context).colorScheme.onSurface,
                    borderWidth: 1.5,
                    constraints: BoxConstraints(minWidth: 48, minHeight: 32),
                    onPressed: (index) => setState(() => _selectedTime = index),
                    isSelected: [
                      _selectedTime == 0,
                      _selectedTime == 1,
                      _selectedTime == 2,
                      _selectedTime == 3,
                      _selectedTime == 4,
                    ],
                    children: ["1D", "7D", "1M", "1Y", "All"]
                        .map((item) => Text(
                              item,
                              style: GoogleFonts.spaceMono(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _sidebarActive = !_sidebarActive;
            }),
            icon: Icon(
              !_sidebarActive
                  ? FluentIcons.full_screen_minimize_24_filled
                  : FluentIcons.full_screen_maximize_24_filled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    final beddingMetrics = [
      (
        selector: (BeddingReading r) => r.temperature.value,
        color: Colors.white.toARGB32()
      ),
      (
        selector: (BeddingReading r) => r.humidity.value,
        color: Colors.white.toARGB32()
      ),
      (
        selector: (BeddingReading r) => r.soilMoisture.value,
        color: Colors.white.toARGB32()
      ),
    ];

    final compostMetrics = [
      (
        selector: (CompostReading r) => r.npk.nitrogen,
        color: Colors.white.toARGB32()
      ),
      (
        selector: (CompostReading r) => r.npk.phosphorus,
        color: Colors.white.toARGB32()
      ),
      (
        selector: (CompostReading r) => r.npk.potassium,
        color: Colors.white.toARGB32()
      ),
    ];

    final beddingConditionCharts = beddingMetrics
        .map(
          (m) => makeDatasource<BeddingReading>(
            SystemLayer.bedding,
            m.selector,
            getDateRange(_selectedTime),
            m.color,
            _sensorReadingList,
          ),
        )
        .toList();

    final compostConditionCharts = compostMetrics
        .map(
          (m) => makeDatasource<CompostReading>(
            SystemLayer.compost,
            m.selector,
            getDateRange(_selectedTime),
            m.color,
            _sensorReadingList,
          ),
        )
        .toList();

    return _chartOverview(
      chartDatasources: [...beddingConditionCharts, ...compostConditionCharts],
      selectedIndex: _selectedChart,
    );
  }

  Widget _chartOverview({
    required List<ChartDatasource> chartDatasources,
    required int selectedIndex,
  }) {
    final chartConfigs = [
      {'label': 'Temperature', 'min': 20.0, 'max': 35.0, 'unit': '°C'},
      {'label': 'Humidity', 'min': 50.0, 'max': 100.0, 'unit': '%'},
      {'label': 'Soil Moisture', 'min': 50.0, 'max': 100.0, 'unit': '%'},
      {'label': 'Nitrogen', 'min': 0.0, 'max': 30.0, 'unit': '%'},
      {'label': 'Phosphorus', 'min': 0.0, 'max': 30.0, 'unit': '%'},
      {'label': 'Potassium', 'min': 0.0, 'max': 30.0, 'unit': '%'},
    ];

    final config = chartConfigs[selectedIndex];

    _currentChartLabel = config['label'] as String;

    return SfCartesianChart(
      trackballBehavior: _trackballBehavior,
      enableSideBySideSeriesPlacement: false,
      enableAxisAnimation: true,
      margin: EdgeInsets.zero,
      plotAreaBorderWidth: 0,
      plotAreaBorderColor: Colors.transparent,
      plotAreaBackgroundColor: Colors.transparent,
      primaryXAxis: ChartAxisConfig.xAxis(
        context,
        grouping: getTimeGrouping(_selectedTime),
      ),
      primaryYAxis: ChartAxisConfig.yAxis(
        context,
        min: config['min'] as double,
        max: config['max'] as double,
        unit: config['unit'] as String,
      ),
      series: [
        SplineAreaChartWidget.build(
          chartDatasource: chartDatasources[selectedIndex],
        ),
      ],
    );
  }
}

class ChartAxisConfig {
  static CategoryAxis xAxis(BuildContext context,
      {required TimeGrouping grouping}) {
    return CategoryAxis(
      isVisible: true,
      maximumLabels: _getMaxLabels(grouping),
      labelIntersectAction: AxisLabelIntersectAction.hide,
      interval: _getInterval(grouping),
      axisLine: AxisLine(
        width: 1,
        color: Theme.of(context).colorScheme.outline.withAlpha(100),
      ),
      borderWidth: 0,
      borderColor: Colors.transparent,
      labelPlacement: LabelPlacement.onTicks,
      edgeLabelPlacement: EdgeLabelPlacement.shift,
      labelPosition: ChartDataLabelPosition.outside,
      labelRotation: 0,
      axisLabelFormatter: (AxisLabelRenderDetails args) {
        try {
          final dateTime = DateTime.parse(args.text.trim());
          final formatted = _formatLabel(dateTime, grouping);

          return ChartAxisLabel(
            '\n$formatted\n',
            GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            ),
          );
        } catch (e) {
          return ChartAxisLabel(
            '\n${args.text}\n',
            GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            ),
          );
        }
      },
      plotOffset: 0,
      majorGridLines: MajorGridLines(width: 0),
      majorTickLines: MajorTickLines(width: 0),
    );
  }

  static NumericAxis yAxis(
    BuildContext context, {
    required double min,
    required double max,
    required String unit,
  }) {
    return NumericAxis(
      minimum: min,
      maximum: max,
      interval: (max - min) / 5,
      opposedPosition: true,
      labelPosition: ChartDataLabelPosition.inside,
      labelAlignment: LabelAlignment.end,
      edgeLabelPlacement: EdgeLabelPlacement.shift,
      plotOffset: 32,
      labelFormat: '{value}$unit\t\t\t',
      labelStyle: GoogleFonts.spaceMono(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.025,
        height: 1.8,
      ),
      axisLine: AxisLine(width: 0),
      borderWidth: 0,
      tickPosition: TickPosition.inside,
      minorTickLines: MinorTickLines(width: 0),
      majorTickLines: MajorTickLines(width: 0),
      majorGridLines: MajorGridLines(
        width: 1,
        color:
            Theme.of(context).colorScheme.surfaceContainerHigh.withAlpha(100),
        dashArray: [5, 5],
      ),
    );
  }

  static double _getInterval(TimeGrouping grouping) {
    return switch (grouping) {
      TimeGrouping.last24Hours => 2,
      TimeGrouping.last7Days => 1,
      TimeGrouping.last30Days => 3,
      TimeGrouping.annual => 1,
      TimeGrouping.all => 2,
    };
  }

  static int _getMaxLabels(TimeGrouping grouping) {
    return switch (grouping) {
      TimeGrouping.last24Hours => 8,
      TimeGrouping.last7Days => 7,
      TimeGrouping.last30Days => 2,
      TimeGrouping.annual => 12,
      TimeGrouping.all => 10,
    };
  }

  static String _formatLabel(DateTime dateTime, TimeGrouping grouping) {
    return switch (grouping) {
      TimeGrouping.last24Hours => _formatTime(dateTime),
      TimeGrouping.last7Days => DateFormat('E').format(dateTime),
      TimeGrouping.last30Days => DateFormat('M/d').format(dateTime),
      TimeGrouping.annual => DateFormat('MMM').format(dateTime),
      TimeGrouping.all => DateFormat('MMM yy').format(dateTime),
    };
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour$period';
  }
}
