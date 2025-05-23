import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_initialization/initialization_waiting_screen.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController _scheduleIdentifierController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final deviceHeight = constraints.maxHeight;
      final deviceWidth = constraints.maxWidth;
      bool isDark =
          MediaQuery.of(context).platformBrightness == Brightness.dark;

      return Scaffold(
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
      );
    });
  }
}
