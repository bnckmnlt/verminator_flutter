import 'package:intl/intl.dart';

String extractDay(String dateString) {
  final date = DateTime.parse(dateString);
  return DateFormat("MMM d").format(date);
}
