import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/daily_report_widget.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ScheduleSystemOverviewWidget extends StatefulWidget {
  final CompostSchedule compostSchedule;
  final PromptBody scheduleSummaryResponse;
  final bool responseLoaded;

  const ScheduleSystemOverviewWidget({
    super.key,
    required this.compostSchedule,
    required this.scheduleSummaryResponse,
    required this.responseLoaded,
  });

  @override
  State<ScheduleSystemOverviewWidget> createState() =>
      _ScheduleSystemOverviewWidgetState();
}

class _ScheduleSystemOverviewWidgetState
    extends State<ScheduleSystemOverviewWidget>
    with AutomaticKeepAliveClientMixin {
  bool _toggledSuggestion = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(ScheduleSystemOverviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.responseLoaded != oldWidget.responseLoaded &&
        widget.responseLoaded) {
      setState(() {
        _toggledSuggestion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final String responseData = widget.responseLoaded
        ? _toggledSuggestion
            ? widget.scheduleSummaryResponse.recommendation
            : widget.scheduleSummaryResponse.insight
        : "Preparing your summary... This may take a little longer than usual as the AI analyzes the data to generate insights.";

    TextStyle responseTextStyle(BuildContext context) {
      return TextStyle(
        fontSize: 16,
        height: 1.6,
      );
    }

    ButtonStyle outlinedButtonStyle(BuildContext context) {
      return OutlinedButton.styleFrom(
        elevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(96),
        ),
      );
    }

    return Row(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              spacing: 24,
              children: [
                Column(
                  spacing: 18,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 14,
                      children: [
                        if (_toggledSuggestion)
                          InkWell(
                              onTap: () => setState(() {
                                    _toggledSuggestion = !_toggledSuggestion;
                                  }),
                              child: Icon(FluentIcons.chevron_left_24_filled)),
                        widget.responseLoaded
                            ? Text(
                                "SCHEDULE SUMMARY ${_toggledSuggestion ? "SUGGESTIONS" : "INSIGHTS"}",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(164),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : Row(
                                spacing: 12,
                                children: [
                                  Icon(
                                    FluentIcons.sparkle_24_filled,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(164),
                                  ),
                                  Text(
                                    "Your summary is on the way. Model is evaluating parameters",
                                    style: responseTextStyle(context).copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(164),
                                    ),
                                  ),
                                ],
                              )
                                .animate()
                                .fade(delay: Duration(milliseconds: 300))
                                .then()
                                .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true),
                                )
                                .tint(
                                  color: Colors.lightBlueAccent,
                                  duration: 1600.ms,
                                  curve: Curves.easeInOut,
                                ),
                      ],
                    ),
                    SizedBox(
                      key: ValueKey(
                          '${widget.responseLoaded}_$_toggledSuggestion'),
                      child: Skeletonizer(
                        enabled: !widget.responseLoaded,
                        child: MarkdownBlock(
                          data: responseData,
                        )
                            .animate(delay: Duration(milliseconds: 2 * 50))
                            .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                            .slideX(
                              duration: 700.ms,
                              begin: 0.1,
                              end: 0,
                              curve: Curves.easeOutCubic,
                            ),
                      ),
                    ),
                  ],
                ),
                if (widget.responseLoaded && !_toggledSuggestion)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IntrinsicWidth(
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _toggledSuggestion = true;
                        }),
                        style: outlinedButtonStyle(context),
                        child: Row(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              FluentIcons.folder_24_regular,
                              size: 22,
                              color: Colors.blue,
                            ),
                            Text(
                              "View suggestions for the next composting schedule",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
