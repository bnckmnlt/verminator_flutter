import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class StatusRepository {
  Future<Either<Failure, List<StatusRecord>>> listStatusRecords();

  Future<Either<Failure, StatusRecord>> selectOneStatusRecord({
    required int id,
  });
}
