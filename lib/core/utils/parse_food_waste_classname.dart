import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';

FoodWasteClassname parseFoodWasteClassname(String value) {
  final mapping = {
    'fruit': FoodWasteClassname.fruit,
    'vegetable': FoodWasteClassname.vegetable,
    'grains': FoodWasteClassname.grains,
    'citrus': FoodWasteClassname.citrus,
    'meat': FoodWasteClassname.meat,
    'foreign': FoodWasteClassname.foreign,
  };

  if (!mapping.containsKey(value)) {
    throw ArgumentError('Unknown classname: $value');
  }

  return mapping[value]!;
}
