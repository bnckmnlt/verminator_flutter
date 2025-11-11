import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';

FoodWasteClassname parseFoodWasteClassname(String value) {
  final Map<String, FoodWasteClassname> mapping = {
    'fruit_waste': FoodWasteClassname.fruitWaste,
    'vegetable_waste': FoodWasteClassname.vegetableWaste,
    'paper_cardboard': FoodWasteClassname.paperCardboard,
    'leaves_dry_material': FoodWasteClassname.leavesDryMaterial,
    'onion_garlic': FoodWasteClassname.onionGarlic,
    'spicy_material': FoodWasteClassname.spicyMaterial,
    'eggshells_coffee_grounds': FoodWasteClassname.eggshellsCoffeeGrounds,
    'grains_and_bread': FoodWasteClassname.grainsAndBread,
    'citrus_peels': FoodWasteClassname.citrusPeels,
    'meat_dairy': FoodWasteClassname.meatDairy,
    'foreign_material': FoodWasteClassname.foreignMaterial,
    'medical_waste': FoodWasteClassname.medicalWaste,
  };

  if (!mapping.containsKey(value)) {
    throw ArgumentError('Unknown classname: $value');
  }

  return mapping[value]!;
}
