import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/domain/entities/compost_schedule.dart';
import 'package:intl/intl.dart';

class SystemScheduleHeaderSection extends StatefulWidget {
  final CompostSchedule compostSchedule;

  const SystemScheduleHeaderSection({super.key, required this.compostSchedule});

  @override
  State<SystemScheduleHeaderSection> createState() =>
      _SystemScheduleHeaderSectionState();
}

class _SystemScheduleHeaderSectionState
    extends State<SystemScheduleHeaderSection> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController scheduleIdentifierController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat("d MMM yyyy, hh:mm")
        .format(DateTime.parse(widget.compostSchedule.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.compostSchedule.scheduleName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return GeneralDialog(
                        title: 'Change compost schedule name',
                        description:
                            'Modify your schedule name (e.g., Backyard Pile 1)',
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
                        approvedFunction: () {
                          if (formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return GeneralDialog(
                                  title: 'Change schedule name?',
                                  description:
                                      'Would you change the schedule name to ${scheduleIdentifierController.text}?',
                                  confirmButtonLabel: 'Confirm',
                                  approvedFunction: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .popUntil(
                                            (route) => route is! PopupRoute);
                                  },
                                );
                              },
                            );
                          }
                        },
                      );
                    });
              },
              child: Icon(
                FluentIcons.edit_24_regular,
                color: Constants().textMutedFgDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.calendar_16_regular,
              color: Constants().textMutedFgDark,
              size: 18,
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2.5),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  color: Constants().textMutedFgDark,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
