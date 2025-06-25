String formatToLocalTime(String utcString) {
  final utcDate = DateTime.parse(utcString).toUtc();
  final localDate = utcDate.toLocal();
  return localDate.toString();
}
