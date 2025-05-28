import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/repositories/food_waste_repository.dart';
import 'package:fpdart/src/either.dart';

class SelectOneFoodWaste implements UseCase<FoodWaste, SelectOneFoodWasteParams> {
  final FoodWasteRepository repository;

  const SelectOneFoodWaste(this.repository);

  @override
  Future<Either<Failure, FoodWaste>> call(SelectOneFoodWasteParams params) async {
    return await repository.selectOneFoodWaste(id: params.id);
  }
}

class SelectOneFoodWasteParams {
  final int id;

  SelectOneFoodWasteParams({
    required this.id,
  });
}
