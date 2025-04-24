import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/repositories/compost_schedule_repository.dart';
import 'package:fpdart/src/either.dart';

class PatchCompostSchedule
    implements UseCase<CompostSchedule, PatchCompostScheduleParams> {
  final CompostScheduleRepository repository;

  const PatchCompostSchedule(this.repository);

  @override
  Future<Either<Failure, CompostSchedule>> call(
      PatchCompostScheduleParams params) async {
    return await repository.patchCompostSchedule(
      id: params.id,
      scheduleName: params.scheduleName,
      compostProduced: params.compostProduced,
      juiceProduced: params.juiceProduced,
      isCompleted: params.isCompleted,
    );
  }
}

class PatchCompostScheduleParams {
  final int id;
  final String? scheduleName;
  final String? compostProduced;
  final String? juiceProduced;
  final bool? isCompleted;

  PatchCompostScheduleParams({
    required this.id,
    this.scheduleName,
    this.compostProduced,
    this.juiceProduced,
    this.isCompleted,
  });
}
