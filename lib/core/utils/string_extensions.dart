extension StringExtensions on String {
  String firstLetterUpperCase() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + this.substring(1);
  }
}
