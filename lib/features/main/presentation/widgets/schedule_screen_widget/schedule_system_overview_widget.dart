import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/daily_report_widget.dart';
import 'package:http/http.dart' as http;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ScheduleSystemOverviewWidget extends StatefulWidget {
  final CompostSchedule compostSchedule;

  const ScheduleSystemOverviewWidget({
    super.key,
    required this.compostSchedule,
  });

  @override
  State<ScheduleSystemOverviewWidget> createState() =>
      _ScheduleSystemOverviewWidgetState();
}

class _ScheduleSystemOverviewWidgetState
    extends State<ScheduleSystemOverviewWidget> {
  late CompostSchedule _compostSchedule;
  late ToastHelper _toaster;

  late PromptBody _scheduleSummaryResponse;

  bool _responseLoaded = false;
  bool _responseError = false;
  bool _toggledSuggestion = false;

  @override
  void initState() {
    super.initState();
    _compostSchedule = widget.compostSchedule;
    _toaster = ToastHelper(context);
    // _getResponse();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String responseData = _responseLoaded
        ? _toggledSuggestion
            ? _scheduleSummaryResponse.recommendation
            : _scheduleSummaryResponse.insight
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

    InputDecoration transparentInput(BuildContext context) {
      return InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        hintText: "Search, or ask anything",
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontSize: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        border: OutlineInputBorder(borderSide: BorderSide.none),
        contentPadding: EdgeInsets.zero,
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
                        _responseLoaded
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
                      child: Skeletonizer(
                        enabled: !_responseLoaded,
                        child: MarkdownBlock(
                          data: responseData,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_responseLoaded && !_toggledSuggestion)
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
        VerticalDivider(),
        Expanded(
          child: Column(
            children: [
              Expanded(flex: 2, child: Container()),
              Container(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: transparentInput(context),
                    ),
                    Align(
                      alignment: AlignmentGeometry.centerRight,
                      child: IconButton(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            minimumSize: Size.zero,
                            backgroundColor: Colors.white,
                            shape: CircleBorder(),
                          ),
                          icon: Icon(
                            FluentIcons.arrow_up_24_filled,
                            size: 20,
                            color: Colors.grey.shade900,
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> _getResponse() async {
    try {
      final response = await http.post(
        Uri.parse("${AppSecrets.domainURL}/summary/${_compostSchedule.id}"),
      );

      if (response.statusCode == 200) {
        _scheduleSummaryResponse =
            PromptBody.fromJson(jsonDecode(response.body));

        if (!mounted) return;

        setState(() {
          _responseLoaded = true;
          _responseError = false;
        });
      }
    } on ServerException catch (e) {
      if (!mounted) return;

      ToastHelper(context).show(
        title: "Something went wrong",
        description: e.toString(),
        isError: true,
      );

      setState(() {
        _responseError = true;
      });
    } catch (e) {
      if (!mounted) return;

      ToastHelper(context).show(
        title: "Unexpected error has occurred",
        description: e.toString(),
        isError: true,
      );

      setState(() {
        _responseError = true;
      });
    }
  }
}
