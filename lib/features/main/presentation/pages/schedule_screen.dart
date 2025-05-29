import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/data_table_sticky.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_waiting_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final formKey = GlobalKey<FormState>();

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

  final data = List.generate(
    100,
    (int index) => DataTableCell(
      day: "May ${index + 1}",
      condition: SensorStatus.good,
      temperature: "37",
      humidity: "46",
      soilMoisture: "65",
      nitrogen: "65",
      phosphorus: "65",
      potassium: "65",
      wormActivity: "Zone D",
    ),
  );

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
        body: SizedBox(
          height: deviceHeight,
          width: deviceWidth,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 44, 16, 0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _schedulePageHeader(),
                        const SizedBox(height: 24),
                        _detailedInfoSection(),
                        const SizedBox(height: 24),
                        _dailyRecordsTableSection()
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
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                      )),
                ),
              )
            ],
          ),
        ),
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

  Widget _dailyRecordsTableSection() {
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
        const SizedBox(height: 16),
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
              data: data,
            ),
          ),
        ),
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
}
