import 'package:flutter_vermicomposting/core/constants/constants.dart';

SensorStatus getSensorStatus({
  required String type,
  required String? value,
  required Map<String, Threshold> thresholds,
}) {
  if (value == null) return SensorStatus.bad;
  final v = double.tryParse(value);
  if (v == null) return SensorStatus.bad;

  final t = thresholds[type];
  if (t == null) return SensorStatus.bad;

  return t.classify(v);
}
