import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FoodWasteRepository {
  Future<Either<Failure, List<FoodWaste>>> listFoodWaste();

  Future<Either<Failure, FoodWaste>> selectOneFoodWaste({
    required int id,
  });
}
