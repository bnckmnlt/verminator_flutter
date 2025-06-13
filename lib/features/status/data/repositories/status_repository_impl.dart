import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/network/connection_checker.dart';
import 'package:flutter_vermicomposting/features/status/data/datasources/status_remote_datasource.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:flutter_vermicomposting/features/status/domain/repositories/status_repository.dart';
import 'package:fpdart/src/either.dart';

class StatusRepositoryImpl implements StatusRepository {
  final StatusRemoteDatasource remoteDatasource;
  final ConnectionChecker connectionChecker;

  const StatusRepositoryImpl(this.remoteDatasource, this.connectionChecker);

  @override
  Future<Either<Failure, List<StatusRecord>>> listStatusRecords() async {
    try {
      final list = await remoteDatasource.listStatusRecords();

      return right(list);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, StatusRecord>> selectOneStatusRecord({
    required int id,
  }) async {
    try {
      final statusRecord = await remoteDatasource.selectOneStatusRecord(id: id);

      return right(statusRecord);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
