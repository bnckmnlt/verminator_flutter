import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CompostScheduleRepository {
  Future<Either<Failure, List<CompostSchedule>>> listCompostSchedule();

  Future<Either<Failure, CompostSchedule>> selectOneCompostSchedules({
    required int id,
  });

  Future<Either<Failure, CompostSchedule>> createCompostScheduleById({
    required String scheduleName,
    required String compostProduced,
    required String juiceProduced,
  });

  Future<Either<Failure, CompostSchedule>> patchCompostSchedule({
    required int id,
    String? scheduleName,
    String? compostProduced,
    String? juiceProduced,
    bool? isCompleted,
  });

  Future<Either<Failure, String>> removeCompostSchedule({
    required int id,
  });
}
