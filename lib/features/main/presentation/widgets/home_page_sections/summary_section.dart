import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/composting_status_stepper_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/summary_card_widget.dart';
import 'package:lottie/lottie.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // System Summary
        systemCycle(context),

        const SizedBox(width: 16),
        // Statistics
        Expanded(flex: 2, child: Container()),

        const SizedBox(width: 16),
        // Cycle Details
        systemSummary(context),
      ],
    );
  }
}

Widget systemSummary(BuildContext context) {
  return Expanded(
    child: Wrap(
      spacing: 18,
      runSpacing: 12,
      children: [
        const Text(
          "System Efficiency",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.025,
            height: 2,
          ),
        ),
        SummaryCard(
          label: "Total Compost Generated",
          value: "54 kg",
          icon: Icons.eco_rounded,
          color: Colors.lightBlueAccent,
        ),
        SummaryCard(
          label: "Total Food Waste Processed",
          value: "32 pcs/per cycle",
          icon: FluentIcons.food_apple_24_filled,
          color: Colors.greenAccent.shade200,
        ),
        SummaryCard(
          label: "Total VermiJuice Collected",
          value: "22L",
          icon: FluentIcons.drink_bottle_32_filled,
          color: Colors.amberAccent,
        ),
        SummaryCard(
          label: "Total Cycle/s Done",
          value: "1 cycle",
          icon: FluentIcons.recycle_32_filled,
          color: Colors.indigoAccent,
        ),
      ],
    ),
  );
}

Widget systemCycle(BuildContext context) {
  return Expanded(
    child: Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Current Cycle",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.025,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      icon: Icon(
                        FluentIcons.chevron_left_24_filled,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      iconSize: 18,
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      icon: Icon(
                        FluentIcons.chevron_right_24_filled,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Schedule
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Estimated day of produce:",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.025,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "24 February 2025, 2:45 PM",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(124),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.025,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stepper
          CompostingStatusStepper(
            status: CompostingStatus.processing,
            time: "12:00",
          ),

          const SizedBox(height: 14),

          Expanded(
            child: SizedBox(
              height: 128,
              width: double.infinity,
              child: Lottie.asset(
                animate: false,
                repeat: false,
                'assets/animations/worm_v2.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
