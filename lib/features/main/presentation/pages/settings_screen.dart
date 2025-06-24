import 'dart:async';
import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_settings/app_settings_cubit.dart';
import 'package:flutter_vermicomposting/core/common/entities/app_settings_model.dart';
import 'package:flutter_vermicomposting/core/common/widgets/animation.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/configurations_screen.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mqtt_client/mqtt_client.dart';

class SettingsScreen extends StatefulWidget {
  static const List<Map<String, dynamic>> _sidebarTabs = [
    {
      "label": "App Settings",
      "icon": FluentIcons.settings_24_regular,
    },
    {
      "label": "System Configurations",
      "icon": FluentIcons.apps_settings_20_regular,
    },
    {
      "label": "About",
      "icon": FluentIcons.info_24_regular,
    },
    {
      "label": "Exit",
      "icon": FluentIcons.arrow_exit_20_regular,
    },
  ];

  static const List<Widget> _pages = [
    _AppSettings(),
    _SystemSettings(),
    _AboutSection(),
  ];

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
              height: deviceHeight,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    width: 1,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      "Options",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.025,
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            for (var i = 0;
                                i <
                                    SettingsScreen._sidebarTabs
                                        .sublist(0, 3)
                                        .length;
                                i++)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    setState(() {
                                      currentIndex = i;
                                    });
                                  },
                                  child: _SidebarItem(
                                    icon: SettingsScreen._sidebarTabs[i]
                                        ["icon"],
                                    label: SettingsScreen._sidebarTabs[i]
                                        ["label"],
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return GeneralDialog(
                                    title: "Confirm Application Exit",
                                    description:
                                        "Are you sure you want to exit the application? All unsaved changes will be lost.",
                                    confirmButtonLabel: "Exit",
                                    approvedFunction: () {},
                                  );
                                });
                          },
                          child: _SidebarItem(
                            icon: SettingsScreen._sidebarTabs[3]["icon"],
                            label: SettingsScreen._sidebarTabs[3]["label"],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: BounceWithFadeAnimation(
                  key: ValueKey(currentIndex),
                  delay: 2,
                  child: SettingsScreen._pages[currentIndex]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SidebarItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
        horizontal: 14,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _AppSettings extends StatefulWidget {
  const _AppSettings({super.key});

  @override
  State<_AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<_AppSettings> {
  final AppSettingsCubit _appSettingsCubit = GetIt.I<AppSettingsCubit>();

  int _selectedFeedingTimer = 120;

  @override
  void initState() {
    super.initState();

    _selectedFeedingTimer = _appSettingsCubit.state.feedingTimer;
  }

  void restoreSettings() {
    final toastHelper = ToastHelper(context);

    showDialog(
        context: context,
        builder: (context) => GeneralDialog(
              title: "Restore System Configuration",
              description: "Do you want to restore to default values?",
              confirmButtonLabel: "Continue",
              approvedFunction: () {
                Navigator.pop(context);

                _appSettingsCubit.updateAppSettings(
                  AppSettingsModel(feedingTimer: 120),
                );

                setState(() {
                  _selectedFeedingTimer = _appSettingsCubit.state.feedingTimer;
                });
                toastHelper.show(
                  title: "Settings Restored",
                  description:
                      "System settings have been successfully restored to default values",
                  isError: false,
                );
              },
            ));
  }

  void updateAppSettings() {
    final toastHelper = ToastHelper(context);

    _appSettingsCubit.updateAppSettings(
      AppSettingsModel(feedingTimer: _selectedFeedingTimer),
    );

    toastHelper.show(
      title: "Settings Updated",
      description: "System settings have been successfully updated",
      isError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    didChangeDependencies();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 44),
      child: Column(
        spacing: 64,
        children: [
          configurationHeader(
            context: context,
            title: "App Settings",
            description: "Manage your application configurations",
            buttonLabel: "Submit Changes",
            buttonBehavior: updateAppSettings,
            optionalButtonBehavior: restoreSettings,
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionHeader(
                    context: context,
                    title: "Feed Timer Settings",
                    description:
                        "Configure the duration of feeding or loading object for the system",
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
                      child: sectionContent(
                        context: context,
                        description:
                            "Choose from 2 minutes (default), 5 minutes, 8 minutes,\nor 10 minutes",
                        content: Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            ReminderInterval(label: ' 5 ', days: 300),
                            ReminderInterval(label: ' 8 ', days: 480),
                            ReminderInterval(label: '10', days: 600),
                            ReminderInterval(label: 'Default', days: 120),
                          ]
                              .map(
                                (item) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFeedingTimer = item.days;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color:
                                            _selectedFeedingTimer != item.days
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHigh
                                                    .withAlpha(124)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withAlpha(44),
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(
                                            item.label == "Default" ? 16 : 32),
                                        border:
                                            _selectedFeedingTimer != item.days
                                                ? Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHigh,
                                                  )
                                                : Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  )),
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            item.label == "Default" ? 20 : 16,
                                        vertical: 8.0),
                                    child: Text(
                                      item.label.toString(),
                                      style: TextStyle(
                                        color:
                                            _selectedFeedingTimer != item.days
                                                ? null
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
                child: Divider(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SystemSettings extends StatefulWidget {
  const _SystemSettings({super.key});

  @override
  State<_SystemSettings> createState() => _SystemSettingsState();
}

class _SystemSettingsState extends State<_SystemSettings> {
  late MqttService _mqttService;
  late StreamSubscription<Map<String, String>> _systemSettingsSubscription;

  static const List<ReminderInterval> _thermalReadingIntervals = [
    ReminderInterval(label: '30', days: 30),
    ReminderInterval(label: '60', days: 60),
    ReminderInterval(label: '5', days: 300),
    ReminderInterval(label: '10', days: 600),
  ];
  static const ReminderInterval _defaultThermalReadingInterval =
      ReminderInterval(label: 'Default', days: 15);

  int currentSystemStatus = 1;
  final TextEditingController _scheduleIdController = TextEditingController();
  int selectedThermalReadingInterval = 15;
  int refreshRate = 2;

  @override
  void initState() {
    super.initState();
    _mqttService = GetIt.I<MqttService>();
    _mqttService.connect();

    _systemSettingsSubscription =
        _mqttService.systemSettingsStream.listen((settings) {
      setState(() {
        currentSystemStatus = parseStatusToInt(settings["status"] ?? '');
        _scheduleIdController.text = (settings["id"] ?? "1").toString();
        selectedThermalReadingInterval =
            int.tryParse(settings["reading_interval"] ?? '') ?? 15;
        refreshRate = int.tryParse(settings["refresh_rate"] ?? '') ?? 2;
      });
    });
  }

  void restoreSettings() {
    showDialog(
        context: context,
        builder: (context) => GeneralDialog(
              title: "Restore System Configuration",
              description: "Do you want to restore to default values?",
              confirmButtonLabel: "Continue",
              approvedFunction: () {
                Navigator.pop(context);

                final toastHelper = ToastHelper(context);

                final Map<String, String> payload = {
                  'status': "idle",
                  'id': 1.toString(),
                  'reading_interval': 15.toString(),
                  'refresh_rate': 2.toString(),
                };

                _mqttService.publish("system/settings", jsonEncode(payload),
                    retain: true, qos: MqttQos.atLeastOnce);

                toastHelper.show(
                  title: "Settings Restored",
                  description:
                      "System settings have been successfully restored to default values",
                  isError: false,
                );
              },
            ));
  }

  void publishSettings() {
    final toastHelper = ToastHelper(context);

    final Map<String, String> payload = {
      'status': parseIntToStatus(currentSystemStatus),
      'id': _scheduleIdController.text,
      'reading_interval': selectedThermalReadingInterval.toString(),
      'refresh_rate': refreshRate.toString(),
    };

    _mqttService.publish("system/settings", jsonEncode(payload),
        retain: true, qos: MqttQos.atLeastOnce);

    toastHelper.show(
      title: "Settings Updated",
      description: "System settings have been successfully updated",
      isError: false,
    );
  }

  @override
  void dispose() {
    _systemSettingsSubscription.cancel();
    _scheduleIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 44),
      child: Column(
        spacing: 64,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildConfigurationHeader(context),
          Column(
            children: [
              _buildSystemStatusSection(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
                child: Divider(),
              ),
              _buildScheduleIdSection(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
                child: Divider(),
              ),
              _buildThermalReadingIntervalSection(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
                child: Divider(),
              ),
              _buildRefreshRateSection(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
                child: Divider(),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildConfigurationHeader(BuildContext context) {
    return configurationHeader(
      context: context,
      title: "System Configuration",
      description: "Manage your system settings and hardware configurations",
      buttonLabel: "Submit Changes",
      buttonBehavior: publishSettings,
      optionalButtonBehavior: restoreSettings,
    );
  }

  Widget _buildSystemStatusSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: sectionHeader(
            context: context,
            title: "System Status",
            description:
                "View or change the current operational status of the system.",
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
            child: sectionContent(
              context: context,
              header: "Status",
              description:
                  "Choose from Active, Feeding, or Idle.It is advisable\nto use this when debugging",
              content: DropdownMenu<int>(
                initialSelection: currentSystemStatus,
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: 1, label: 'Active'),
                  DropdownMenuEntry(value: 2, label: 'Feeding'),
                  DropdownMenuEntry(value: 3, label: 'Idle'),
                ],
                onSelected: (value) => setState(() {
                  currentSystemStatus = value!;
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleIdSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: sectionHeader(
            context: context,
            title: "Schedule ID",
            description:
                "Manually change the Schedule ID currently assigned in the system",
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
            child: sectionContent(
              context: context,
              header: "Schedule ID",
              content: Container(
                width: MediaQuery.of(context).size.width * 0.10,
                child: TextFormField(
                  controller: _scheduleIdController,
                  maxLength: 2,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThermalReadingIntervalSection(BuildContext context) {
    final intervals = [
      ..._thermalReadingIntervals,
      _defaultThermalReadingInterval
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: sectionHeader(
            context: context,
            title: "Board Reading Interval",
            description:
                "Set how frequently sensor readings are taken and published\n by the Raspberry Pi",
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
            child: sectionContent(
              context: context,
              description:
                  "Choose from 15 seconds (default), 30 seconds, 60 seconds,\n5 minutes,or 10 minutes",
              content: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: intervals
                    .map(
                      (item) => InkWell(
                        onTap: () => setState(() {
                          selectedThermalReadingInterval = item.days;
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                              color: selectedThermalReadingInterval != item.days
                                  ? Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh
                                      .withAlpha(124)
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(44),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(
                                  item.label == "Default" ? 16 : 32),
                              border: selectedThermalReadingInterval !=
                                      item.days
                                  ? Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHigh,
                                    )
                                  : Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                          padding: EdgeInsets.symmetric(
                              horizontal: item.label == "Default" ? 20 : 16,
                              vertical: 8.0),
                          child: Text(
                            item.label.toString(),
                            style: TextStyle(
                              color: selectedThermalReadingInterval != item.days
                                  ? null
                                  : Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRefreshRateSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: sectionHeader(
            context: context,
            title: "Thermal Sensor Refresh Rate",
            description:
                "Configure how fast the MLX90640 updates its temperature\nreadings",
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
            child: sectionContent(
              context: context,
              header: "MLX90640 Refresh Rate",
              content: DropdownMenu<int>(
                initialSelection: refreshRate,
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: 2, label: '2Hz Refresh Rate'),
                  DropdownMenuEntry(value: 4, label: '4Hz Refresh Rate'),
                  DropdownMenuEntry(
                      value: 8, label: '8Hz Refresh Rate (Warning)'),
                  DropdownMenuEntry(
                      value: 16, label: '16Hz Refresh Rate (Warning)'),
                ],
                onSelected: (value) => setState(() {
                  refreshRate = value!;
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 168,
            child: Image.asset(
              "assets/images/thinkio_logo_full.png",
              fit: BoxFit.cover,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Column(
            children: [
              Text(
                "made in rtu 🇵🇭",
                style: GoogleFonts.lacquer(),
              ),
              Text(
                "All Rights Reserved",
                style: TextStyle(
                  letterSpacing: 0.025,
                ),
              ),
              Text(
                "© Think I/0 2025",
                style: TextStyle(
                  letterSpacing: 0.025,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

int parseStatusToInt(String status) {
  switch (status) {
    case "active":
      return 1;
    case "feeding":
      return 2;
    default:
      return 3;
  }
}

String parseIntToStatus(int status) {
  switch (status) {
    case 1:
      return "active";
    case 2:
      return "feeding";
    default:
      return "idle";
  }
}
