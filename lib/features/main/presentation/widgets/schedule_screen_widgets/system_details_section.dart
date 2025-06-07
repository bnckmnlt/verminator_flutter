import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';

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
        "value": widget.compostSchedule.compostProduced,
        "unit": "kg",
      },
      {
        "label": "Vermitea Produced",
        "value": widget.compostSchedule.juiceProduced,
        "unit": "L",
      },
    ];

    foodWasteRows = [
      {
        "label": "Fruits",
        "value": widget.foodWasteList
            .where((item) =>
                "fruit" == item.classname.name && item.foodWasteScheduleId == 1)
            .length
            .toString(),
      },
      {
        "label": "Vegetables",
        "value": widget.foodWasteList
            .where((item) =>
                "vegetable" == item.classname.name &&
                item.foodWasteScheduleId == 1)
            .length
            .toString(),
      },
      {
        "label": "Grains",
        "value": widget.foodWasteList
            .where((item) =>
                "grains" == item.classname.name &&
                item.foodWasteScheduleId == 1)
            .length
            .toString(),
      },
      {
        "label": "Rejected",
        "value": widget.foodWasteList
            .where((item) =>
                "invalid" == item.classname.name &&
                item.foodWasteScheduleId == 1)
            .length
            .toString(),
      },
    ];

    return Container(
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
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
              ],
            );
          }),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              "Food Waste Processed",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...foodWasteRows.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['label'],
                        style: TextStyle(
                          color: Constants().textMutedFgDark,
                          fontWeight: FontWeight.w500,
                        )),
                    Text(
                      "${item['value']} items",
                      style: TextStyle(),
                    ),
                  ],
                ),
                if (index != foodWasteRows.length - 1)
                  Divider(
                    height: 16,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
