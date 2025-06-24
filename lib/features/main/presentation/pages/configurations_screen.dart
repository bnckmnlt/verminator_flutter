import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';

class ConfigurationsScreen extends StatefulWidget {
  const ConfigurationsScreen({super.key});

  @override
  State<ConfigurationsScreen> createState() => _ConfigurationsScreenState();
}

class _ConfigurationsScreenState extends State<ConfigurationsScreen> {
  double _targetTemperatureValue = 30.0;
  double _targetHumidityValue = 85.0;
  RangeValues _soilMoistureRangeValue = const RangeValues(40, 60);
  RangeValues _soilAerationRangeValue = const RangeValues(60, 80);
  ReminderInterval defaultFeedingReminder =
      const ReminderInterval(label: 'Default', days: 0);
  int _selectedFeedingReminder = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double deviceHeight = MediaQuery.of(context).size.height;
      final double deviceWidth = MediaQuery.of(context).size.width;

      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                configurationHeader(
                  context: context,
                  title: "Configurations",
                  description: "Manage your system's default parameters",
                  buttonLabel: "Submit Changes",
                  buttonBehavior: () {},
                ),
                const SizedBox(height: 52),
                _ambientFanControlComponent(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
                  child: Divider(),
                ),
                _soilMoistureControlComponent(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
                  child: Divider(),
                ),
                _soilAerationControlComponent(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
                  child: Divider(),
                ),
                _feedingReminderControlComponent(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _ambientFanControlComponent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: sectionHeader(
            context: context,
            title: "Ambient Fan",
            description: "Configure ambient fan trigger parameters",
          ),
        ),
        Expanded(
          child: sectionContent(
            context: context,
            description:
                "Set the maximum temperature (°C) and humidity (%) thresholds to activate fan system",
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Temperature",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                              ),
                            ),
                            child: Text(
                              '${_targetTemperatureValue}°C',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CupertinoSlider(
                        min: 10.0,
                        max: 40.0,
                        value: _targetTemperatureValue,
                        onChanged: (double value) {
                          setState(() {
                            _targetTemperatureValue = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Humidity",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                              ),
                            ),
                            child: Text(
                              '${_targetHumidityValue}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CupertinoSlider(
                        min: 0.0,
                        max: 100.0,
                        value: _targetHumidityValue,
                        onChanged: (double value) {
                          setState(() {
                            _targetHumidityValue = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _soilMoistureControlComponent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: sectionHeader(
            context: context,
            title: "Soil Moisture",
            description: "Adjust soil moisture trigger level parameter",
          ),
        ),
        Expanded(
          child: sectionContent(
            context: context,
            description:
                "Set soil moisture range (%) for bedding layer to trigger misting pump",
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Soil Moisture Range",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                        ),
                      ),
                      child: Text(
                        '${_soilMoistureRangeValue.start.round()}% - ${_soilMoistureRangeValue.end.round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RangeSlider(
                  min: 0.0,
                  max: 100.0,
                  divisions: 20,
                  values: _soilMoistureRangeValue,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _soilMoistureRangeValue = values;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _soilAerationControlComponent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: sectionHeader(
            context: context,
            title: "Soil Aeration",
            description: "Adjust soil aeration trigger level parameter",
          ),
        ),
        Expanded(
          child: sectionContent(
            context: context,
            description:
                "Set soil moisture range (%) for bedding layer to trigger soil aeration system",
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Safe Soil Moisture Range",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                        ),
                      ),
                      child: Text(
                        '${_soilAerationRangeValue.start.round()}% - ${_soilAerationRangeValue.end.round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RangeSlider(
                  min: 0.0,
                  max: 100.0,
                  divisions: 20,
                  values: _soilAerationRangeValue,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _soilAerationRangeValue = values;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _feedingReminderControlComponent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: sectionHeader(
            context: context,
            title: "Feeding Reminder",
            description: "Specify feeding reminder schedule",
          ),
        ),
        Expanded(
          child: sectionContent(
            context: context,
            description:
                "Configure feeding reminder schedule (optional). Defaults to none",
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...Constants.feedingReminderInterval,
                  defaultFeedingReminder
                ]
                    .map(
                      (item) => GestureDetector(
                        onTap: () {
                          _selectedFeedingReminder = item.days;
                          setState(() {});
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: item.label == "Default" ? 6 : 2),
                          child: Chip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                    item.label == "Default" ? 16 : 32),
                              ),
                            ),
                            backgroundColor:
                                _selectedFeedingReminder != item.days
                                    ? null
                                    : Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(44),
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            side: _selectedFeedingReminder != item.days
                                ? null
                                : BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            label: Text(
                              item.label.toString(),
                              style: TextStyle(
                                color: _selectedFeedingReminder != item.days
                                    ? null
                                    : Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget configurationHeader({
  required BuildContext context,
  required String title,
  required String description,
  required String buttonLabel,
  VoidCallback? optionalButtonBehavior,
  required VoidCallback buttonBehavior,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(186),
            ),
          ),
        ],
      ),
      Row(
        children: [
          OutlinedButton(
            onPressed: optionalButtonBehavior,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(
                  width: 1,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh),
              padding: EdgeInsets.zero,
              // remove internal padding
              minimumSize: const Size(36, 36),
            ),
            child: Icon(
              FluentIcons.history_24_filled,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: buttonBehavior,
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget sectionHeader({
  required BuildContext context,
  required String title,
  required String description,
  Widget? optionalWidget,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
        ),
      ),
      const SizedBox(height: 8),
      if (optionalWidget != null) optionalWidget,
    ],
  );
}

Widget sectionContent({
  required BuildContext context,
  String? header,
  Widget? content,
  String? description,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (header != null)
        Text(
          header,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      if (header != null) const SizedBox(height: 8),
      if (content != null) content!,
      if (description != null) const SizedBox(height: 24),
      Text(
        description ?? "",
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(124),
        ),
        softWrap: true,
        maxLines: 2,
      ),
    ],
  );
}
