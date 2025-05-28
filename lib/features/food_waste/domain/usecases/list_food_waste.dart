import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/repositories/food_waste_repository.dart';
import 'package:fpdart/src/either.dart';

class ListFoodWaste implements UseCase<List<FoodWaste>, NoParams> {
  final FoodWasteRepository repository;

  const ListFoodWaste(this.repository);

  @override
  Future<Either<Failure, List<FoodWaste>>> call(NoParams params) async {
    return await repository.listFoodWaste();
  }
}
