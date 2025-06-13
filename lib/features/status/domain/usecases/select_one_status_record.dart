import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:flutter_vermicomposting/features/status/domain/repositories/status_repository.dart';
import 'package:fpdart/fpdart.dart';

class SelectOneStatusRecord
    implements UseCase<StatusRecord, SelectOneStatusRecordParams> {
  final StatusRepository repository;

  const SelectOneStatusRecord(this.repository);

  @override
  Future<Either<Failure, StatusRecord>> call(
      SelectOneStatusRecordParams params) async {
    return await repository.selectOneStatusRecord(id: params.id);
  }
}

class SelectOneStatusRecordParams {
  final int id;

  SelectOneStatusRecordParams({
    required this.id,
  });
}
