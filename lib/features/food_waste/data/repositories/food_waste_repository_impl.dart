import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/error/failure.dart';
import 'package:flutter_vermicomposting/core/network/connection_checker.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/datasources/food_waste_remote_datasource.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/repositories/food_waste_repository.dart';
import 'package:fpdart/src/either.dart';

class FoodWasteRepositoryImpl implements FoodWasteRepository {
  final FoodWasteRemoteDatasource remoteDatasource;
  final ConnectionChecker connectionChecker;

  const FoodWasteRepositoryImpl(
    this.remoteDatasource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, List<FoodWaste>>> listFoodWaste() async {
    try {
      final list = await remoteDatasource.listFoodWaste();

      return right(list);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, FoodWaste>> selectOneFoodWaste({
    required int id,
  }) async {
    try {
      final foodWaste = await remoteDatasource.selectOneFoodWaste(id: id);

      return right(foodWaste);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
