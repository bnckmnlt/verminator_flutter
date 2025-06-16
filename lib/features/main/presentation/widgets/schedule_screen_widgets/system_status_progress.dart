import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SystemStatusProgress extends StatefulWidget {
  final int scheduleId;

  const SystemStatusProgress({
    super.key,
    required this.scheduleId,
  });

  @override
  State<SystemStatusProgress> createState() => _SystemStatusProgressState();
}

class _SystemStatusProgressState extends State<SystemStatusProgress> {
  final GlobalKey myKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<StatusRecordBloc>().add(StatusRecordList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatusRecordBloc, StatusRecordState>(
      builder: (context, state) {
        if (state is StatusRecordLoading) {
          return const Center(child: Loader());
        }

        if (state is StatusRecordFailure) {
          return EmptyDisplayWidget(
            description: state.error,
            title: 'An error has occurred',
            icon: FluentIcons.cloud_error_24_regular,
          );
        }

        if (state is StatusRecordListSuccess) {
          final statusList = state.statusRecordList
              .where((status) => status.scheduleId == widget.scheduleId)
              .toList()
            ..sort((a, b) => DateTime.parse(b.createdAt)
                .compareTo(DateTime.parse(a.createdAt)));

          if (statusList.isEmpty) return const SizedBox();

          final firstStatus = statusList.first;
          final isCompleted = firstStatus.isCompleted;
          final gaugeValue = _getGaugeValue(firstStatus.status);

          final Color activeColor =
              isCompleted ? Colors.blue : Colors.grey.shade700;

          return SfLinearGauge(
            key: myKey,
            animationDuration: 0,
            minimum: 0,
            maximum: 90,
            showTicks: false,
            interval: 30,
            animateRange: true,
            axisTrackStyle: LinearAxisTrackStyle(
              thickness: 8,
              edgeStyle: LinearEdgeStyle.bothCurve,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            labelOffset: 20,
            axisLabelStyle: TextStyle(
              color: Constants().textMutedFgDark,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.025,
            ),
            labelFormatterCallback: (label) {
              return switch (label) {
                '0' =>
                  'Initial\n${statusList.length > 0 ? extractDay(statusList[0].updatedAt) ?? "" : ""}',
                '30' =>
                  'Active\n${statusList.length > 1 ? extractDay(statusList[1].updatedAt) ?? "" : ""}',
                '60' =>
                  'Ready\n${statusList.length > 2 ? extractDay(statusList[2].updatedAt) ?? "" : ""}',
                '90' =>
                  'Released\n${statusList.length > 3 ? extractDay(statusList[3].updatedAt) ?? "" : ""}',
                _ => label,
              };
            },
            ranges: [
              LinearGaugeRange(
                midWidth: 8,
                endWidth: 8,
                startValue: 0,
                endValue: gaugeValue,
                position: LinearElementPosition.cross,
                edgeStyle: LinearEdgeStyle.bothCurve,
                color: activeColor,
              ),
            ],
            markerPointers:
                [0.0, 30.0, 60.0, 90.0].asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              final isActive = gaugeValue >= value;

              return LinearWidgetPointer(
                value: value,
                position: LinearElementPosition.cross,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: GoogleFonts.spaceMono(
                        color: isActive
                            ? Colors.white
                            : Constants().textMutedFgDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }

        return const SizedBox();
      },
    );
  }
}

double _getGaugeValue(CompostingStatus status) {
  switch (status) {
    case CompostingStatus.initial:
      return 0;
    case CompostingStatus.active:
      return 30;
    case CompostingStatus.ready:
      return 60;
    case CompostingStatus.released:
      return 90;
  }
}
