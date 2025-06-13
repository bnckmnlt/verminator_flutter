import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/status_badge.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';
import 'package:flutter_vermicomposting/core/utils/string_extensions.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_waiting_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_screen.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _scheduleIdentifierController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GeneralDialog(
                    title: 'Create compost schedule',
                    description:
                        'Give your composting cycle a name (e.g., Backyard Pile 1)',
                    confirmButtonLabel: 'Continue',
                    widget: Form(
                      key: formKey,
                      child: TextFormField(
                        controller: _scheduleIdentifierController,
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
                              title: 'Begin monitoring',
                              description:
                                  'Would you like to begin tracking ${_scheduleIdentifierController.text}?',
                              confirmButtonLabel: 'Confirm',
                              approvedFunction: () {
                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        InitializationWaitingScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                });
          },
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<CompostScheduleBloc, CompostScheduleState>(
          builder: (context, state) {
            if (state is CompostScheduleLoading) {
              return Center(
                child: Loader(),
              );
            } else if (state is CompostScheduleFailure) {
              return EmptyDisplayWidget(
                description: state.error,
                title: 'An error has occurred',
                icon: FluentIcons.cloud_error_24_regular,
              );
            } else if (state is CompostScheduleListSuccess) {
              return BlocBuilder<StatusRecordBloc, StatusRecordState>(
                  builder: (context, statusState) {
                if (statusState is StatusRecordLoading) {
                  return Center(
                    child: Loader(),
                  );
                } else if (statusState is StatusRecordFailure) {
                  return EmptyDisplayWidget(
                    description: statusState.error,
                    title: 'An error has occurred',
                    icon: FluentIcons.cloud_error_24_regular,
                  );
                } else if (statusState is StatusRecordListSuccess) {
                  final statusList = statusState.statusRecordList
                      .where((status) => status.scheduleId == 1)
                      .toList()
                    ..sort((a, b) => DateTime.parse(b.createdAt)
                        .compareTo(DateTime.parse(a.createdAt)));

                  if (statusList.isEmpty) return const SizedBox();

                  final firstStatus = statusList.first;
                  final isCompleted = firstStatus.isCompleted;

                  final progressValue = _getProgressValue(firstStatus.status);

                  return Container(
                    height: deviceHeight,
                    width: deviceWidth,
                    padding: const EdgeInsets.fromLTRB(44, 64, 44, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _headerSection(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: state.compostScheduleList.length,
                            itemBuilder: (context, index) {
                              final schedule = state.compostScheduleList[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ScheduleScreen(
                                              scheduleId: schedule.id)));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      width: 1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHigh,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              schedule.scheduleName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          StatusBadge(
                                            color: !schedule.isCompleted
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                            state: !schedule.isCompleted
                                                ? "Active"
                                                : "Inactive",
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 8,
                                        children: [
                                          Row(
                                            spacing: 2,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Progress",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Constants()
                                                      .textMutedFgDark,
                                                ),
                                              ),
                                              Text(
                                                firstStatus.status.name
                                                    .firstLetterUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.025,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              minHeight: 6,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHigh,
                                              color: isCompleted
                                                  ? Colors.blueAccent
                                                  : Colors.grey,
                                              value: progressValue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Compost",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Constants()
                                                      .textMutedFgDark,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.025,
                                                ),
                                              ),
                                              Text(
                                                "${schedule.juiceProduced.toString()}kg",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Vermitea",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Constants()
                                                      .textMutedFgDark,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.025,
                                                ),
                                              ),
                                              Text(
                                                "${schedule.juiceProduced.toString()}L",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  );
                }

                return const SizedBox();
              });
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Text(
      "Compost Schedule List",
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

double _getProgressValue(CompostingStatus status) {
  switch (status) {
    case CompostingStatus.initial:
      return 0.25;
    case CompostingStatus.active:
      return 0.50;
    case CompostingStatus.ready:
      return 0.75;
    case CompostingStatus.released:
      return 1.0;
  }
}
