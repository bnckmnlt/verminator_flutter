import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/core/theme/styles/button_styles.dart';
import 'package:flutter_vermicomposting/core/theme/styles/text_styles.dart';
import 'package:flutter_vermicomposting/core/utils/extract_by_day.dart';
import 'package:flutter_vermicomposting/core/utils/parse_error_message.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/data/models/compost_schedule_model.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/output_validation/validation_instruction.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleScreenHeaderWidget extends StatefulWidget {
  final CompostSchedule compostSchedule;
  final MqttService mqttService;

  const ScheduleScreenHeaderWidget({
    super.key,
    required this.mqttService,
    required this.compostSchedule,
  });

  @override
  State<ScheduleScreenHeaderWidget> createState() =>
      _ScheduleScreenHeaderWidgetState();
}

class _ScheduleScreenHeaderWidgetState
    extends State<ScheduleScreenHeaderWidget> {
  late CompostSchedule _compostSchedule;

  final formKey = GlobalKey<FormState>();
  final TextEditingController scheduleIdentifierController =
      TextEditingController();

  late ToastHelper _toaster;

  @override
  void initState() {
    super.initState();

    _compostSchedule = widget.compostSchedule;
  }

  bool _isReadyToComplete = false;
  bool _readyForValidation = false;

  @override
  Widget build(BuildContext context) {
    _toaster = ToastHelper(context);

    TextStyle mutedTextStyle(BuildContext context) {
      return TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
        letterSpacing: 0.025,
      );
    }

    return Expanded(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 64,
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(64),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/icons/verminator_logo.png",
                        fit: BoxFit.contain,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _compostSchedule.scheduleName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            "Vermicomposting - Schedule",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(164),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      if (_compostSchedule.isCompleted)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade100.withAlpha(24),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            spacing: 4,
                            children: [
                              Icon(
                                FluentIcons.checkmark_24_filled,
                                size: 20,
                                color: Colors.greenAccent,
                              ),
                              Text(
                                "COMPLETED",
                                style: GoogleFonts.spaceMono(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.025,
                                ),
                              ),
                            ],
                          )
                              .animate(delay: Duration(milliseconds: 1 * 50))
                              .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                              .slideX(
                                duration: 700.ms,
                                begin: 0.1,
                                end: 0,
                                curve: Curves.easeOutCubic,
                              ),
                        )
                    ],
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  BlocBuilder<StatusRecordBloc, StatusRecordState>(
                    builder: (ctx, state) {
                      if (state is StatusRecordListSuccess) {
                        final statusList = state.statusRecordList
                            .where(
                              (status) =>
                                  status.scheduleId ==
                                  widget.compostSchedule.id,
                            )
                            .toList();

                        if (statusList.isNotEmpty) {
                          final firstStatus = statusList.first;

                          _isReadyToComplete =
                              firstStatus.status == CompostingStatus.released &&
                                  firstStatus.isCompleted == false;

                          _readyForValidation =
                              firstStatus.status == CompostingStatus.released &&
                                  firstStatus.isCompleted == true;
                        }
                      }

                      return _isReadyToComplete
                          ? OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                side: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                  horizontal: 14,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _handleEndSchedule(_toaster),
                              child: Row(
                                spacing: 6,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FluentIcons
                                        .task_list_square_database_20_regular,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.8),
                                    size: 14,
                                  ),
                                  Text(
                                    "End Schedule",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      letterSpacing: 0.025,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : !_readyForValidation
                              ? SizedBox.shrink()
                              : ElevatedButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ValidationInstruction(
                                        scheduleId: widget.compostSchedule.id,
                                      ),
                                    ),
                                  ),
                                  style: AppButtonStyles.of(
                                      context: context,
                                      variant: AppButtonVariant.primary),
                                  child: Text(
                                    "Soil and Vermitea Validation",
                                    style: AppTextStyles.paragraphSemibold(
                                            context: context, size: 14)
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                  ),
                                );
                    },
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                    ),
                    onPressed: () => _handleChangeScheduleName(_toaster),
                    icon: Icon(FluentIcons.edit_24_regular),
                  ),
                ],
              )
            ],
          ),
          _startEndDateHeader(mutedTextStyle(context)),
        ],
      ),
    );
  }

  Widget _startEndDateHeader(TextStyle textStyle) {
    final startDate = DateTime.parse(_compostSchedule.createdAt).toLocal();
    final expectedEndDate = startDate.add(const Duration(days: 45));

    Widget buildIconText({required IconData icon, required String text}) {
      return Row(
        spacing: 6,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
          ),
          Text(text, style: textStyle),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 14,
        children: [
          buildIconText(
            icon: FluentIcons.calendar_empty_24_regular,
            text:
                "Start: ${extractDay(startDate.toString(), format: "MMM d, y")}",
          ),
          buildIconText(
            icon: FluentIcons.target_arrow_24_regular,
            text:
                "Expected End: ${extractDay(expectedEndDate.toString(), format: "MMM d, y")}",
          ),
        ],
      ),
    );
  }

  void _handleChangeScheduleName(ToastHelper toastHelper) {
    showDialog(
      context: context,
      builder: (context) {
        return GeneralDialog(
          title: 'Change compost schedule name',
          description: 'Modify your schedule name (e.g., Backyard Pile 1)',
          confirmButtonLabel: 'Continue',
          widget: Form(
            key: formKey,
            child: TextFormField(
              controller: scheduleIdentifierController,
              validator: (value) {
                if (value!.isEmpty || value.length <= 8) {
                  return "Compost schedule name is invalid";
                }
                return null;
              },
            ),
          ),
          approvedFunction: () async {
            if (formKey.currentState!.validate()) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GeneralDialog(
                    title: 'Change schedule name?',
                    description:
                        'Would you change the schedule name to ${scheduleIdentifierController.text}?',
                    confirmButtonLabel: 'Confirm',
                    approvedFunction: () async {
                      final response = await http.patch(
                        Uri.parse(
                          "${AppSecrets.domainURL}/schedule/${_compostSchedule.id}",
                        ),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(<String, dynamic>{
                          'scheduleName':
                              scheduleIdentifierController.text.trim(),
                        }),
                      );

                      if (response.statusCode == 200) {
                        final compostSchedule = CompostScheduleModel.fromJson(
                          jsonDecode(response.body),
                        );
                        toastHelper.show(
                          title: "Successfully updated",
                          description:
                              "Successfully updated schedule name to ${compostSchedule.scheduleName}",
                          isError: false,
                        );
                        context.read<CompostScheduleBloc>().add(
                              CompostScheduleList(),
                            );
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).popUntil((route) => route is PageRoute);
                      } else {
                        toastHelper.show(
                          title: "An error has occurred",
                          description: response.body.parseErrorMessage(),
                          isError: true,
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  void _handleEndSchedule(ToastHelper toastHelper) async {
    final rootContext = context;
    final MqttService mqttService = widget.mqttService;
    final SupabaseClient supabase = GetIt.instance<SupabaseClient>();
    final now = DateTime.now().toIso8601String();

    showDialog(
      context: rootContext,
      builder: (BuildContext dialogContext) {
        return GeneralDialog(
          title: 'Finalize Vermicomposting Cycle',
          description:
              'Are you sure you want to mark this vermicomposting cycle as complete? This action will finalize all associated data',
          confirmButtonLabel: 'Confirm',
          approvedFunction: () async {
            Navigator.of(dialogContext).pop();
            await Future.delayed(const Duration(milliseconds: 150));

            showDialog(
              context: rootContext,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
              useRootNavigator: true,
            );

            Future<void> fail(String title, String message) async {
              Navigator.of(rootContext, rootNavigator: true).pop();
              toastHelper.show(
                title: title,
                description: message,
                isError: true,
              );
            }

            try {
              final scheduleUri = Uri.parse(
                "${AppSecrets.domainURL}/schedule/${widget.compostSchedule.id}",
              );

              final compostWeight = mqttService
                      .lastBeddingLayer?["compost_weight"]?["value"]
                      ?.toString() ??
                  '0';

              final juiceWeight = mqttService.lastFluidLayer?["juice_weight"]
                          ?["value"]
                      ?.toString() ??
                  '0';

              final schedulePayload = {
                'compostProduced': compostWeight,
                'juiceProduced': juiceWeight,
                'isCompleted': true,
                'dateReleased': now,
              };

              final scheduleResponse = await http.patch(
                scheduleUri,
                headers: {'Content-Type': 'application/json; charset=UTF-8'},
                body: jsonEncode(schedulePayload),
              );

              if (scheduleResponse.statusCode != 200) {
                await fail(
                  "Schedule update failed",
                  scheduleResponse.body.parseErrorMessage(),
                );
                return;
              }

              await supabase
                  .from("status_records")
                  .update({"is_completed": true})
                  .eq('status_schedule_id', widget.compostSchedule.id)
                  .eq('status', 'released');

              final notificationPayload = {
                "schedule_id": widget.compostSchedule.id,
                "notification_type": "completion",
                "subject": "Compost finished",
                "description":
                    "${widget.compostSchedule.scheduleName} has been completed with ${juiceWeight}L of vermitea and ${compostWeight}kg of compost produced.",
                "path": null,
              };

              await supabase.from("notification").insert(notificationPayload);

              final settingsPayload = {
                "status": "idle",
                "id": 0,
                "reading_interval": "15",
                "refresh_rate": "2",
              };

              mqttService.publish(
                "system/settings",
                jsonEncode(settingsPayload),
                qos: MqttQos.atLeastOnce,
                retain: true,
              );

              Navigator.of(rootContext, rootNavigator: true).pop();

              toastHelper.show(
                title: "Cycle Finalized",
                description:
                    "The vermicomposting cycle has been successfully completed and recorded.",
                isError: false,
              );

              context.read<CompostScheduleBloc>().add(CompostScheduleList());
              context.read<StatusRecordBloc>().add(StatusRecordList());

              await Future.delayed(const Duration(milliseconds: 100));

              Navigator.of(
                rootContext,
                rootNavigator: true,
              ).popUntil((route) => route is PageRoute);
            } catch (e) {
              await fail("Unexpected Error", e.toString());
            }
          },
        );
      },
    );
  }
}
