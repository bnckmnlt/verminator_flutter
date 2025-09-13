String formatToLocalTime(String utcString) {
  final utcDate = DateTime.parse(utcString).toUtc();
  final phDate = utcDate.add(const Duration(hours: 8));
  return phDate.toString();
}
