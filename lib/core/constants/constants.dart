import 'package:flutter/cupertino.dart';

enum LogSeverityFilter { all, info, warn, error, fatal }

enum SensorStatus { good, fair, bad }

enum CompostingStatus {
  initial,
  processing,
  ready,
  released,
}

class Constants {
  Color textMutedFgDark = Color(0xFF9f9fa9);

  static const noConnectionErrorMessage = 'Not connected to a network!';

  static const List<ReminderInterval> feedingReminderInterval = [
    ReminderInterval(label: ' 3 ', days: 3),
    ReminderInterval(label: ' 7 ', days: 7),
    ReminderInterval(label: ' 10', days: 10),
    ReminderInterval(label: ' 14', days: 14),
  ];

  static List<String> loadingTips = [
    "Avoid placing plastic wrappers or utensils on the conveyor — they are not compostable.",
    "Add food waste one item at a time for accurate sorting and classification.",
    "Did you know? Citrus peels and onions are valid — but too much can slow down composting!",
    "Never throw glass, metal, or rubber items — these are harmful to the worms.",
    "Cut large scraps (like melon rinds) into smaller pieces for faster breakdown.",
    "Reminder: Do not stack food waste — multiple items at once may lead to misclassification.",
    "Paper towels and napkins are compostable if they’re not soaked in chemicals.",
    "Coffee grounds and filters are great for worm bins, but the system doesn't support them yet. :(",
    "Plastics, styrofoam, and foil should never go into the compost stream.",
    "Always check your food waste for stray non-organic packaging before loading."
  ];
}

class ReminderInterval {
  final String label;
  final int days;

  const ReminderInterval({
    required this.label,
    required this.days,
  });
}

class ProcessInformation {
  final IconData icon;
  final title;
  final message;
  final bool currentError;

  const ProcessInformation({
    required this.icon,
    required this.title,
    required this.message,
    required this.currentError,
  });
}

class ConfigInformation {
  final String label;
  final String setting;

  const ConfigInformation({
    required this.label,
    required this.setting,
  });
}

class SensorReadings {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final SensorStatus status;
  final String? remarks;

  SensorReadings({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    this.remarks,
  });
}

class SummaryCardItem {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  SummaryCardItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

class ChartData {
  final String x;
  final double y;
  final Color? color;

  ChartData(this.x, this.y, [this.color]);
}

class SensorControl {
  final String device;
  final String label;
  final IconData icon;
  late final bool state;

  SensorControl({
    required this.device,
    required this.label,
    required this.icon,
    required this.state,
  });
}

class SelectedChart {
  final String label;
  final Color color;
  final List<ChartData> data;

  SelectedChart({
    required this.label,
    required this.color,
    required this.data,
  });
}
