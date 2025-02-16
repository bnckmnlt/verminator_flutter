import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/composting_status_step.dart';

class CompostingStatusStepper extends StatelessWidget {
  final CompostingStatus status;
  final String time;

  const CompostingStatusStepper({
    super.key,
    required this.status,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CompostingStatusStep(
          status: CompostingStatus.initial,
          time: time,
          isCurrentOrPast: status.index >= CompostingStatus.initial.index,
        ),
        const SizedBox(height: 8),
        CompostingStatusStep(
          status: CompostingStatus.processing,
          time: time,
          isCurrentOrPast: status.index >= CompostingStatus.processing.index,
        ),
        const SizedBox(height: 8),
        CompostingStatusStep(
          status: CompostingStatus.ready,
          time: time,
          isCurrentOrPast: status.index >= CompostingStatus.ready.index,
        ),
        const SizedBox(height: 8),
        CompostingStatusStep(
          status: CompostingStatus.released,
          time: time,
          isCurrentOrPast: status.index >= CompostingStatus.released.index,
        ),
      ],
    );
  }
}
