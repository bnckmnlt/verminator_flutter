import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/logs/domain/entity/log_entity.dart';
import 'package:flutter_vermicomposting/features/logs/domain/repositories/log_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListLogs implements UseCase<List<LogEntity>, NoParams> {
  final LogRepository repository;

  const ListLogs(this.repository);

  @override
  Future<Either<Failure, List<LogEntity>>> call(NoParams params) async {
    return await repository.listLogs();
  }
}
