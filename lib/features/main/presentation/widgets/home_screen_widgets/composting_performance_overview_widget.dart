import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/food_waste_to_chartdata.dart';
import 'package:flutter_vermicomposting/core/utils/sensor_reading_to_daily_avg.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/test_screen.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CompostingPerformanceOverviewWidget extends StatefulWidget {
  final List<SensorReading> sensorReadingList;
  final List<FoodWaste> foodWasteList;

  const CompostingPerformanceOverviewWidget({
    super.key,
    required this.sensorReadingList,
    required this.foodWasteList,
  });

  @override
  State<CompostingPerformanceOverviewWidget> createState() =>
      _CompostingPerformanceOverviewWidgetState();
}

class _CompostingPerformanceOverviewWidgetState
    extends State<CompostingPerformanceOverviewWidget> {
  Key animationKey = UniqueKey();

  late List<SensorReading> _sensorReadingList;
  late List<FoodWaste> _foodWasteList;

  int chartOverviewCurrentTab = 0;
  int selectedChart = 0;
  int selectedDateRange = 1;

  @override
  void initState() {
    _sensorReadingList = widget.sensorReadingList;
    _foodWasteList = widget.foodWasteList;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final beddingMetrics = [
      (selector: (BeddingReading r) => r.temperature.value, color: 0xff2563EB),
      (selector: (BeddingReading r) => r.humidity.value, color: 0xff3B86F7),
      (selector: (BeddingReading r) => r.soilMoisture.value, color: 0xff90C7FE),
    ];

    final compostMetrics = [
      (selector: (CompostReading r) => r.npk.nitrogen, color: 0xff2563EB),
      (selector: (CompostReading r) => r.npk.phosphorus, color: 0xff3B86F7),
      (selector: (CompostReading r) => r.npk.potassium, color: 0xff90C7FE),
    ];

    final beddingConditionCharts = beddingMetrics
        .map((m) => _makeDatasource<BeddingReading>(
              SystemLayer.bedding,
              m.selector,
              getDateRange(selectedDateRange),
              m.color,
            ))
        .toList();

    final compostConditionCharts = compostMetrics
        .map((m) => _makeDatasource<CompostReading>(
              SystemLayer.compost,
              m.selector,
              getDateRange(selectedDateRange),
              m.color,
            ))
        .toList();

    final Map<String, List<ChartData>> foodWasteChartData = {
      "fruit": foodWasteToChartData(
          FoodWasteClassname.fruit, _foodWasteList, DateFormat.yMMMMd()),
      "vegetable": foodWasteToChartData(
          FoodWasteClassname.vegetable, _foodWasteList, DateFormat.yMMMMd()),
      "grains": foodWasteToChartData(
          FoodWasteClassname.grains, _foodWasteList, DateFormat.yMMMMd()),
      "citrus": foodWasteToChartData(
          FoodWasteClassname.citrus, _foodWasteList, DateFormat.yMMMMd()),
      "meat": foodWasteToChartData(
          FoodWasteClassname.meat, _foodWasteList, DateFormat.yMMMMd()),
      "foreign": foodWasteToChartData(
          FoodWasteClassname.foreign, _foodWasteList, DateFormat.yMMMMd()),
    };

    final kitchenWasteChartAnnotations = [
      AnnotationData("Fruit", const Color(0xFF2563EB)),
      AnnotationData("Vegetable", const Color(0xFF3B82F6)),
      AnnotationData("Grains", const Color(0xFF93C5FD)),
      AnnotationData("Citrus", const Color(0xFFDC2626)),
      AnnotationData("Meat", const Color(0xFFF87171)),
      AnnotationData("Foreign", const Color(0xFFFECACA)),
    ];

    final chartsOverviewTabs = [
      ChartOverview(
        label: "Nutrient Level",
        description: "The nutrient readings recorded throughout the month",
        annotation: [
          AnnotationData("Nitrogen", const Color(0xff2563EB)),
          AnnotationData("Phosphorus", const Color(0xff3B86F7)),
          AnnotationData("Potassium", const Color(0xff90C7FE)),
        ],
        chartWidget: _nutrientLevelChartOverview(compostConditionCharts),
      ),
      ChartOverview(
        label: "Bedding Condition",
        description: "The bedding condition recorded throughout the month",
        annotation: [
          AnnotationData("Temperature", Color(0xff2563EB)),
          AnnotationData("Humidity", Color(0xff3B86F7)),
          AnnotationData("Soil Moisture", Color(0xff90C7FE)),
        ],
        chartWidget: _beddingConditionChartOverview(
          beddingConditionCharts[selectedChart],
        ),
      ),
      ChartOverview(
        label: "Kitchen Waste Processed",
        description: "The kitchen waste processed throughout the month",
        annotation: kitchenWasteChartAnnotations,
        chartWidget: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 248,
            child: SfCartesianChart(
              enableAxisAnimation: true,
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                borderWidth: 0,
                borderColor: Colors.transparent,
                labelPlacement: LabelPlacement.onTicks,
                edgeLabelPlacement: EdgeLabelPlacement.hide,
                majorGridLines: MajorGridLines(width: 0),
                majorTickLines: MajorTickLines(width: 0),
                labelPosition: ChartDataLabelPosition.inside,
                labelAlignment: LabelAlignment.end,
                tickPosition: TickPosition.inside,
                plotOffset: 0,
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.025,
                ),
                axisLine: AxisLine(
                  width: 0,
                ),
              ),
              primaryYAxis: NumericAxis(
                edgeLabelPlacement: EdgeLabelPlacement.hide,
                labelPosition: ChartDataLabelPosition.inside,
                labelAlignment: LabelAlignment.center,
                tickPosition: TickPosition.inside,
                minorTickLines: MinorTickLines(width: 0),
                majorTickLines: MajorTickLines(width: 0),
                borderWidth: 0,
                plotOffset: 0,
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.025,
                ),
                axisLine: AxisLine(
                  width: 0,
                ),
              ),
              series: <CartesianSeries>[
                ...foodWasteChartData.entries
                    .toList()
                    .asMap()
                    .entries
                    .map((item) {
                  final int index = item.key;
                  final List<ChartData> data = item.value.value;

                  return StackedColumnSeries<ChartData, String>(
                    groupName: index < 2 ? "Valid" : "Invalid",
                    dataSource: data,
                    color: kitchenWasteChartAnnotations[index].color,
                    sortingOrder: SortingOrder.descending,
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        showCumulativeValues: true,
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.025,
                        )),
                    xValueMapper: (ChartData d, _) => d.x,
                    yValueMapper: (ChartData d, _) => d.y,
                  );
                })
              ],
            ),
          ),
        ),
      ),
    ];

    Widget dateRangeFilter = PopupMenuButton(
      onSelected: (value) => setState(() {
        selectedDateRange = value;
      }),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 0,
          child: Text('24 hours'),
        ),
        PopupMenuItem(
          value: 1,
          child: Text('1 week'),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('1 month'),
        ),
        PopupMenuItem(
          value: 3,
          child: Text('1 year'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(32),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
        child: Text(
          ["24 hours", "1 week", "1 month", "1 year"][selectedDateRange],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    Widget selection = PopupMenuButton(
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
          spacing: 6,
          children: [
            Text(
              chartsOverviewTabs[chartOverviewCurrentTab]
                  .annotation![selectedChart]
                  .label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              FluentIcons.chevron_down_24_filled,
              size: 18,
            ),
          ],
        ),
      ),
    );

    return Column(
      spacing: 18,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Composting Performance Overview",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 470,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLow
                      .withAlpha(124),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    width: 2,
                  )),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: BounceWithFadeAnimation(
                  key: animationKey,
                  delay: 1,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 24,
                        right: 24,
                        child: Column(
                          spacing: 32,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 4,
                              children: [
                                Text(
                                  chartsOverviewTabs[chartOverviewCurrentTab]
                                      .label,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  chartsOverviewTabs[chartOverviewCurrentTab]
                                      .description,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(186),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 14,
                              children:
                                  chartsOverviewTabs[chartOverviewCurrentTab]
                                      .annotation!
                                      .map((item) {
                                return Row(
                                  spacing: 8,
                                  children: [
                                    Container(
                                      height: 12,
                                      width: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: item.color,
                                      ),
                                    ),
                                    Text(item.label),
                                  ],
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      ),
                      Dismissible(
                        key: UniqueKey(),
                        onDismissed: (chartOverviewCurrentTab >= 0 &&
                                chartOverviewCurrentTab < 3)
                            ? (DismissDirection direction) {
                                if (direction == DismissDirection.endToStart) {
                                  navigateNextChart();
                                } else if (direction ==
                                    DismissDirection.startToEnd) {
                                  navigatePreviousChart();
                                }
                              }
                            : (direction) {},
                        child: chartsOverviewTabs[chartOverviewCurrentTab]
                            .chartWidget,
                      ),
                      Positioned(
                        top: 24,
                        left: 24,
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            dateRangeFilter,
                            if (chartOverviewCurrentTab == 1) selection,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _nutrientLevelChartOverview(
      List<ChartDatasource> nutrientLevelDatasources) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 248,
        child: SfCartesianChart(
          margin: const EdgeInsets.all(0),
          plotAreaBorderWidth: 0,
          plotAreaBackgroundColor: Colors.transparent,
          primaryXAxis: CategoryAxis(
            axisLine: AxisLine(width: 0),
            borderWidth: 0,
            borderColor: Colors.transparent,
            labelPlacement: LabelPlacement.onTicks,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            majorGridLines: MajorGridLines(width: 0),
            majorTickLines: MajorTickLines(width: 0),
            isVisible: false,
          ),
          primaryYAxis: NumericAxis(
            labelPosition: ChartDataLabelPosition.inside,
            labelAlignment: LabelAlignment.end,
            tickPosition: TickPosition.inside,
            minorTickLines: MinorTickLines(width: 0),
            majorTickLines: MajorTickLines(width: 0),
            borderWidth: 0,
            plotOffset: 0,
            labelFormat: ' {value}%',
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.025,
            ),
            axisLine: AxisLine(
              width: 0,
            ),
          ),
          series: <CartesianSeries>[
            ...nutrientLevelDatasources.map((item) {
              return SplineAreaSeries<ChartData, String>(
                sortingOrder: SortingOrder.ascending,
                dataSource: item.chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: Colors.white,
                borderColor: Colors.white,
                borderWidth: 4,
                borderDrawMode: BorderDrawMode.top,
                gradient: LinearGradient(
                  colors: [
                    item.chartColor!.withAlpha(58),
                    item.chartColor!.withAlpha(24),
                    item.chartColor!.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                markerSettings: MarkerSettings(
                  borderWidth: 1.5,
                  borderColor: Colors.white,
                  width: 12,
                  height: 12,
                  isVisible: true,
                  shape: DataMarkerType.circle,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _beddingConditionChartOverview(ChartDatasource datasource) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 248,
        child: SfCartesianChart(
          enableAxisAnimation: true,
          margin: EdgeInsets.zero,
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            axisLine: AxisLine(width: 0),
            borderWidth: 0,
            borderColor: Colors.transparent,
            labelPlacement: LabelPlacement.onTicks,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            majorGridLines: MajorGridLines(width: 0),
            majorTickLines: MajorTickLines(width: 0),
            isVisible: false,
          ),
          primaryYAxis: NumericAxis(
            edgeLabelPlacement: EdgeLabelPlacement.hide,
            minimum: selectedChart == 0 ? 20 : 0,
            maximum: selectedChart == 0 ? 45 : 120,
            labelPosition: ChartDataLabelPosition.inside,
            labelAlignment: LabelAlignment.end,
            tickPosition: TickPosition.inside,
            minorTickLines: MinorTickLines(width: 0),
            majorTickLines: MajorTickLines(width: 0),
            borderWidth: 0,
            plotOffset: 0,
            labelFormat: ' {value}${selectedChart == 0 ? "°C" : "%"}',
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.025,
            ),
            axisLine: AxisLine(
              width: 0,
            ),
          ),
          series: <CartesianSeries>[
            SplineAreaSeries<ChartData, String>(
              sortingOrder: SortingOrder.ascending,
              dataSource: datasource.chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: Colors.white,
              borderColor: Colors.white,
              borderWidth: 4,
              borderDrawMode: BorderDrawMode.top,
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withAlpha(58),
                  Colors.blueAccent.withAlpha(24),
                  Colors.blueAccent.withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              markerSettings: MarkerSettings(
                borderWidth: 1.5,
                borderColor: Colors.white,
                width: 12,
                height: 12,
                isVisible: true,
                shape: DataMarkerType.circle,
              ),
            )
          ],
        ),
      ),
    );
  }

  void navigateNextChart() {
    if (chartOverviewCurrentTab < 2) {
      setState(() {
        chartOverviewCurrentTab++;
      });
    } else {
      setState(() {
        chartOverviewCurrentTab = 0;
      });
    }
    refreshAnimations();
  }

  void navigatePreviousChart() {
    if (chartOverviewCurrentTab != 0) {
      setState(() {
        chartOverviewCurrentTab--;
      });
    } else {
      setState(() {
        chartOverviewCurrentTab = 2;
      });
    }
    refreshAnimations();
  }

  void refreshAnimations() {
    setState(() {
      animationKey = UniqueKey();
    });
  }

  ChartDatasource _makeDatasource<T>(
    SystemLayer layer,
    num Function(T) selector,
    int limit,
    int color,
  ) {
    return ChartDatasource(
      chartData: sensorReadingToDailyAvg<T>(
        _sensorReadingList,
        layer,
        selector,
        limit: limit,
      ),
      chartColor: Color(color),
    );
  }
}

class ChartOverview {
  final String label;
  final String description;
  final List<AnnotationData>? annotation;
  final List<ChartData>? singleData;
  final Widget chartWidget;

  ChartOverview({
    required this.label,
    required this.description,
    this.annotation,
    this.singleData,
    required this.chartWidget,
  });
}

class ChartDatasource {
  final List<ChartData> chartData;
  final Color? chartColor;

  ChartDatasource({
    required this.chartData,
    required this.chartColor,
  });
}

class AnnotationData {
  final String label;
  final Color? color;

  AnnotationData(
    this.label,
    this.color,
  );
}
