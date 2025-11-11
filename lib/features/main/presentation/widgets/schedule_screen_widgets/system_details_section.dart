import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_instruction_screen.dart';

class SystemDetailsSection extends StatefulWidget {
  final CompostSchedule compostSchedule;
  final List<FoodWaste> foodWasteList;

  const SystemDetailsSection({
    super.key,
    required this.compostSchedule,
    required this.foodWasteList,
  });

  @override
  State<SystemDetailsSection> createState() => _SystemDetailsSectionState();
}

class _SystemDetailsSectionState extends State<SystemDetailsSection> {
  late List<Map<String, dynamic>> detailList;

  late List<Map<String, dynamic>> foodWasteRows;

  @override
  void initState() {
    super.initState();

    detailList = [
      {
        "label": "Compost Produced",
        "value": widget.compostSchedule.compostProduced,
        "unit": "kg",
      },
      {
        "label": "Vermijuice Produced",
        "value": widget.compostSchedule.juiceProduced,
        "unit": "L",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    detailList = [
      {
        "label": "Compost Produced",
        "value": widget.compostSchedule.compostProduced ?? "0",
        "unit": "kg",
      },
      {
        "label": "Vermijuice Produced",
        "value": widget.compostSchedule.juiceProduced ?? "0",
        "unit": "L",
      },
    ];

    foodWasteRows = [
      {
        "label": "Fruits",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.fruitWaste &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Vegetables",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.vegetableWaste &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Papers and Cardboards",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.paperCardboard &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Leaves and Dry Materials",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.leavesDryMaterial &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Grains & Bread",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.grainsAndBread &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Eggshells & Coffee Grounds",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.eggshellsCoffeeGrounds &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Onion & Garlic",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.onionGarlic &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Spicy Material",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.spicyMaterial &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Citrus Peels",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.citrusPeels &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Meat & Dairy",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.meatDairy &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Foreign Material",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.foreignMaterial &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Medical Waste",
        "value": widget.foodWasteList
            .where((item) =>
                item.classname == FoodWasteClassname.medicalWaste &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
    ];

    final hasFoodWaste = widget.foodWasteList.any(
      (item) => item.foodWasteScheduleId == widget.compostSchedule.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          "System Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withAlpha(124),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              )),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...detailList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['label'],
                            style: TextStyle(
                              color: Constants().textMutedFgDark,
                              fontWeight: FontWeight.w500,
                            )),
                        Row(
                          children: [
                            Text(
                              "${item['value'].toString()}${item['unit']}",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (index != detailList.length - 1)
                      Divider(
                        height: 16,
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Food Waste Processed",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return GeneralDialog(
                                title: "Start Worm Feeding",
                                description:
                                    "Are you ready to begin adding food waste to this composting batch? This will mark the start of the feeding process",
                                isDismissable: true,
                                confirmButtonLabel: "Continue",
                                approvedFunction: () {
                                  Navigator.pop(context);

                                  Navigator.push(
                                      context,
                                      InitializationInstructionScreen.route(
                                          widget.compostSchedule.id));
                                },
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.75,
                          backgroundColor:
                              Colors.greenAccent.shade200.withAlpha(64),
                          foregroundColor: Colors.greenAccent,
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24))),
                      child: Text(
                        'Start Feeding',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              hasFoodWaste
                  ? Column(
                      children: foodWasteRows.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['label'],
                                  style: TextStyle(
                                    color: Constants().textMutedFgDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text("${item['value']} items"),
                              ],
                            ),
                            if (index != foodWasteRows.length - 1)
                              Divider(
                                height: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                              ),
                          ],
                        );
                      }).toList(),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
                      child: const EmptyDisplayWidget(
                        title: "No Food Waste Records",
                        description:
                            "There are currently no food waste entries associated with this compost schedule.",
                      ),
                    )
            ],
          ),
        ),
      ],
    );
  }
}
