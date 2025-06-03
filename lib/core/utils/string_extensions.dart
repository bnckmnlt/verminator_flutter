extension StringExtensions on String {
  String firstLetterUpperCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

double? safeParseDouble(String? value) {
  if (value == null || value.trim() == "-" || value.trim().isEmpty) {
    return null;
  }
  return double.tryParse(value);
}
