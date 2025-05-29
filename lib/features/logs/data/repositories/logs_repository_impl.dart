import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/network/connection_checker.dart';
import 'package:flutter_vermicomposting/features/logs/data/datasources/log_remote_datasource.dart';
import 'package:flutter_vermicomposting/features/logs/domain/entity/log_entity.dart';
import 'package:flutter_vermicomposting/features/logs/domain/repositories/log_repository.dart';
import 'package:fpdart/fpdart.dart';

class LogRepositoryImpl implements LogRepository {
  final LogRemoteDatasource remoteDatasource;
  final ConnectionChecker connectionChecker;

  const LogRepositoryImpl(
    this.remoteDatasource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<LogEntity>>> listLogs() async {
    try {
      final logs = await remoteDatasource.listLogs();

      return right(logs);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
