import 'dart:async';
import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_schedule/app_schedule_cubit.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/evaluate_soil_health.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:flutter_vermicomposting/features/main/data/models/sensor_values_model.dart';
import 'package:flutter_vermicomposting/features/main/domain/entities/sensor_values.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_screen.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:google_fonts/google_fonts.dart';

// TODO: [✅] DONEEEEEEEEE
class SystemInformationWidget extends StatefulWidget {
  final MqttService mqttService;
  final List<CompostSchedule> scheduleData;
  final List<FoodWaste> foodWasteData;

  const SystemInformationWidget({
    super.key,
    required this.scheduleData,
    required this.foodWasteData,
    required this.mqttService,
  });

  @override
  State<SystemInformationWidget> createState() =>
      _SystemInformationWidgetState();
}

class _SystemInformationWidgetState extends State<SystemInformationWidget> {
  late StreamSubscription<String> _beddingLayerSubscription;
  late StreamSubscription<String> _compostLayerSubscription;

  late List<SummaryCardItem> _summaryItems;

  Map<String, dynamic> _collectedData = {};

  late CompostSchedule currentSchedule;

  SensorValues sensorValues = SensorValues(
    temperature: "0",
    humidity: "0",
    soilMoisture: "0",
    nitrogen: "0",
    phosphorus: "0",
    potassium: "0",
    compost: "0",
    vermijuice: "0",
    reservoir: "0",
  );

  int totalCompostProduced = 0;
  int totalJuiceProduced = 0;

  @override
  void initState() {
    super.initState();

    final appState = context.read<AppScheduleCubit>().state;

    if (appState case AppScheduleActive(:final compostSchedule)) {
      currentSchedule = compostSchedule;
    }

    _beddingLayerSubscription =
        widget.mqttService.beddingLayerStream.listen(_onData);
    _compostLayerSubscription =
        widget.mqttService.compostLayerStream.listen(_onData);

    totalCompostProduced = widget.scheduleData.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item.compostProduced ?? '0') ?? 0),
    );
    totalJuiceProduced = widget.scheduleData.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item.juiceProduced ?? '0') ?? 0),
    );

    _summaryItems = [
      SummaryCardItem(
        label: "Total Food Processed",
        value: widget.foodWasteData.length.toString(),
        unit: " items",
        icon: FluentIcons.food_apple_24_regular,
        color: Colors.lightBlueAccent,
      ),
      SummaryCardItem(
        label: "Total Compost Produced",
        value: totalCompostProduced.toString(),
        unit: "kg",
        icon: Icons.eco_rounded,
        color: Colors.lightBlueAccent,
      ),
      SummaryCardItem(
        label: "Total Vermitea Collected",
        value: totalJuiceProduced.toString(),
        unit: "L",
        icon: FluentIcons.drink_bottle_20_regular,
        color: Colors.lightBlueAccent,
      ),
      SummaryCardItem(
        label: "Total Cycle/s Completed",
        value: widget.scheduleData.length.toString(),
        unit: " cycle",
        icon: FluentIcons.recycle_20_regular,
        color: Colors.lightBlueAccent,
      ),
    ];
  }

  @override
  void dispose() {
    _beddingLayerSubscription.cancel();
    _compostLayerSubscription.cancel();
    super.dispose();
  }

  void _onData(String? data) {
    if (data == null) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      _collectedData.addAll(map);
      setState(() {
        sensorValues = SensorValuesModel.fromJson(_collectedData);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(_summaryItems.length, (index) {
          final item = _summaryItems[index];
          final isLast = index == _summaryItems.length - 1;
          return Column(
            children: [
              if (index == 0) _systemHealthCard(isLast),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, isLast ? 0.0 : 16.0),
                child: _systemInformationCard(
                  label: item.label,
                  value: item.value,
                  unit: item.unit,
                  icon: item.icon,
                  color: item.color,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _systemInformationCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.spaceMono(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.spaceMono(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.025,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _systemHealthCard(bool isLast) {
    final result = evaluateSoilHealth(
      temperature: safeParseDouble(sensorValues.temperature),
      humidity: safeParseDouble(sensorValues.humidity),
      soilMoisture: safeParseDouble(sensorValues.soilMoisture),
      nitrogen: safeParseDouble(sensorValues.nitrogen),
      phosphorus: safeParseDouble(sensorValues.phosphorus),
      potassium: safeParseDouble(sensorValues.potassium),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, isLast ? 0.0 : 16.0),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      result['color'].withOpacity(0.05),
                      result['color'].withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "System Health",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(124),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          FluentIcons.heart_pulse_24_regular,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(124),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result["status"].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ScheduleScreen(scheduleId: currentSchedule.id),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  color: Colors.white.withAlpha(32),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "View Schedule Record",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        FluentIcons.chevron_right_24_filled,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
