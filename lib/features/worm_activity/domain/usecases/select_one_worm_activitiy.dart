import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/repository/worm_activity_repository.dart';
import 'package:fpdart/fpdart.dart';

class SelectOneWormActivity
    implements UseCase<WormActivity, SelectOneWormActivityParams> {
  final WormActivityRepository repository;

  const SelectOneWormActivity(this.repository);

  @override
  Future<Either<Failure, WormActivity>> call(
      SelectOneWormActivityParams params) async {
    return await repository.selectOneWormActivity(
      id: params.id,
    );
  }
}

class SelectOneWormActivityParams {
  final int id;

  SelectOneWormActivityParams({
    required this.id,
  });
}
