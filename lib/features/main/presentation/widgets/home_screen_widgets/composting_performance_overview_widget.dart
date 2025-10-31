import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/common/widgets/popup_selection_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/spline_area_chart_widget.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/food_waste_to_chartdata.dart';
import 'package:flutter_vermicomposting/core/utils/sensor_reading_to_daily_avg.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/home_screen.dart';
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
      "fruit_waste": foodWasteToChartData(
          FoodWasteClassname.fruitWaste, _foodWasteList, DateFormat.yMMMMd()),
      "vegetable_waste": foodWasteToChartData(FoodWasteClassname.vegetableWaste,
          _foodWasteList, DateFormat.yMMMMd()),
      "paper_cardboard": foodWasteToChartData(FoodWasteClassname.paperCardboard,
          _foodWasteList, DateFormat.yMMMMd()),
      "leaves_dry_material": foodWasteToChartData(
          FoodWasteClassname.leavesDryMaterial,
          _foodWasteList,
          DateFormat.yMMMMd()),
      "onion_garlic": foodWasteToChartData(
          FoodWasteClassname.onionGarlic, _foodWasteList, DateFormat.yMMMMd()),
      "spicy_material": foodWasteToChartData(FoodWasteClassname.spicyMaterial,
          _foodWasteList, DateFormat.yMMMMd()),
      "eggshells_coffee_grounds": foodWasteToChartData(
          FoodWasteClassname.eggshellsCoffeeGrounds,
          _foodWasteList,
          DateFormat.yMMMMd()),
      "grains_and_bread": foodWasteToChartData(
          FoodWasteClassname.grainsAndBread,
          _foodWasteList,
          DateFormat.yMMMMd()),
      "citrus_peels": foodWasteToChartData(
          FoodWasteClassname.citrusPeels, _foodWasteList, DateFormat.yMMMMd()),
      "meat_dairy": foodWasteToChartData(
          FoodWasteClassname.meatDairy, _foodWasteList, DateFormat.yMMMMd()),
      "foreign_material": foodWasteToChartData(
          FoodWasteClassname.foreignMaterial,
          _foodWasteList,
          DateFormat.yMMMMd()),
      "medical_waste": foodWasteToChartData(
          FoodWasteClassname.medicalWaste, _foodWasteList, DateFormat.yMMMMd()),
    };

    final chartsOverviewTabs = [
      ChartOverview(
        label: "Nutrient Level",
        description: "The nutrient readings recorded throughout the month",
        annotation: Constants().nutrientAnnotations,
        chartWidget: _nutrientLevelChartOverview(compostConditionCharts),
      ),
      ChartOverview(
        label: "Bedding Condition",
        description: "The bedding condition recorded throughout the month",
        annotation: Constants().beddingAnnotations,
        chartWidget: _beddingConditionChartOverview(
          beddingConditionCharts[selectedChart],
        ),
      ),
      ChartOverview(
        label: "Kitchen Waste Processed",
        description: "The kitchen waste processed throughout the month",
        annotation: Constants().kitchenWasteChartAnnotations,
        chartWidget: _kitchenWasteChartOverview(
          foodWasteChartData,
          Constants().kitchenWasteChartAnnotations,
        ),
      ),
    ];

    final dateRangeFilter = PopupSelectionWidget(
      label: Constants().dateRangeList[selectedDateRange],
      selectedFunction: (value) => setState(() {
        selectedDateRange = value;
      }),
      popupKeys: Constants().dateRangeList,
      isElevated: true,
    );

    final selection = PopupSelectionWidget(
      label: Constants().beddingAnnotations[selectedChart].label,
      selectedFunction: (value) => setState(() {
        selectedChart = value;
      }),
      popupKeys:
          Constants().beddingAnnotations.map((item) => item.label).toList(),
      trailingIcon: const Icon(
        FluentIcons.chevron_down_24_filled,
        size: 18,
      ),
    );

    return Column(
      spacing: 14,
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
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 248,
                            child: chartsOverviewTabs[chartOverviewCurrentTab]
                                .chartWidget,
                          ),
                        ),
                      ),
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
                                    fontFamily: "Zenbones Mono",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  chartsOverviewTabs[chartOverviewCurrentTab]
                                      .description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(164),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Wrap(
                                spacing: 14,
                                runSpacing: 8,
                                alignment: WrapAlignment.end,
                                children:
                                    chartsOverviewTabs[chartOverviewCurrentTab]
                                        .annotation!
                                        .map((item) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                      Text(
                                        item.label,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            )
                          ],
                        ),
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
      List<ChartDatasource> chartDatasourceList) {
    return SfCartesianChart(
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
        labelStyle: TextStyle(
          fontSize: 14,
          fontFamily: "Zenbones Mono",
          fontWeight: FontWeight.w600,
          letterSpacing: 0.025,
        ),
        axisLine: AxisLine(
          width: 0,
        ),
      ),
      series: chartDatasourceList.map((item) {
        return SplineAreaChartWidget.build(chartDatasource: item);
      }).toList(),
    );
  }

  Widget _beddingConditionChartOverview(ChartDatasource chartDatasource) {
    return SfCartesianChart(
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
        labelStyle: TextStyle(
          fontSize: 14,
          fontFamily: "Zenbones Mono",
          fontWeight: FontWeight.w600,
          letterSpacing: 0.025,
        ),
        axisLine: AxisLine(
          width: 0,
        ),
      ),
      series: <CartesianSeries>[
        SplineAreaChartWidget.build(chartDatasource: chartDatasource),
      ],
    );
  }

  Widget _kitchenWasteChartOverview(
      Map<String, List<ChartData>> foodWasteChartData,
      List<AnnotationData> kitchenWasteChartAnnotations) {
    return SfCartesianChart(
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
        ...foodWasteChartData.entries.toList().asMap().entries.map((item) {
          final int index = item.key;
          final List<ChartData> data = item.value.value;

          String groupName;
          if (index == 0) {
            groupName = "Valid";
          } else if (index == 1) {
            groupName = "Controlled";
          } else {
            groupName = "Invalid";
          }

          return StackedColumnSeries<ChartData, String>(
            groupName: groupName,
            dataSource: data,
            color: index < kitchenWasteChartAnnotations.length
                ? kitchenWasteChartAnnotations[index].color
                : Colors.grey,
            sortingOrder: SortingOrder.descending,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              showCumulativeValues: true,
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.025,
              ),
            ),
            xValueMapper: (ChartData d, _) => d.x,
            yValueMapper: (ChartData d, _) => d.y,
          );
        }),
      ],
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
      datasource: sensorReadingToDailyAvg<T>(
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
  final List<ChartData> datasource;
  final Color chartColor;

  ChartDatasource({
    required this.datasource,
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
