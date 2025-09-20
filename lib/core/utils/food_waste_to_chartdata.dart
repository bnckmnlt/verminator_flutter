import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:intl/intl.dart';

List<ChartData> foodWasteToChartData(
  FoodWasteClassname classname,
  List<FoodWaste> foodWasteList,
  DateFormat? dateFormat,
) {
  return foodWasteList
      .where((food) => food.classname == classname)
      .fold<Map<String, List<FoodWaste>>>({}, (prev, curr) {
        final dateLabel = dateFormat != null
            ? dateFormat.format(DateTime.parse(curr.createdAt))
            : DateFormat.yMMMd().format(DateTime.parse(curr.createdAt));

        prev.putIfAbsent(dateLabel, () => []).add(curr);

        return prev;
      })
      .entries
      .map((entry) {
        final date = entry.key;
        final int list = entry.value.length;

        return ChartData(date, list.toDouble());
      })
      .toList();
}
