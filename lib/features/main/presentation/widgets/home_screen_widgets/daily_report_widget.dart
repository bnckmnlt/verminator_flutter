import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/core/utils/evaluate_soil_health.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
import 'package:flutter_vermicomposting/main.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DailyReportWidget extends StatefulWidget {
  final SensorValues sensorValues;

  const DailyReportWidget({
    super.key,
    required this.sensorValues,
  });

  @override
  State<DailyReportWidget> createState() => _DailyReportWidgetState();
}

class _DailyReportWidgetState extends State<DailyReportWidget> {
  late SummaryPromptResponse _dailyReportResponse;
  late SensorValues _sensorValues;
  late Map<String, PromptBody> _summaryData;
  late List<String> dataKeys;
  DateTime? _selectedDate = DateTime.now();

  int currentSummaryTab = 0;

  bool responseLoaded = false;

  @override
  void initState() {
    _sensorValues = widget.sensorValues;

    log.severe(_selectedDate?.toIso8601String());

    super.initState();

    _getResponse();
  }

  Future<void> _getResponse() async {
    try {
      final response = await http.post(
        Uri.parse(
            "${AppSecrets.domainURL}/prompt/${_selectedDate?.toUtc().toIso8601String()}"),
      );

      if (response.statusCode == 200) {
        _dailyReportResponse =
            SummaryPromptResponse.fromJson(jsonDecode(response.body));

        setState(() {
          responseLoaded = true;
        });
      } else {
        throw ServerException(response.body.parseErrorMessage());
      }
    } on ServerException catch (e) {
      log.warning(e.toString());
    } catch (e, stack) {
      log.severe('Unexpected error: $e', e, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (responseLoaded) {
      _summaryData =
          _dailyReportResponse.toMap().entries.fold({}, (prev, curr) {
        final String label = curr.key;
        final PromptBody body = curr.value;

        prev.putIfAbsent(
            label,
            () => PromptBody(
                insight: body.insight, recommendation: body.recommendation));

        return prev;
      });

      dataKeys = _summaryData.keys.toList();
    }

    final result = evaluateSoilHealth(
      temperature: safeParseDouble(_sensorValues.temperature),
      humidity: safeParseDouble(_sensorValues.humidity),
      soilMoisture: safeParseDouble(_sensorValues.soilMoisture),
      nitrogen: safeParseDouble(_sensorValues.nitrogen),
      phosphorus: safeParseDouble(_sensorValues.phosphorus),
      potassium: safeParseDouble(_sensorValues.potassium),
    );

    Widget selection = PopupMenuButton(
      onSelected: (value) => setState(() {
        currentSummaryTab = value;
      }),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 0,
          child: Text('Temperature'),
        ),
        PopupMenuItem(
          value: 1,
          child: Text('Humidity'),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('Soil Moisture'),
        ),
        PopupMenuItem(
          value: 3,
          child: Text('Nitrogen'),
        ),
        PopupMenuItem(
          value: 4,
          child: Text('Phosphorus'),
        ),
        PopupMenuItem(
          value: 5,
          child: Text('Potassium'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        child: Row(
          spacing: 6,
          children: [
            Text(
              responseLoaded
                  ? dataKeys[currentSummaryTab].toUpperCase()
                  : "Loading",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              FluentIcons.chevron_down_24_filled,
              size: 14,
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 18,
      children: [
        Text(
          "Today's Report",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Glassmorphism(
          blur: 12,
          opacity: 0.2,
          child: Container(
            height: 470,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHigh
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainer,
                width: 1.5,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  result["color"].withAlpha(28),
                  result["color"].withAlpha(24),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("System Health"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            result["status"].toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.025,
                            ),
                          ),
                          Icon(
                            result['icon'],
                            size: 20,
                            color: result["color"],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  _readingPromptSection(selection),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _readingPromptSection(Widget selection) {
    return Column(
      spacing: 14,
      children: [
        Row(
          spacing: 12,
          children: [
            Icon(CupertinoIcons.sparkles),
            Row(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withAlpha(64),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.orangeAccent,
                    ),
                  ),
                  child: Text(
                    "AI",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        Column(
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    minimumSize: Size.zero,
                    side: BorderSide(
                      width: 1,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(24),
                    ),
                  ),
                  onPressed: () => _selectDate(context),
                  child: Row(
                    spacing: 6,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      Text(
                        DateFormat.yMMMd().format(_selectedDate!),
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                selection,
              ],
            ),
            responseLoaded
                ? insightAndRecommendationSection(
                    _summaryData[dataKeys[currentSummaryTab]]!)
                : Center(child: Loader()),
          ],
        ),
      ],
    );
  }

  Widget insightAndRecommendationSection(PromptBody promptBody) {
    return Column(
      spacing: 14,
      children: [
        Column(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Insight",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.025,
              ),
            ),
            Text(
              promptBody.insight,
              textAlign: TextAlign.justify,
            )
          ],
        ),
        Column(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recommendation",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.025,
              ),
            ),
            Text(
              promptBody.recommendation,
              textAlign: TextAlign.justify,
            )
          ],
        )
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      helpText: 'Select a Date',
      cancelText: 'Cancel',
      confirmText: 'Select',
      fieldLabelText: 'Selected Date',
      fieldHintText: 'Month/Day/Year',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        responseLoaded = false;
      });
    }

    _getResponse();
  }
}

class SummaryPromptResponse {
  final PromptBody temperature;
  final PromptBody humidity;
  final PromptBody soilMoisture;
  final PromptBody nitrogen;
  final PromptBody phosphorus;
  final PromptBody potassium;

  SummaryPromptResponse({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });

  factory SummaryPromptResponse.fromJson(Map<String, dynamic> json) {
    return SummaryPromptResponse(
      temperature: PromptBody.fromJson(json["temperature"]),
      humidity: PromptBody.fromJson(json["humidity"]),
      soilMoisture: PromptBody.fromJson(json["moisture"]),
      nitrogen: PromptBody.fromJson(json["nitrogen"]),
      phosphorus: PromptBody.fromJson(json["phosphorus"]),
      potassium: PromptBody.fromJson(json["potassium"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "temperature": this.temperature,
      "humidity": this.humidity,
      "soilMoisture": this.soilMoisture,
      "nitrogen": this.nitrogen,
      "phosphorus": this.phosphorus,
      "potassium": this.potassium,
    };
  }
}

class PromptBody {
  final String insight;
  final String recommendation;

  PromptBody({
    required this.insight,
    required this.recommendation,
  });

  factory PromptBody.fromJson(Map<String, dynamic> json) {
    return PromptBody(
      insight: json["insight"] as String,
      recommendation: json["recommendation"] as String,
    );
  }
}
