part of 'food_waste_bloc.dart';

@immutable
sealed class FoodWasteState {
  const FoodWasteState();
}

final class FoodWasteInitial extends FoodWasteState {}

final class FoodWasteLoading extends FoodWasteState {}

final class FoodWasteFailure extends FoodWasteState {
  final String error;

  const FoodWasteFailure(this.error);
}

final class FoodWasteListSuccess extends FoodWasteState {
  final List<FoodWaste> foodWaste;

  const FoodWasteListSuccess(this.foodWaste);
}

final class FoodWasteSuccess extends FoodWasteState {
  final FoodWaste foodWaste;

  const FoodWasteSuccess(this.foodWaste);
}
