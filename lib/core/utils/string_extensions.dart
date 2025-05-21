extension StringExtensions on String {
  String firstLetterUpperCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
