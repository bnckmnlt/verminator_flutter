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
                "fruit" == item.classname.name &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Vegetables",
        "value": widget.foodWasteList
            .where((item) =>
                "vegetable" == item.classname.name &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Grains",
        "value": widget.foodWasteList
            .where((item) =>
                "grains" == item.classname.name &&
                item.foodWasteScheduleId == widget.compostSchedule.id)
            .length
            .toString(),
      },
      {
        "label": "Rejected",
        "value": widget.foodWasteList
            .where((item) =>
                "invalid" == item.classname.name &&
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
                    if (!hasFoodWaste)
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
                            backgroundColor: Colors.greenAccent.withAlpha(32),
                            foregroundColor: Colors.greenAccent,
                            padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
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
