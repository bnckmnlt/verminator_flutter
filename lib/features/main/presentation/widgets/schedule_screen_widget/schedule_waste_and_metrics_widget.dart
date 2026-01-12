import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/food_waste/domain/entities/food_waste.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ScheduleWasteAndMetricsWidget extends StatefulWidget {
  final CompostSchedule compostSchedule;
  final List<FoodWaste> foodWasteList;

  const ScheduleWasteAndMetricsWidget({
    super.key,
    required this.compostSchedule,
    required this.foodWasteList,
  });

  @override
  State<ScheduleWasteAndMetricsWidget> createState() =>
      _ScheduleWasteAndMetricsWidgetState();
}

class _ScheduleWasteAndMetricsWidgetState
    extends State<ScheduleWasteAndMetricsWidget> {
  late FocusNode _focusNode;

  late List<FoodWaste> _foodWasteList;

  bool _isRecordSelectionActive = false;
  late Map<String, List<FoodWaste>> _activeRecordSelected;
  late FoodWaste _selectedRecord;

  bool _isImageSelected = false;

  @override
  void initState() {
    super.initState();

    _foodWasteList = widget.foodWasteList;

    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isImageSelected) {
        setState(() => _isImageSelected = false);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classCounts = getCountsPerClass(_foodWasteList);
    final ranges = buildRanges(classCounts);
    final legendItems = buildLegend(context, classCounts);

    Map<String, List<FoodWaste>> feedingRecords =
        parseFoodWasteRecords(_foodWasteList);

    if (mounted) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Row(
          spacing: 14,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                spacing: 14,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: SingleChildScrollView(
                        child: Column(
                          spacing: 24,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: BreadCrumb(
                                    overflow: ScrollableOverflow(
                                      keepLastDivider: false,
                                      reverse: false,
                                      direction: Axis.horizontal,
                                    ),
                                    items: <BreadCrumbItem>[
                                      BreadCrumbItem(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        content: InkWell(
                                          splashFactory: NoSplash.splashFactory,
                                          onTap: () => setState(() =>
                                              _isRecordSelectionActive = false),
                                          child: Text(
                                            'Feeding Records',
                                            style: GoogleFonts.inter(
                                              color: _isRecordSelectionActive
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withAlpha(164)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                              fontSize: 16,
                                              fontWeight:
                                                  _isRecordSelectionActive
                                                      ? FontWeight.normal
                                                      : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_isRecordSelectionActive)
                                        BreadCrumbItem(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          content: Text(
                                            _activeRecordSelected.keys.first,
                                            style: GoogleFonts.inter(
                                              color: _isRecordSelectionActive &&
                                                      !_isImageSelected
                                                  ? Colors.lightBlueAccent
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withAlpha(164),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      if (_isImageSelected &&
                                          _isRecordSelectionActive)
                                        BreadCrumbItem(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          content: Flexible(
                                            child: Text(
                                              _selectedRecord.filePath
                                                  .split("/")
                                                  .last,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: GoogleFonts.inter(
                                                color: _isRecordSelectionActive
                                                    ? Colors.lightBlueAccent
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withAlpha(164),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                    divider: Icon(Icons.chevron_right),
                                  ),
                                ),
                              ],
                            ),
                            if (feedingRecords.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 128.0),
                                  child: EmptyDisplayWidget(
                                    title: "No data to show",
                                    description:
                                        "It may take up to 24 hours for data to refresh. Please try again later.",
                                  ),
                                ),
                              )
                            else if (!_isRecordSelectionActive)
                              _buildFeedingListSection(
                                feedingRecords,
                                (entry) => setState(() {
                                  _isRecordSelectionActive = true;
                                  _activeRecordSelected = {
                                    entry.key: entry.value
                                  };
                                }),
                              )
                            else
                              _buildImageGallerySection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!_isImageSelected && feedingRecords.isNotEmpty) Divider(),
                  if (!_isImageSelected && feedingRecords.isNotEmpty)
                    Column(
                      spacing: 14,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 44),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: legendItems
                                      .map((item) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 44.0,
                                            ),
                                            child:
                                                item.animate().fade().slideY(),
                                          ))
                                      .toList(),
                                )),
                          ),
                        ),
                        SfLinearGauge(
                          showLabels: false,
                          showTicks: false,
                          animateAxis: true,
                          animateRange: true,
                          ranges: ranges,
                        ),
                      ],
                    )
                        .animate()
                        .fade(
                          duration: 700.ms,
                          curve: Curves.easeOut,
                        )
                        .slideY(
                          begin: 0.15,
                          end: 0.0,
                          duration: 750.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.0, 1.0),
                          duration: 500.ms,
                          curve: Curves.easeOut,
                        )
                ],
              ),
            ),
            if (_isImageSelected) VerticalDivider(),
            if (_isImageSelected)
              Expanded(child: _buildImageDetailsSection())
                  .animate()
                  .fade(
                    duration: 700.ms,
                    curve: Curves.easeOut,
                  )
                  .slideX(
                    begin: 0.15,
                    end: 0.0,
                    duration: 750.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .scale(
                    begin: const Offset(0.98, 0.98),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildFeedingListSection(Map<String, List<FoodWaste>> feedingRecords,
      Function(MapEntry<String, List<FoodWaste>>) onClickFunction) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (!hasFocus && _isImageSelected) {
          setState(() => _isImageSelected = false);
        }
      },
      child: Wrap(
        spacing: 16,
        children: feedingRecords.entries.map((item) {
          String date = item.key;
          List<FoodWaste> records = item.value;

          return InkWell(
            onTap: () => onClickFunction(item),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 324,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5),
                          BlendMode.darken,
                        ),
                        child: Image.network(
                          records.last.filePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(0.60),
                              Colors.black.withOpacity(0.50),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Column(
                        children: [
                          SizedBox(height: 64),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  date,
                                  style: GoogleFonts.oswald(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${records.length} item(s)",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.025,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageGallerySection() {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (!hasFocus && _isImageSelected) {
          setState(() => _isImageSelected = false);
        }
      },
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: _activeRecordSelected.entries
            .expand(
              (entry) => entry.value.map(
                (item) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _isImageSelected = true;
                      _selectedRecord = item;
                    });
                    _focusNode.requestFocus();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.filePath,
                      width: 124,
                      height: 124,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildImageDetailsSection() {
    TextStyle itemTextStyle() {
      return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.025,
      );
    }

    final List<Map<String, dynamic>> itemList = [
      {
        'label': 'Filename',
        'widget': Text(
          _selectedRecord.filePath.split("/").last.toString(),
          overflow: TextOverflow.ellipsis,
          style: itemTextStyle(),
        ),
      },
      {
        'label': 'Filetype',
        'widget': Text(
          "image/png",
          style: itemTextStyle(),
        )
      },
      {
        'label': 'Confidence Score',
        'widget': Text(
          "${(_selectedRecord.confidence * 100).toStringAsFixed(2)}% accurate",
          style: itemTextStyle(),
        )
      },
      {
        'label': 'Classname',
        'widget': Text(
          _selectedRecord.classname.label,
          style: itemTextStyle(),
        ),
      },
      {
        'label': 'Status',
        'widget': _selectedRecord.materialStatus.statusWidget,
      },
      {
        'label': 'Loaded at',
        'widget': Text(
          extractDay(_selectedRecord.createdAt, format: 'MM/d/yyyy HH:mm:ss a'),
          style: itemTextStyle(),
        ),
      },
    ];

    final imageProvider = Image.network(
      _selectedRecord.filePath,
      isAntiAlias: true,
    ).image;

    return Column(
      spacing: 24,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: InstaImageViewer(
                backgroundIsTransparent: true,
                child: Image(
                  isAntiAlias: true,
                  errorBuilder: (context, error, stackTrace) {
                    return EmptyDisplayWidget(
                      icon: FluentIcons.image_prohibited_24_regular,
                      title: "Unable to Display File",
                      description:
                          "The requested source file could not be loaded. It may be missing or there was an error accessing it.",
                    );
                  },
                  image: imageProvider,
                ),
              )
                  .animate()
                  .fade(
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  )
                  .scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                  )
                  .slideY(
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                    begin: 0.05,
                    end: 0,
                  ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: 18,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Image Details",
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.025,
                  ),
                ),
                Column(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  children: itemList.map((item) {
                    String label = item["label"];
                    Widget itemWidget = item["widget"];

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Text(
                          label,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(164),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                        Expanded(
                          child: itemWidget,
                        )
                      ],
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Map<String, List<FoodWaste>> parseFoodWasteRecords(List<FoodWaste> records) {
  return records.fold<Map<String, List<FoodWaste>>>(
    {},
    (acc, curr) {
      final dt = extractDay(curr.createdAt, format: "MMMM d");

      acc.putIfAbsent(dt, () => []);
      acc[dt]!.add(curr);

      return acc;
    },
  );
}

Map<FoodWasteClassname, int> getCountsPerClass(List<FoodWaste> list) {
  final Map<FoodWasteClassname, int> counts = {};

  for (final item in list) {
    counts[item.classname] = (counts[item.classname] ?? 0) + 1;
  }

  return counts;
}

List<LinearGaugeRange> buildRanges(Map<FoodWasteClassname, int> classCounts) {
  final int total = classCounts.values.fold(0, (a, b) => a + b);
  double start = 0;

  final entries = classCounts.entries.toList();

  return List.generate(entries.length, (index) {
    final entry = entries[index];
    final percentage = (entry.value / total) * 100;

    final edgeStyle = (index == 0)
        ? LinearEdgeStyle.startCurve
        : (index == entries.length - 1)
            ? LinearEdgeStyle.endCurve
            : LinearEdgeStyle.bothFlat;

    final range = LinearGaugeRange(
      position: LinearElementPosition.cross,
      edgeStyle: edgeStyle,
      startValue: start,
      endValue: start + percentage,
      startWidth: 10,
      endWidth: 10,
      color: Colors.accents[index % Colors.accents.length],
    );

    start += percentage;
    return range;
  });
}

List<Widget> buildLegend(
    BuildContext context, Map<FoodWasteClassname, int> classCounts) {
  final entries = classCounts.entries.toList();
  final int total = classCounts.values.fold(0, (a, b) => a + b);

  return List.generate(entries.length, (index) {
    final entry = entries[index];
    final color = Colors.accents[index % Colors.accents.length];
    final count = entry.value;
    final percentage = total > 0 ? (count / total) * 100 : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key.label,
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
                letterSpacing: 0.025,
                height: 0.73,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$count item(s)",
                  textHeightBehavior: TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: GoogleFonts.inter(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(124),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  });
}
