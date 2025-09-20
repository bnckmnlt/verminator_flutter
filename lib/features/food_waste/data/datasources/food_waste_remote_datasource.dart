import 'dart:convert';

import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/models/food_waste_model.dart';
import 'package:http/http.dart' as http;

abstract interface class FoodWasteRemoteDatasource {
  Future<List<FoodWasteModel>> listFoodWaste();

  Future<FoodWasteModel> selectOneFoodWaste({
    required int id,
  });
}

class FoodWasteRemoteDatasourceImpl implements FoodWasteRemoteDatasource {
  @override
  Future<List<FoodWasteModel>> listFoodWaste() async {
    try {
      final response = await http.get(
        Uri.parse("https://verminator.thinkio.me/food-waste"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((compostSchedule) => FoodWasteModel.fromJson(compostSchedule))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<FoodWasteModel> selectOneFoodWaste({
    required int id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("https://verminator.thinkio.me/food-waste/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return FoodWasteModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
