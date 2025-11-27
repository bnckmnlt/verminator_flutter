import 'package:flutter/material.dart';

class FoodWaste {
  final int id;
  final int foodWasteScheduleId;
  final String filePath;
  final MaterialStatus materialStatus;
  final double confidence;
  final FoodWasteClassname classname;
  final String createdAt;

  FoodWaste({
    required this.id,
    required this.foodWasteScheduleId,
    required this.filePath,
    required this.materialStatus,
    required this.confidence,
    required this.classname,
    required this.createdAt,
  });
}

enum MaterialStatus { valid, invalid, controlled }

enum FoodWasteClassname {
  fruitWaste,
  vegetableWaste,
  paperCardboard,
  leavesDryMaterial,
  onionGarlic,
  spicyMaterial,
  eggshellsCoffeeGrounds,
  grainsAndBread,
  citrusPeels,
  meatDairy,
  foreignMaterial,
  medicalWaste,
}

extension FoodWasteClassnameLabel on FoodWasteClassname {
  String get label {
    switch (this) {
      case FoodWasteClassname.fruitWaste:
        return "Fruit Waste";
      case FoodWasteClassname.vegetableWaste:
        return "Vegetable Waste";
      case FoodWasteClassname.paperCardboard:
        return "Paper & Cardboard";
      case FoodWasteClassname.leavesDryMaterial:
        return "Leaves & Dry Material";
      case FoodWasteClassname.onionGarlic:
        return "Onion & Garlic";
      case FoodWasteClassname.spicyMaterial:
        return "Spicy Material";
      case FoodWasteClassname.eggshellsCoffeeGrounds:
        return "Eggshells & Coffee Grounds";
      case FoodWasteClassname.grainsAndBread:
        return "Grains & Bread";
      case FoodWasteClassname.citrusPeels:
        return "Citrus Peels";
      case FoodWasteClassname.meatDairy:
        return "Meat & Dairy";
      case FoodWasteClassname.foreignMaterial:
        return "Foreign Material";
      case FoodWasteClassname.medicalWaste:
        return "Medical Waste";
    }
  }
}

extension MaterialStatusLabel on MaterialStatus {
  Widget get statusWidget {
    String material = "";
    Color color = Colors.greenAccent;

    switch (this) {
      case MaterialStatus.valid:
        material = "Valid Material";
        color = Colors.greenAccent;
      case MaterialStatus.invalid:
        material = "Invalid Material";
        color = Colors.redAccent;
      case MaterialStatus.controlled:
        material = "Controlled Material";
        color = Colors.amberAccent;
    }

    return ConstrainedBox(
        constraints: BoxConstraints(minWidth: 64, maxWidth: 124),
        child: _statusBadge(color: color, state: material));
  }
}

Widget _statusBadge({
  required Color color,
  required String state,
}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 2.5, horizontal: 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Text(
        state,
        style: TextStyle(
          color: color != Colors.redAccent ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.025,
        ),
      ),
    ),
  );
}
