T? getMax<T extends num>(List<T> list) =>
    list.isNotEmpty ? list.reduce((a, b) => a > b ? a : b) : null;

T? getMin<T extends num>(List<T> list) =>
    list.isNotEmpty ? list.reduce((a, b) => a < b ? a : b) : null;

String formatDouble(num? value) =>
    value != null ? value.toStringAsFixed(1) : "-";
