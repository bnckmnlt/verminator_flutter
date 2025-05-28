import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// TODO: [✅] DONEEEEEE

class BeddingConditionWidget extends StatefulWidget {
  const BeddingConditionWidget({super.key});

  @override
  State<BeddingConditionWidget> createState() => _BeddingConditionWidgetState();
}

class _BeddingConditionWidgetState extends State<BeddingConditionWidget> {
  int selectedChart = 0;

  @override
  Widget build(BuildContext context) {
    final toastHelper = ToastHelper(context);

    return BounceWithFadeAnimation(
        delay: 1,
        child: BlocBuilder<SensorReadingBloc, SensorReadingState>(
            builder: (context, state) {
          if (state is SensorReadingLoading) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(0, 124, 0, 0),
              child: Loader(),
            );
          } else if (state is SensorReadingFailure) {
            toastHelper.show(
              title: "An error has occurred during retrieval",
              description: state.error,
              isError: true,
            );
          } else if (state is SensorReadingListSuccess) {
            Map<String, List<BeddingReading>> readingsByDay = {};

            for (var reading in state.list) {
              if (reading.layer == SystemLayer.bedding) {
                final dateLabel = extractDay(reading.createdAt);
                final bedding = reading.asBeddingReading;
                if (bedding == null) continue;
                readingsByDay.putIfAbsent(dateLabel, () => []).add(bedding);
              }
            }

            List<ChartData> tempChartData = [];
            List<ChartData> humidityChartData = [];
            List<ChartData> soilMoistureChartData = [];

            readingsByDay.forEach((day, dayReadings) {
              double avgTemp = dayReadings
                      .map((b) => b.temperature.value.toDouble())
                      .fold(0.0, (sum, v) => sum + v) /
                  dayReadings.length;

              double avgHumidity = dayReadings
                      .map((b) => b.humidity.value.toDouble())
                      .fold(0.0, (sum, v) => sum + v) /
                  dayReadings.length;

              double avgSoilMoisture = dayReadings
                      .map((b) => b.soilMoisture.value.toDouble())
                      .fold(0.0, (sum, v) => sum + v) /
                  dayReadings.length;

              tempChartData.add(ChartData(day, avgTemp));
              humidityChartData.add(ChartData(day, avgHumidity));
              soilMoistureChartData.add(ChartData(day, avgSoilMoisture));
            });

            final List<SelectedChart> beddingConditionCharts = [
              SelectedChart(
                  label: 'Temperature',
                  color: Color(0xff2563EB),
                  data: tempChartData),
              SelectedChart(
                  label: 'Humidity',
                  color: Color(0xff3B86F7),
                  data: humidityChartData),
              SelectedChart(
                  label: 'Soil Moisture',
                  color: Color(0xff90C7FE),
                  data: soilMoistureChartData),
            ];

            return Column(
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(186),
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
                              color:
                                  beddingConditionCharts[selectedChart].color,
                              width: 0,
                              dataSource:
                                  beddingConditionCharts[selectedChart].data,
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
                              dataSource:
                                  beddingConditionCharts[selectedChart].data,
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
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
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
            );
          }

          return const SizedBox();
        }));
  }
}
