import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/repository/worm_activity_repository.dart';
import 'package:fpdart/fpdart.dart';

class ListWormActivity implements UseCase<List<WormActivity>, NoParams> {
  final WormActivityRepository repository;

  const ListWormActivity(this.repository);

  @override
  Future<Either<Failure, List<WormActivity>>> call(NoParams params) async {
    return await repository.listWormActivity();
  }
}
