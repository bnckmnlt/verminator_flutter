enum LogSeverityFilter { all, info, warn, error, fatal }

enum CompostingStatus {
  initial,
  processing,
  ready,
  released,
}

class Constants {
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
