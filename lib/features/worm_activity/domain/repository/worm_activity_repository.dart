import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class WormActivityRepository {
  Future<Either<Failure, List<WormActivity>>> listWormActivity();

  Future<Either<Failure, WormActivity>> selectOneWormActivity({
    required int id,
});
}
