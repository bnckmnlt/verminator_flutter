import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/composting_performance_overview_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SplineAreaChartWidget {
  static SplineAreaSeries build({
    required ChartDatasource chartDatasource,
  }) {
    return SplineAreaSeries<ChartData, String>(
      dataSource: chartDatasource.datasource,
      sortingOrder: SortingOrder.descending,
      color: Colors.white,
      borderWidth: 2,
      borderColor: Colors.white,
      borderDrawMode: BorderDrawMode.top,
      gradient: LinearGradient(
        colors: [
          chartDatasource.chartColor.withAlpha(58),
          chartDatasource.chartColor.withAlpha(24),
          chartDatasource.chartColor.withAlpha(0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      markerSettings: const MarkerSettings(
        isVisible: true,
        height: 10,
        width: 10,
        borderWidth: 1.5,
        borderColor: Colors.white,
        shape: DataMarkerType.circle,
      ),
      xValueMapper: (ChartData data, _) => data.x,
      yValueMapper: (ChartData data, _) => data.y,
    );
  }
}
