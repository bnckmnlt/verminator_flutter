import 'package:intl/intl.dart';

String extractDay(String dateString, {String format = "MMM d"}) {
  final date = DateTime.parse(dateString);
  return DateFormat(format).format(date);
}
