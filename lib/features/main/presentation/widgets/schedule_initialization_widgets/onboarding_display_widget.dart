import 'package:flutter/material.dart';

class OnboardingDisplayWidget extends StatefulWidget {
  final String assetSrc;
  final Widget displayBody;

  const OnboardingDisplayWidget({
    super.key,
    required this.assetSrc,
    required this.displayBody,
  });

  @override
  State<OnboardingDisplayWidget> createState() =>
      _OnboardingDisplayWidgetState();
}

class _OnboardingDisplayWidgetState extends State<OnboardingDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Row(
        spacing: 32,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              widget.assetSrc,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: widget.displayBody,
          ),
        ],
      ),
    );
  }
}
