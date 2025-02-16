import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/error_widget.dart';

class LiveMonitoringSection extends StatelessWidget {
  const LiveMonitoringSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 2;
        double itemWidth = constraints.maxWidth / columns - 16;

        return Wrap(
          spacing: 16,
          runSpacing: 0,
          children: [
            SizedBox(
              width: itemWidth,
              child: Container(
                height: 468,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: GeneralErrorWidget(
                    errorTitle: "Worm Monitoring not available",
                    errorMessage:
                        "Please check the device connection\nand try again.",
                    errorIcon: FluentIcons.cloud_error_24_regular,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: Container(
                height: 468,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: GeneralErrorWidget(
                    errorTitle: "Camera Feed not found",
                    errorMessage:
                        "Please check the camera connection\nand try again.",
                    errorIcon: FluentIcons.cloud_error_24_regular,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
