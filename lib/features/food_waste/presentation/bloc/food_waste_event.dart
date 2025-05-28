part of 'food_waste_bloc.dart';

@immutable
sealed class FoodWasteEvent {}

final class FoodWasteSelectOne extends FoodWasteEvent {
  final int id;

  FoodWasteSelectOne({required this.id});
}

final class FoodWasteList extends FoodWasteEvent {}
