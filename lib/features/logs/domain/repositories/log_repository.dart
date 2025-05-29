import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/features/logs/domain/entity/log_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class LogRepository {
  Future<Either<Failure, List<LogEntity>>> listLogs();
}
