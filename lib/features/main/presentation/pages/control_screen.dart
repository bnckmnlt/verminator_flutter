import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/control_screen_widgets/conveyor_control_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/control_screen_widgets/pump_control_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/control_screen_widgets/rake_control_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/control_screen_widgets/sensor_with_duration_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/control_screen_widgets/sifter_control_widget.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';

// TODO: [✅] DONEEEEE

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late MqttService _mqttService;
  late List<SensorControl> _sensorsList;

  @override
  void initState() {
    super.initState();

    _mqttService = GetIt.I<MqttService>();

    _sensorsList = [
      SensorControl(
        device: "Dual 150x150mm Fan",
        label: "Ambient Aeration Control",
        icon: CupertinoIcons.wind,
        state: false,
        topic: "control/fan",
      ),
      SensorControl(
        device: "Dual 150x150mm Fan",
        label: "Soil Aeration Control",
        icon: CupertinoIcons.wind_snow,
        state: false,
        topic: "control/aeration",
      ),
      SensorControl(
        device: " 12V Pump",
        label: "Conveyor Misting Control",
        icon: CupertinoIcons.wind_snow,
        state: false,
        topic: "control/misting",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double deviceHeight = MediaQuery.of(context).size.height;
        final double deviceWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme:
                IconThemeData(color: Theme.of(context).colorScheme.onSurface),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: Container(
            height: deviceHeight,
            width: deviceWidth,
            padding: const EdgeInsets.fromLTRB(44, 64, 44, 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Control Hub",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Easily manage and monitor system actions using the controls below",
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(186),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 44),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: PumpControlWidget(
                          mqttService: _mqttService,
                        ),
                      ),
                      ..._sensorsList.map((item) {
                        return Expanded(
                          child: SensorWithDurationWidget(
                            sensorData: item,
                            label: item.label,
                            device: item.device,
                            mqttService: _mqttService,
                            topic: item.topic,
                          ),
                        );
                      })
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                                child: RakeControlWidget(
                              mqttService: _mqttService,
                            )),
                            Expanded(
                                child: SifterControlWidget(
                              mqttService: _mqttService,
                            )),
                            Expanded(
                                child: ConveyorControlWidget(
                              mqttService: _mqttService,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget sensorCardHeader({
  required BuildContext context,
  required String label,
  required String device,
  Widget? optionalWidget,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            device,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
              fontSize: 10,
            ),
          ),
        ],
      ),
      if (optionalWidget != null) optionalWidget,
    ],
  );
}
