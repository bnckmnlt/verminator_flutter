import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vermicomposting/core/common/widgets/app_background.dart';
import 'package:flutter_vermicomposting/core/common/widgets/dialog.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/common/widgets/loader.dart';
import 'package:flutter_vermicomposting/core/common/widgets/toast_helper.dart';
import 'package:flutter_vermicomposting/core/error/exception.dart';
import 'package:flutter_vermicomposting/core/secrets/app_secrets.dart';
import 'package:flutter_vermicomposting/core/theme/styles/button_styles.dart';
import 'package:flutter_vermicomposting/core/theme/styles/text_styles.dart';
import 'package:flutter_vermicomposting/features/compost_output/data/model/CompostOutputModel.dart';
import 'package:flutter_vermicomposting/features/compost_output/domain/entities/compost_output.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/output_validation/validation_result.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/daily_report_widget.dart';
import 'package:flutter_vermicomposting/mqtt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:typed_data/src/typed_buffer.dart';
import 'package:http/http.dart' as http;

class ValidationInstruction extends StatefulWidget {
  final int scheduleId;

  const ValidationInstruction({
    super.key,
    required this.scheduleId,
  });

  @override
  State<ValidationInstruction> createState() => _ValidationInstructionState();
}

class _ValidationInstructionState extends State<ValidationInstruction> {
  bool _isValidating = false;
  bool _responseLoaded = false;

  late MqttService _mqttClient;
  late SupabaseClient _supabaseClient;
  late PromptBody _scheduleSummaryResponse;

  StreamSubscription<List<Map<String, dynamic>>>? _compostOutputSubscription;

  late CompostOutput _compostOutput;

  @override
  void initState() {
    super.initState();
    _mqttClient = GetIt.I<MqttService>();
    _supabaseClient = GetIt.I<SupabaseClient>();
  }

  @override
  void dispose() {
    _compostOutputSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    double horizontalPadding = width * 0.05;
    double verticalPadding = height * 0.05;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Glassmorphism(
        blur: 64,
        opacity: 0.3,
        child: AppBackground(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            child: _isValidating
                ? Loader()
                : Column(
                    children: [
                      _buildImageSection(),
                      _buildDescriptionAndActionSection(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Expanded(
      flex: 3,
      child: Image.asset(
        "assets/images/npk-sensor.png",
        fit: BoxFit.contain,
      )
          .animate()
          .fadeIn(duration: 900.ms, curve: Curves.easeOut)
          .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildDescriptionAndActionSection() {
    return Expanded(
      flex: 2,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width * 0.2,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              spacing: 28,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  spacing: 24,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      "Post-Harvest Nutrient and Vermitea Assessment",
                      style: AppTextStyles.h3,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                        .blurXY(
                            begin: 4,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOut),
                    Text(
                      textAlign: TextAlign.center,
                      "Carefully remove the NPK sensor from the bedding layer and place it on top of the soil in the compost container to measure the final nutrient composition of the produced compost. At the same time, the system will assess the quality of the collected vermitea.\n\nEnsure that the sensor is properly positioned and stable before taking readings to maintain accuracy. Once all components are set and ready, press the button below to proceed.",
                      style: AppTextStyles.paragraph(context: context),
                    )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                        .blurXY(
                            begin: 6,
                            end: 0,
                            duration: 700.ms,
                            curve: Curves.easeOut),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return GeneralDialog(
                            title: "Ready to Start Assessment?",
                            description:
                                "Make sure the NPK sensor is properly placed on top of the compost and that the vermitea collection is ready. The system will begin measuring nutrient levels and vermitea quality once you confirm.\n\nThis process cannot be interrupted once started.",
                            confirmButtonLabel: "Start Assessment",
                            approvedFunction: () => {
                              Navigator.pop(context),
                              _getResponse(),
                              _startValidation(),
                            },
                          );
                        });
                  },
                  style: AppButtonStyles.of(
                      context: context, variant: AppButtonVariant.primary),
                  child: Text(
                    "Start Assessment",
                    style: AppTextStyles.paragraphSemibold(
                            context: context, size: 14)
                        .copyWith(
                            color: Theme.of(context).colorScheme.onSurface),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startValidation() {
    setState(() => _isValidating = true);
    _mqttClient.publish("system/compost", "${widget.scheduleId}:Get");

    _compostOutputSubscription = _supabaseClient
        .from('compost_output')
        .stream(primaryKey: ['id'])
        .gte('released_at', DateTime.now().toUtc().toIso8601String())
        .order('released_at')
        .listen((data) {
          if (data.isEmpty) return;

          _compostOutput = CompostOutputModel.fromJson(data.first);
          _compostOutputSubscription?.cancel();

          _navigateIfReady();
        });
  }

  Future<void> _getResponse() async {
    try {
      final response = await http.post(
        Uri.parse("${AppSecrets.domainURL}/validation/${widget.scheduleId}"),
      );

      if (response.statusCode == 200) {
        _scheduleSummaryResponse =
            PromptBody.fromJson(jsonDecode(response.body));
        _responseLoaded = true;

        _navigateIfReady();
      } else {
        _handleValidationError(
            "Server returned ${response.statusCode}. Please try again.");
      }
    } on ServerException catch (e) {
      _handleValidationError(e.toString());
    } catch (e) {
      _handleValidationError(e.toString());
    }
  }

  void _navigateIfReady() {
    if (!_responseLoaded || _compostOutput == null) return;
    if (!mounted) return;

    setState(() => _isValidating = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ValidationResult(
          compostOutput: _compostOutput,
          summaryResponse: _scheduleSummaryResponse,
        ),
      ),
    );
  }

  void _handleValidationError(String message) {
    _compostOutputSubscription?.cancel();

    if (!mounted) return;

    setState(() => _isValidating = false);

    ToastHelper(context).show(
      title: "Assessment Failed",
      description: message,
      isError: true,
    );
  }
}
