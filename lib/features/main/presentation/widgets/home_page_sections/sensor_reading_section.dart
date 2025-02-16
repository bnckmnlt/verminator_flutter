import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/layers/bedding_layer.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/layers/compost_layer.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/layers/liquid_layer.dart';

class SensorReadingSection extends StatelessWidget {
  const SensorReadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 3;
        double itemWidth =
            constraints.maxWidth / columns - 16;

        return Wrap(
          spacing: 16,
          runSpacing: 0,
          children: [
            SizedBox(
              width: itemWidth,
              child: BeddingLayer(),
            ),
            SizedBox(
              width: itemWidth,
              child: CompostLayer(),
            ),
            SizedBox(
              width: itemWidth,
              child: LiquidLayer(),
            ),
          ],
        );
      },
    );
  }
}
