import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/food_waste/data/models/food_waste_model.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SystemImageDetails extends StatefulWidget {
  final FoodWasteModel foodWaste;
  final void Function() onShowDetails;

  const SystemImageDetails({
    super.key,
    required this.onShowDetails,
    required this.foodWaste,
  });

  @override
  State<SystemImageDetails> createState() => _SystemImageDetailsState();
}

class _SystemImageDetailsState extends State<SystemImageDetails> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> itemList = [
      {'label': 'Filetype', 'widget': Text("image/png")},
      {
        'label': 'Confidence Score',
        'widget': Text(
          widget.foodWaste.confidence.toStringAsFixed(2),
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.025,
          ),
        )
      },
      {
        'label': 'Classname',
        'widget': _getClassnameWidget(
          widget.foodWaste.materialStatus,
          widget.foodWaste.classname,
        )
      },
      {
        'label': 'Status',
        'widget': _getStatusBadge(
          widget.foodWaste.materialStatus,
        )
      },
      {
        'label': 'Loaded at',
        'widget': Text(
          DateFormat('MM/d/yyyy HH:mm:ss a')
              .format(DateTime.parse(widget.foodWaste.createdAt))
              .toString(),
        ),
      },
    ];

    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 248,
                    child: Text(
                      widget.foodWaste.filePath.split("/").last.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.025,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onShowDetails,
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(124),
                    ),
                  ),
                ],
              ),
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                )),
                child: Image.network(
                  widget.foodWaste.filePath,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Image Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                ),
                child: Column(children: [
                  ...itemList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['label'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(124),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            item['widget']
                          ],
                        ),
                        if (index != itemList.length - 1)
                          Divider(
                            height: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                          ),
                      ],
                    );
                  }),
                ]),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _getClassnameWidget(
      MaterialStatus status, FoodWasteClassname classname) {
    IconData icon;
    MaterialAccentColor color;

    switch (status) {
      case MaterialStatus.valid:
        icon = FluentIcons.food_apple_24_regular;
        color = Colors.blueAccent;
        break;

      case MaterialStatus.controlled:
        icon = FluentIcons.plant_grass_24_regular;
        color = Colors.greenAccent;
        break;

      default:
        icon = FluentIcons.prohibited_24_regular;
        color = Colors.redAccent;
        break;
    }

    final formattedName = classname.name
        .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');

    return Row(
      spacing: 6,
      children: [
        Icon(icon, size: 14, color: color),
        Text(
          formattedName,
          style: GoogleFonts.spaceMono(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.025,
          ),
        ),
      ],
    );
  }

  Widget _getStatusBadge(MaterialStatus status) {
    MaterialAccentColor color;
    Color fgColor;

    if (status == MaterialStatus.valid) {
      color = Colors.greenAccent;
      fgColor = Colors.black;
    } else if (status == MaterialStatus.controlled) {
      color = Colors.amberAccent;
      fgColor = Colors.black;
    } else {
      color = Colors.redAccent;
      fgColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: fgColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.025,
        ),
      ),
    );
  }
}
