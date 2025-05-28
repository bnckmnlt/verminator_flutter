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

class NutrientSummaryWidget extends StatefulWidget {
  const NutrientSummaryWidget({super.key});

  @override
  State<NutrientSummaryWidget> createState() => _NutrientSummaryWidgetState();
}

class _NutrientSummaryWidgetState extends State<NutrientSummaryWidget> {
  @override
  Widget build(BuildContext context) {
    final toastHelper = ToastHelper(context);

    return BounceWithFadeAnimation(
      delay: 1,
      child: BlocBuilder<SensorReadingBloc, SensorReadingState>(
        builder: (context, state) {
          if (state is SensorReadingLoading) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 124, 0, 0),
              child: const Loader(),
            );
          } else if (state is SensorReadingFailure) {
            toastHelper.show(
              title: "An error has occurred during retrieval",
              description: state.error,
              isError: true,
            );
          } else if (state is SensorReadingListSuccess) {
            Map<String, List<CompostReading>> npkReadingsByDay = {};

            for (var reading in state.list) {
              if (reading.layer == SystemLayer.compost) {
                final dateLabel = extractDay(reading.createdAt);
                final compost = reading.asCompostReading;
                if (compost == null) continue;
                npkReadingsByDay.putIfAbsent(dateLabel, () => []).add(compost);
              }
            }

            List<ChartData> nitrogenChartData = [];
            List<ChartData> phosphorusChartData = [];
            List<ChartData> potassiumChartData = [];

            npkReadingsByDay.forEach((day, dayReadings) {
              double avgNitrogen = dayReadings
                      .map((c) => c.npk.nitrogen.toDouble())
                      .fold(0.0, (sum, v) => sum + v) /
                  dayReadings.length;

              double avgPhosphorus = dayReadings
                      .map((c) => c.npk.phosphorus.toDouble())
                      .fold(0.0, (sum, v) => sum + v) /
                  dayReadings.length;

              double avgPotassium = dayReadings
                      .map((c) => c.npk.potassium.toDouble())
                      .fold(0.0, (sum, v) => sum + v) /
                  dayReadings.length;

              nitrogenChartData.add(ChartData(day, avgNitrogen));
              phosphorusChartData.add(ChartData(day, avgPhosphorus));
              potassiumChartData.add(ChartData(day, avgPotassium));
            });

            final List<SelectedChart> nutrientConditionCharts = [
              SelectedChart(
                  label: 'Nitrogen',
                  color: Color(0xff2563EB),
                  data: nitrogenChartData),
              SelectedChart(
                  label: 'Phosphorus',
                  color: Color(0xff3B86F7),
                  data: phosphorusChartData),
              SelectedChart(
                  label: 'Potassium',
                  color: Color(0xff90C7FE),
                  data: potassiumChartData),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Nutrient Level Summary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "The nutrient readings recorded throughout the month",
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(186),
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
                            for (int i = 0;
                                i < nutrientConditionCharts.length;
                                i++) ...[
                              SplineSeries<ChartData, String>(
                                color: nutrientConditionCharts[
                                        i % nutrientConditionCharts.length]
                                    .color,
                                width: 0,
                                dataSource: nutrientConditionCharts[i].data,
                                xValueMapper: (ChartData d, _) => d.x,
                                yValueMapper: (ChartData d, _) => d.y,
                              ),
                              SplineAreaSeries<ChartData, String>(
                                gradient: LinearGradient(
                                  colors: [
                                    nutrientConditionCharts[
                                            i % nutrientConditionCharts.length]
                                        .color
                                        .withOpacity(0.25),
                                    nutrientConditionCharts[
                                            i % nutrientConditionCharts.length]
                                        .color
                                        .withOpacity(0.15),
                                    nutrientConditionCharts[
                                            i % nutrientConditionCharts.length]
                                        .color
                                        .withOpacity(0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                dataSource: nutrientConditionCharts[i].data,
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
                  children: nutrientConditionCharts.map((item) {
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
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
