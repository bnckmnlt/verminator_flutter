import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/repositories/compost_schedule_repository.dart';
import 'package:fpdart/src/either.dart';

class RemoveCompostSchedule
    implements UseCase<String, RemoveCompostScheduleParams> {
  final CompostScheduleRepository repository;

  const RemoveCompostSchedule(this.repository);

  @override
  Future<Either<Failure, String>> call(
      RemoveCompostScheduleParams params) async {
    return await repository.removeCompostSchedule(
      id: params.id,
    );
  }
}

class RemoveCompostScheduleParams {
  final int id;

  RemoveCompostScheduleParams({
    required this.id,
  });
}
