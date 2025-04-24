import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/repositories/compost_schedule_repository.dart';
import 'package:fpdart/src/either.dart';

class CreateCompostSchedule
    implements UseCase<CompostSchedule, CreateCompostScheduleParams> {
  final CompostScheduleRepository repository;

  const CreateCompostSchedule(this.repository);

  @override
  Future<Either<Failure, CompostSchedule>> call(params) async {
    return await repository.createCompostScheduleById(
      scheduleName: params.scheduleName,
      compostProduced: params.compostProduced,
      juiceProduced: params.juiceProduced,
    );
  }
}

class CreateCompostScheduleParams {
  final String scheduleName;
  final String compostProduced;
  final String juiceProduced;

  CreateCompostScheduleParams({
    required this.scheduleName,
    required this.compostProduced,
    required this.juiceProduced,
  });
}
