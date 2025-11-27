import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/popup_selection_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/core/utils/evaluate_soil_health.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
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
  DateTime? _selectedDate = DateTime.now();

  late PromptResponse _dailyReportResponse;
  late SensorValues _sensorValues;

  late Map<String, PromptBody> _summaryData;
  late List<String> _dataKeys;
  late Widget _selection;

  bool _isError = false;

  late ToastHelper _toaster;

  int currentSummaryTab = 0;

  bool responseLoaded = false;

  @override
  void initState() {
    _sensorValues = widget.sensorValues;

    super.initState();

    // _getResponse();
  }

  @override
  Widget build(BuildContext context) {
    _toaster = ToastHelper(context);

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

      _dataKeys = _summaryData.keys.toList();

      _selection = PopupSelectionWidget(
        label: _dataKeys[currentSummaryTab].toUpperCase(),
        selectedFunction: (value) => setState(() {
          currentSummaryTab = value;
        }),
        popupKeys: _dataKeys,
        trailingIcon: const Icon(
          FluentIcons.chevron_down_24_filled,
          size: 14,
        ),
      );
    }

    final result = evaluateSoilHealth(
      temperature: safeParseDouble(_sensorValues.temperature),
      humidity: safeParseDouble(_sensorValues.humidity),
      soilMoisture: safeParseDouble(_sensorValues.soilMoisture),
      nitrogen: safeParseDouble(_sensorValues.nitrogen),
      phosphorus: safeParseDouble(_sensorValues.phosphorus),
      potassium: safeParseDouble(_sensorValues.potassium),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 14,
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
          child: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration(seconds: 1), () {
                responseLoaded = false;
                _getResponse();
              });
            },
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
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.transparent],
                  stops: [0.8, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _systemConditionSection(result),
                      Divider(),
                      responseLoaded
                          ? _readingPromptSection(_selection)
                          : SizedBox(
                              height: 324,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 20,
                                children: [
                                  Loader(),
                                  if (_isError)
                                    OutlinedButton(
                                      onPressed: () => _getResponse(),
                                      style: OutlinedButton.styleFrom(
                                        disabledBackgroundColor:
                                            Color(0xFF27272a).withAlpha(124),
                                        disabledForegroundColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withAlpha(0),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 24,
                                        ),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                        ),
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        minimumSize: Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        "Reload response",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.025,
                                        ),
                                      ),
                                    ),
                                ],
                              )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _systemConditionSection(Map<String, dynamic> result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "System Condition",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              result["status"].toString().toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Zenbones Mono",
                fontWeight: FontWeight.bold,
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
    );
  }

  Widget _readingPromptSection(Widget selection) {
    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 12,
          children: [
            Icon(CupertinoIcons.sparkles),
            Row(
              spacing: 8,
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
                    color: Colors.lightBlue.withAlpha(64),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.lightBlue,
                    ),
                  ),
                  child: Text(
                    "AI",
                    style: TextStyle(
                      color: Colors.lightBlue,
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
          spacing: 16,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                      minimumSize: Size.zero,
                      side: BorderSide(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
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
            ),
            responseLoaded
                ? insightAndRecommendationSection(
                    _summaryData[_dataKeys[currentSummaryTab]]!)
                : Center(child: Loader()),
          ],
        ),
      ],
    );
  }

  Widget insightAndRecommendationSection(PromptBody promptBody) {
    return Column(
      spacing: 18,
      children: [
        Column(
          spacing: 10,
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
                height: 1.5,
              ),
            )
          ],
        ),
        Column(
          spacing: 10,
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
                height: 1.5,
              ),
            )
          ],
        ),
        SizedBox.fromSize(
          size: Size(24, 24),
        )
      ],
    );
  }

  Future<void> _getResponse() async {
    try {
      final response = await http.post(
        Uri.parse(
            "${AppSecrets.domainURL}/prompt/${_selectedDate?.toUtc().toIso8601String()}"),
      );

      if (response.statusCode == 200) {
        _dailyReportResponse =
            PromptResponse.fromJson(jsonDecode(response.body));

        setState(() {
          responseLoaded = true;
        });
      }
      setState(() {
        _isError = false;
      });
    } on ServerException catch (e) {
      _toaster.show(
        title: "Something went wrong",
        description: e.toString(),
        isError: true,
      );
      setState(() {
        _isError = true;
      });
    } catch (e) {
      _toaster.show(
        title: "Unexpected error has occured",
        description: e.toString(),
        isError: true,
      );
      setState(() {
        _isError = true;
      });
    }
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

class PromptResponse {
  final PromptBody temperature;
  final PromptBody humidity;
  final PromptBody moisture;
  final PromptBody nitrogen;
  final PromptBody phosphorus;
  final PromptBody potassium;

  PromptResponse({
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });

  factory PromptResponse.fromJson(Map<String, dynamic> json) {
    return PromptResponse(
      temperature: PromptBody.fromJson(json["temperature"]),
      humidity: PromptBody.fromJson(json["humidity"]),
      moisture: PromptBody.fromJson(json["moisture"]),
      nitrogen: PromptBody.fromJson(json["nitrogen"]),
      phosphorus: PromptBody.fromJson(json["phosphorus"]),
      potassium: PromptBody.fromJson(json["potassium"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "temperature": temperature,
      "humidity": humidity,
      "moisture": moisture,
      "nitrogen": nitrogen,
      "phosphorus": phosphorus,
      "potassium": potassium,
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
