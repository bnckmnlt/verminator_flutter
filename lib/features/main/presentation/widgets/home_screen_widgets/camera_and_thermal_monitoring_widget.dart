import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/video_feed_widget.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraAndThermalMonitoringWidget extends StatefulWidget {
  const CameraAndThermalMonitoringWidget({super.key});

  @override
  State<CameraAndThermalMonitoringWidget> createState() =>
      _CameraAndThermalMonitoringWidgetState();
}

class _CameraAndThermalMonitoringWidgetState
    extends State<CameraAndThermalMonitoringWidget> {
  late MqttService _mqttService;

  WebViewController? cameraFeedController;
  WebViewController? thermalFeedController;

  bool cameraState = false;
  bool thermalCameraState = false;

  int visionCurrentTab = 0;

  @override
  void initState() {
    _mqttService = GetIt.instance<MqttService>();

    _mqttService.controlCameraStream.listen((value) {
      setState(() {
        cameraState = value == 'active' ? true : false;
      });
    });

    _mqttService.controlThermalStream.listen((value) {
      setState(() {
        thermalCameraState = value == 'active' ? true : false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cameraParameterList = [
      {
        "controller": cameraFeedController,
        "state": cameraState,
      },
      {
        "controller": thermalFeedController,
        "state": thermalCameraState,
      },
    ];

    bool state = cameraParameterList[visionCurrentTab]["state"];
    String source = Constants.serverList[visionCurrentTab]['src'];
    String topic = Constants.serverList[visionCurrentTab]['topic'];

    List<Map<String, dynamic>> buttonFunctions = [
      {
        "icon": FluentIcons.power_24_filled,
        "function": () {
          _mqttService.publish(
              topic,
              (visionCurrentTab == 0 ? cameraState : thermalCameraState)
                  ? "inactive"
                  : "active",
              qos: MqttQos.atLeastOnce,
              retain: true);
        }
      },
      {
        "icon": FluentIcons.arrow_sync_24_filled,
        "function": () =>
            reloadWebView(cameraParameterList[visionCurrentTab]['controller']),
      },
    ];

    return SizedBox(
      width: 640,
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Computer Vision and Thermal Feed",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Column(
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  spacing: 14,
                  children: Constants.serverList.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Map<String, dynamic> item = entry.value;

                    bool activeTab = visionCurrentTab == index;

                    return GestureDetector(
                      onTap: () => setState(() => visionCurrentTab = index),
                      child: Row(
                        spacing: 8,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: activeTab
                                ? Container(
                                    key: const ValueKey('dot'),
                                    height: 6,
                                    width: 6,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: activeTab
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(124),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            child: Text(item['label']),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                height: 475,
                width: 640,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow
                        .withAlpha(124),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      width: 2,
                    )),
                child: Stack(
                  children: [
                    state
                        ? VideoFeedWidget(
                            onWebViewCreated: (controller) {
                              cameraParameterList[visionCurrentTab]
                                  ["controller"] = controller;
                            },
                            cameraChannel: source,
                          )
                        : Center(
                            child: EmptyDisplayWidget(
                              title: "Inactive Device",
                              description:
                                  "The device is currently not operational or has no active session.",
                            ),
                          ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withAlpha(32),
                              )),
                          child: Row(
                            spacing: 6,
                            children: [
                              Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      state ? Colors.redAccent : Colors.white,
                                ),
                              ),
                              Text(
                                "LIVE",
                                style: TextStyle(
                                  color:
                                      state ? Colors.redAccent : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Row(
                        spacing: 8,
                        children: List.generate(2, (int index) => index)
                            .asMap()
                            .entries
                            .map((entry) {
                          final int index = entry.key;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Material(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withAlpha(32),
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: buttonFunctions[index]['function'],
                                splashColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                highlightColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Icon(
                                    buttonFunctions[index]['icon'],
                                    size: 24,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void reloadWebView(WebViewController? _webViewController) {
    _webViewController?.reload();
  }
}
