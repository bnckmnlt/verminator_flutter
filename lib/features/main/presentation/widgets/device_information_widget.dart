import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/entities/device_info_model.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/device_info_utils.dart';
import 'package:flutter_vermicomposting/main.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceInformationWidget extends StatefulWidget {
  final Map<String, String> deviceInfo;
  final bool deviceIsActive;

  const DeviceInformationWidget({
    super.key,
    required this.deviceInfo,
    required this.deviceIsActive,
  });

  @override
  State<DeviceInformationWidget> createState() =>
      _DeviceInformationWidgetState();
}

class _DeviceInformationWidgetState extends State<DeviceInformationWidget> {
  late DeviceInfoModel deviceInfo;
  late bool deviceIsActive;

  @override
  void initState() {
    super.initState();
    updateDeviceDetails();
  }

  void updateDeviceDetails() {
    setState(() {
      deviceIsActive = widget.deviceIsActive;
      log.info(widget.deviceInfo);
      deviceInfo = DeviceInfoModel.fromJson(widget.deviceInfo);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!deviceInfo.hasValues() && !deviceIsActive) {
      return Center(
        child: EmptyDisplayWidget(
          title: "Failed to parse data",
          description: "No data to display\nDevice not active",
        ),
      );
    }

    final filteredEntries = deviceInfo.toJson().entries.toList();

    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredEntries.map((item) {
        final showProgress =
            ["CPU Usage", "Memory Usage", "Storage Usage"].contains(item.key);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            spacing: 2.5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.key,
                style: TextStyle(
                  color: Constants().textMutedFgDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.value.length != 0 ? item.value : "Connecting...",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.spaceMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (showProgress) ...[
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                  value: calculateCpuUsage(item.value),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
