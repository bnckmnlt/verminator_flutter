import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/status_badge.dart';
import 'package:flutter_vermicomposting/core/theme/styles/button_styles.dart';
import 'package:flutter_vermicomposting/core/theme/styles/text_styles.dart';
import 'package:flutter_vermicomposting/features/compost_output/domain/entities/compost_output.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/home_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/daily_report_widget.dart';

class ValidationResult extends StatefulWidget {
  final CompostOutput compostOutput;
  final PromptBody summaryResponse;

  const ValidationResult({
    super.key,
    required this.compostOutput,
    required this.summaryResponse,
  });

  @override
  State<ValidationResult> createState() => _ValidationResultState();
}

class _ValidationResultState extends State<ValidationResult> {
  late CompostOutput _compostOutput;
  late PromptBody _summaryResponse;

  @override
  void initState() {
    super.initState();

    _compostOutput = widget.compostOutput;
    _summaryResponse = widget.summaryResponse;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    double horizontalPadding = width * 0.075;
    double verticalPadding = height * 0.05;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          child: Center(
            child: Row(
              spacing: 48,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _validationResult(),
                _validationInsightsAndRecommendation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _validationResult() {
    return Expanded(
      child: Column(
        spacing: 32,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "November Compost #1",
                style: AppTextStyles.h3.copyWith(fontSize: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withAlpha(24),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "COMPLETED",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                    fontFamily: "Zenbones Mono",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            spacing: 24,
            children: [
              _buildResultWidget(
                  label: "Compost Produced",
                  result: "${_compostOutput.compostProduced} Kilo"),
              _buildResultWidget(
                  label: "Vermitea Collected",
                  result: "${_compostOutput.vermiteaProduced} Liters"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 36,
                    children: [
                      _buildResultWidget(
                          label: "Nitrogen",
                          result: "${_compostOutput.compostNpk.nitrogen}%"),
                      _buildResultWidget(
                          label: "Phosphorus",
                          result: "${_compostOutput.compostNpk.phosphorus}%"),
                      _buildResultWidget(
                          label: "Potassium",
                          result: "${_compostOutput.compostNpk.potassium}%"),
                    ],
                  ),
                  PopupMenuButton(
                    icon: Icon(
                      FluentIcons.info_24_regular,
                      size: 22,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(164),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 324),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Text(
                                  "NPK Levels",
                                  style: AppTextStyles.h4
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                _npkInfoRow(context, "N – Nitrogen",
                                    "Drives leafy growth and green color. Ideal compost range: 3>%"),
                                _npkInfoRow(context, "P – Phosphorus",
                                    "Supports root development and flowering. Ideal range: 10>%"),
                                _npkInfoRow(context, "K – Potassium",
                                    "Strengthens plant immunity and water regulation. Ideal range: 10>%"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResultWidget(
                      label: "Vermitea Total Dissolved Solids",
                      result: "${_compostOutput.vermiteaTds} ppm"),
                  PopupMenuButton(
                    icon: Icon(
                      FluentIcons.info_24_regular,
                      size: 22,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(164),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 324),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Text(
                                  "TDS – Total Dissolved Solids",
                                  style: AppTextStyles.h4
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Measures the concentration of dissolved nutrients in vermitea. Higher TDS generally indicates a richer nutrient content.",
                                  style:
                                      AppTextStyles.paragraph(context: context),
                                ),
                                _npkInfoRow(context, "Low (< 300 ppm)",
                                    "Dilute — consider reducing water ratio."),
                                _npkInfoRow(context, "Optimal (300–800 ppm)",
                                    "Well-balanced vermitea quality."),
                                _npkInfoRow(context, "High (> 800 ppm)",
                                    "Concentrated — dilute before applying to plants."),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
            spacing: 16,
            children: [
              Text(
                "Using an AI-driven model to assess the compost quality, the system analyzes the collected sensor data, especially the NPK levels of the soil, to provide a comprehensive evaluation of the produced compost. Above are the results of your compost analysis, along with interpretations and recommended improvements.",
                style: AppTextStyles.paragraph(context: context)
                    .copyWith(fontSize: 18),
              ),
              Row(
                spacing: 10,
                children: [
                  Icon(FluentIcons.sparkle_24_regular),
                  Text(
                    "Smart Analysis",
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _validationInsightsAndRecommendation() {
    return Expanded(
      child: Column(
        spacing: 24,
        children: [
          Expanded(
            child: Column(
              spacing: 24,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    spacing: 16,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 18,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLow
                                      .withAlpha(96),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                                  ),
                                ),
                                child: Icon(
                                  FluentIcons.search_info_24_filled,
                                ),
                              ),
                              Text(
                                "Insights",
                                style: AppTextStyles.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.withAlpha(64),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.lightBlue,
                              ),
                            ),
                            child: Text(
                              "AI",
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.025,
                              ),
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _summaryResponse.insight,
                            style: AppTextStyles.paragraph(context: context)
                                .copyWith(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: 16,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 18,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLow
                                      .withAlpha(96),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHigh,
                                  ),
                                ),
                                child: const Icon(
                                  FluentIcons.thumb_like_24_filled,
                                ),
                              ),
                              Text(
                                "Recommendations",
                                style: AppTextStyles.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.withAlpha(64),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.lightBlue,
                              ),
                            ),
                            child: Text(
                              "AI",
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.025,
                              ),
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _summaryResponse.recommendation,
                            style: AppTextStyles.paragraph(context: context)
                                .copyWith(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeScreen()),
            ),
            style: AppButtonStyles.of(
                    context: context, variant: AppButtonVariant.outline)
                .copyWith(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
            child: Text(
              "Return to Dashboard",
              style: AppTextStyles.paragraphSemibold(context: context, size: 14)
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResultWidget({
    required String label,
    required String result,
  }) {
    return IntrinsicHeight(
      child: Row(
        spacing: 20,
        children: [
          Container(
            width: 1,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.h4.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(164),
                ),
              ),
              Text(
                result,
                style: AppTextStyles.h2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _npkInfoRow(BuildContext context, String label, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          label,
          style: AppTextStyles.paragraph(context: context)
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          description,
          style: AppTextStyles.paragraph(context: context),
        ),
      ],
    );
  }
}
