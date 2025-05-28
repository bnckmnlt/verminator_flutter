import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';

// TODO: [✅] DONEEEEEEEEE
class SystemInformationWidget extends StatefulWidget {
  final List<CompostSchedule> scheduleData;
  final List<FoodWaste> foodWasteData;

  const SystemInformationWidget({
    super.key,
    required this.scheduleData,
    required this.foodWasteData,
  });

  @override
  State<SystemInformationWidget> createState() =>
      _SystemInformationWidgetState();
}

class _SystemInformationWidgetState extends State<SystemInformationWidget> {
  late List<SummaryCardItem> _summaryItems;

  int totalCompostProduced = 0;
  int totalJuiceProduced = 0;

  @override
  void initState() {
    super.initState();

    totalCompostProduced = widget.scheduleData.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item.compostProduced ?? '0') ?? 0),
    );
    totalJuiceProduced = widget.scheduleData.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item.juiceProduced ?? '0') ?? 0),
    );

    _summaryItems = [
      SummaryCardItem(
        label: "Total Food Processed",
        value: widget.foodWasteData.length.toString(),
        unit: "pcs",
        icon: FluentIcons.food_apple_24_regular,
        color: Colors.lightBlueAccent,
      ),
      SummaryCardItem(
        label: "Total Compost Produced",
        value: totalCompostProduced.toString(),
        unit: "kg",
        icon: Icons.eco_rounded,
        color: Colors.greenAccent,
      ),
      SummaryCardItem(
        label: "Total Vermijuice Collected",
        value: totalJuiceProduced.toString(),
        unit: "L",
        icon: FluentIcons.drink_bottle_20_regular,
        color: Colors.amberAccent,
      ),
      SummaryCardItem(
        label: "Total Cycle/s Completed",
        value: widget.scheduleData.length.toString(),
        unit: " cycle",
        icon: FluentIcons.recycle_20_regular,
        color: Colors.indigoAccent,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(_summaryItems.length, (index) {
          final item = _summaryItems[index];
          final isLast = index == _summaryItems.length - 1;
          return Column(
            children: [
              if (index == 0) _systemHealthCard(isLast),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, isLast ? 0.0 : 16.0),
                child: _systemInformationCard(
                  label: item.label,
                  value: item.value,
                  unit: item.unit,
                  icon: item.icon,
                  color: item.color,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _systemInformationCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 2.5),
              Text(
                unit,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.025,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _systemHealthCard(bool isLast) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, isLast ? 0.0 : 16.0),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.greenAccent.withOpacity(0.05),
                      Colors.greenAccent.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "System Health",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(124),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          FluentIcons.heart_pulse_24_regular,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(124),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Excellent",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                color: Colors.white.withAlpha(32),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "View Schedule Record",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      FluentIcons.chevron_right_24_filled,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
