import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/repositories/compost_schedule_repository.dart';
import 'package:fpdart/src/either.dart';

class SelectOneCompostSchedule
    implements UseCase<CompostSchedule, SelectOneCompostScheduleParams> {
  final CompostScheduleRepository repository;

  const SelectOneCompostSchedule(this.repository);

  @override
  Future<Either<Failure, CompostSchedule>> call(
    SelectOneCompostScheduleParams params,
  ) async {
    return await repository.selectOneCompostSchedules(
      id: params.id,
    );
  }
}

class SelectOneCompostScheduleParams {
  final int id;

  SelectOneCompostScheduleParams({
    required this.id,
  });
}
