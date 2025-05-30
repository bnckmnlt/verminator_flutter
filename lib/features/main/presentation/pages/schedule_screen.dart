import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/entities/layer_classes.dart';
import 'package:flutter_vermicomposting/core/common/widgets/data_table_sticky.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_waiting_screen.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/domain/entity/sensor_reading.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/domain/entity/worm_activity.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:flutter_vermicomposting/main.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();

  bool _hasLoaded = false;

  final TextEditingController _scheduleIdentifierController =
      TextEditingController();

  final List<DataTableColumn> columns = [
    DataTableColumn(label: "Day"),
    DataTableColumn(label: "Condition"),
    DataTableColumn(label: "Temperature"),
    DataTableColumn(label: "Humidity"),
    DataTableColumn(label: "Soil Moisture"),
    DataTableColumn(label: "Nitrogen"),
    DataTableColumn(label: "Potassium"),
    DataTableColumn(label: "Phosphorus"),
    DataTableColumn(label: "Worm Activity"),
  ];

  @override
  void initState() {
    super.initState();

    if (!_hasLoaded) {
      context.read<SensorReadingBloc>().add(SensorReadingList());
      context.read<WormActivityBloc>().add(WormActivityList());
      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, mainConstraints) {
      final deviceHeight = mainConstraints.maxHeight;
      final deviceWidth = mainConstraints.maxWidth;
      bool isDark =
          MediaQuery.of(context).platformBrightness == Brightness.dark;

      return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GeneralDialog(
                    title: 'Create compost schedule',
                    description:
                        'Give your composting cycle a name (e.g., Backyard Pile 1)',
                    confirmButtonLabel: 'Continue',
                    widget: Form(
                      key: formKey,
                      child: TextFormField(
                        controller: _scheduleIdentifierController,
                        validator: (value) {
                          if (value!.isEmpty || value.length <= 8) {
                            return "Compost schedule name is invalid";
                          }
                          return null;
                        },
                      ),
                    ),
                    approvedFunction: () {
                      if (formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return GeneralDialog(
                              title: 'Begin monitoring',
                              description:
                                  'Would you like to begin tracking ${_scheduleIdentifierController.text}?',
                              confirmButtonLabel: 'Confirm',
                              approvedFunction: () {
                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        InitializationWaitingScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                });
          },
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<SensorReadingBloc, SensorReadingState>(
            builder: (context, sensorReadingState) {
          if (sensorReadingState is SensorReadingLoading) {
            return const Center(
              child: Loader(),
            );
          } else if (sensorReadingState is SensorReadingFailure) {
            return Center(
              child: EmptyDisplayWidget(
                icon: FluentIcons.cloud_error_28_regular,
                title: "An error has occurred",
                description: sensorReadingState.error,
              ),
            );
          } else if (sensorReadingState is SensorReadingListSuccess) {
            return BlocBuilder<WormActivityBloc, WormActivityState>(
                builder: (context, wormActivityState) {
              if (wormActivityState is WormActivityLoading) {
                return const Center(
                  child: Loader(),
                );
              } else if (wormActivityState is WormActivityFailure) {
                return Scaffold(
                  body: Center(
                    child: EmptyDisplayWidget(
                      icon: FluentIcons.cloud_error_28_regular,
                      title: "An error has occurred",
                      description: wormActivityState.error,
                    ),
                  ),
                );
              } else if (wormActivityState is WormActivityListSuccess) {
                final List<SensorReading> sensorReadingsData =
                    sensorReadingState.list;
                final List<WormActivity> wormActivityData =
                    wormActivityState.list;

                List<DailyRecordsModel> data = calculateDailyAverages(
                    sensorReadingsData, wormActivityData);

                return SizedBox(
                  height: deviceHeight,
                  width: deviceWidth,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _schedulePageHeader(),
                                const SizedBox(height: 24),
                                _detailedInfoSection(),
                                const SizedBox(height: 24),
                                _dailyRecordsTableSection(data: data),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                              )),
                        ),
                      )
                    ],
                  ),
                );
              }

              return EmptyDisplayWidget(
                title: "An error has occurred",
                description:
                    "Something happened during the process. Please try again later",
              );
            });
          }

          return EmptyDisplayWidget(
            title: "An error has occurred",
            description:
                "Something happened during the process. Please try again later",
          );
        }),
      );
    });
  }

  Widget _schedulePageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "May Cycle",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {},
              child: Icon(FluentIcons.edit_24_regular),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.calendar_16_regular,
              color: Constants().textMutedFgDark,
              size: 18,
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2.5),
              child: Text(
                "2 May 2025, 14:25",
                style: TextStyle(
                  fontSize: 16,
                  color: Constants().textMutedFgDark,
                  letterSpacing: 0.025,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _dailyRecordsTableSection({
    required List<DailyRecordsModel> data,
  }) {
    final dataSource = data.map((item) {
      return DataTableCell(
        day: item.day,
        condition: SensorStatus.good,
        temperature: item.temperature,
        humidity: item.humidity,
        soilMoisture: item.soilMoisture,
        nitrogen: item.nitrogen,
        phosphorus: item.phosphorus,
        potassium: item.potassium,
        wormActivity: item.wormActivity,
      );
    }).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daily Records",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Here's a list of the system records for the month!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            SizedBox(
              height: 32,
              width: 250,
              child: TextFormField(
                style: const TextStyle(
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  hintText: 'Filter conditions...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                cursorColor: Theme.of(context).colorScheme.primary,
                enabled: true,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            const SizedBox(width: 2),
            OutlinedButton(
              onPressed: () {
                context.read<SensorReadingBloc>().add(SensorReadingList());
                context.read<WormActivityBloc>().add(WormActivityList());
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: Size.zero,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  width: 1,
                ),
              ),
              child: Icon(
                FluentIcons.arrow_sync_24_regular,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
              ),
            ),
            const SizedBox(width: 2),
            OutlinedButton(
              onPressed: () {
                _selectDate(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: Size.zero,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FluentIcons.clock_24_regular,
                    size: 16,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(124),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Last hour',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(124),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.025,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
          // constrain the height
          child: SizedBox(
            height: 460,
            child: DataTableSticky(
              columns: columns,
              data: dataSource,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _detailedInfoSection() {
    return Column(
      children: [
        Container(
          height: 124,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 164,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07), // soft shadow
                      blurRadius: 8,
                      offset: Offset(0, 2), // vertical shadow
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 164,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07), // soft shadow
                      blurRadius: 8,
                      offset: Offset(0, 2), // vertical shadow
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isAfter(now) ? now : selectedDate,
      firstDate: DateTime(2024),
      lastDate: now,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}

List<DailyRecordsModel> calculateDailyAverages(
  List<SensorReading> readings,
  List<WormActivity> wormActivities,
) {
  final beddingByDay = <String, List<BeddingReading>>{};
  final compostByDay = <String, List<CompostReading>>{};

  // Process sensor readings
  for (var r in readings) {
    final day = extractDay(r.createdAt);
    if (r.layer == SystemLayer.bedding && r.asBeddingReading != null) {
      beddingByDay.putIfAbsent(day, () => []).add(r.asBeddingReading!);
    } else if (r.layer == SystemLayer.compost && r.asCompostReading != null) {
      compostByDay.putIfAbsent(day, () => []).add(r.asCompostReading!);
    }
  }

  // Process worm activity
  final wormActivityByDay = {
    for (var w in wormActivities) extractDay(w.createdAt): w
  };

  // Collect all unique days from both sources
  final allDays = <String>{
    ...beddingByDay.keys,
    ...compostByDay.keys,
    ...wormActivityByDay.keys
  };

  // Optional: sort days (if you want chronological order, assuming formatted like 'Apr 1')
  // final sortedDays = allDays.toList()..sort((a, b) => /* your comparison logic */);

  log.info("Sensor Reading Days: ${beddingByDay.keys.toList()}");
  log.info("Worm Activity Days: ${wormActivityByDay.keys.toList()}");
  log.info("All Daily Records Days: ${allDays.toList()}");

  return allDays.map((day) {
    final bed = beddingByDay[day] ?? [];
    final comp = compostByDay[day] ?? [];

    double avg(List<num> nums) =>
        nums.isEmpty ? 0.0 : nums.reduce((a, b) => a + b) / nums.length;

    final avgTemp = avg(bed.map((r) => r.temperature.value).toList());
    final avgHumidity = avg(bed.map((r) => r.humidity.value).toList());
    final avgSoilMoisture = avg(bed.map((r) => r.soilMoisture.value).toList());
    final nitrogen = avg(comp.map((r) => r.npk.nitrogen).toList());
    final phosphorus = avg(comp.map((r) => r.npk.phosphorus).toList());
    final potassium = avg(comp.map((r) => r.npk.potassium).toList());

    final wormActivity = (wormActivityByDay[day]
            ?.getActiveZoneLabel(wormActivityByDay[day]!.zones)) ??
        "Unknown";

    return DailyRecordsModel(
      day: day,
      condition: SensorStatus.good,
      temperature: bed.isNotEmpty ? avgTemp.toStringAsFixed(1) : "-",
      humidity: bed.isNotEmpty ? avgHumidity.toStringAsFixed(1) : "-",
      soilMoisture: bed.isNotEmpty ? avgSoilMoisture.toStringAsFixed(1) : "-",
      nitrogen: comp.isNotEmpty
          ? (nitrogen == 0 ? "-" : nitrogen.toStringAsFixed(1))
          : "-",
      phosphorus: comp.isNotEmpty
          ? (phosphorus == 0 ? "-" : phosphorus.toStringAsFixed(1))
          : "-",
      potassium: comp.isNotEmpty
          ? (potassium == 0 ? "-" : potassium.toStringAsFixed(1))
          : "-",
      wormActivity: wormActivity.toString(),
    );
  }).toList();
}

class DailyRecordsModel {
  final String day;
  final SensorStatus condition;
  final String temperature;
  final String humidity;
  final String soilMoisture;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String wormActivity;

  DailyRecordsModel({
    required this.day,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.wormActivity,
  });
}
