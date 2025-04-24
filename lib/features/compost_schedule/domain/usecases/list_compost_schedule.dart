import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/repositories/compost_schedule_repository.dart';
import 'package:fpdart/src/either.dart';

class ListCompostSchedule implements UseCase<List<CompostSchedule>, NoParams> {
  final CompostScheduleRepository repository;

  const ListCompostSchedule(this.repository);

  @override
  Future<Either<Failure, List<CompostSchedule>>> call(NoParams params) async {
    return await repository.listCompostSchedule();
  }
}
