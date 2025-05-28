import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/usecases/list_food_waste.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/usecases/select_one_food_waste.dart';

part 'food_waste_event.dart';
part 'food_waste_state.dart';

class FoodWasteBloc extends Bloc<FoodWasteEvent, FoodWasteState> {
  final SelectOneFoodWaste _selectOneFoodWaste;
  final ListFoodWaste _listFoodWaste;

  FoodWasteBloc({
    required SelectOneFoodWaste selectOneFoodWaste,
    required ListFoodWaste listFoodWaste,
  })  : _selectOneFoodWaste = selectOneFoodWaste,
        _listFoodWaste = listFoodWaste,
        super(FoodWasteInitial()) {
    on<FoodWasteEvent>((event, emit) => emit(FoodWasteLoading()));
    on<FoodWasteList>(_onListFoodWaste);
    on<FoodWasteSelectOne>(_onSelectOneFoodWaste);
  }

  void _onListFoodWaste(
      FoodWasteList event, Emitter<FoodWasteState> emit) async {
    final res = await _listFoodWaste(NoParams());

    res.fold(
      (l) => emit(FoodWasteFailure(l.message)),
      (r) => emit(FoodWasteListSuccess(r)),
    );
  }

  void _onSelectOneFoodWaste(
      FoodWasteSelectOne event, Emitter<FoodWasteState> emit) async {
    final res =
        await _selectOneFoodWaste(SelectOneFoodWasteParams(id: event.id));

    res.fold(
      (l) => emit(FoodWasteFailure(l.message)),
      (r) => emit(FoodWasteSuccess(r)),
    );
  }
}
