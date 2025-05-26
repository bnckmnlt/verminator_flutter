import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';

class PumpControlWidget extends StatefulWidget {
  const PumpControlWidget({super.key});

  @override
  State<PumpControlWidget> createState() => _PumpControlWidgetState();
}

class _PumpControlWidgetState extends State<PumpControlWidget> {
  late List<SensorControl> pumpControlList;

  @override
  void initState() {
    super.initState();
    pumpControlList = [
      SensorControl(
        device: "Pump",
        label: "Bedding Hydration",
        icon: Icons.water_drop_outlined,
        state: false,
      ),
      SensorControl(
        device: "Pump",
        label: "Vermijuice Dispenser",
        icon: FluentIcons.drink_bottle_20_regular,
        state: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: pumpControlList.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 214,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item.icon),
                      SizedBox(
                        height: 24,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Switch(
                            value: item.state,
                            onChanged: (bool value) {
                              setState(() {
                                pumpControlList[i] = SensorControl(
                                  device: item.device,
                                  label: item.label,
                                  icon: item.icon,
                                  state: value,
                                );
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  sensorCardHeader(
                    context: context,
                    label: item.label,
                    device: item.device,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
