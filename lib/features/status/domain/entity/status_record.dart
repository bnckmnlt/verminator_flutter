import 'package:flutter_vermicomposting/core/constants/constants.dart';

class StatusRecord {
  final int id;
  final int scheduleId;
  final CompostingStatus status;
  final String? remarks;
  final bool isCompleted;
  final String createdAt;
  final String updatedAt;

  StatusRecord({
    required this.id,
    required this.scheduleId,
    required this.status,
    this.remarks,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });
}
