import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/status/domain/entity/status_record.dart';
import 'package:flutter_vermicomposting/features/status/domain/repositories/status_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListStatusRecords implements UseCase<List<StatusRecord>, NoParams> {
  final StatusRepository repository;

  const ListStatusRecords(this.repository);

  @override
  Future<Either<Failure, List<StatusRecord>>> call(NoParams params) async {
    return await repository.listStatusRecords();
  }
}
