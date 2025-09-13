import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';

class CustomIndicator extends ShapePainter {
  final double lineWidth;
  final bool translate;

  CustomIndicator({
    required super.pagesLength,
    required super.netDragPercent,
    required super.currentPageIndex,
    required super.slideDirection,
    super.activePainter,
    super.inactivePainter,
    super.showAllActiveIndicators,
    this.lineWidth = 20.0,
    this.translate = false,
  });

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.lineWidth != this.lineWidth;
  }

  /*This helps to paint anything before the active and inactive indicators are painted,
    this means you can do transformations, translations, animations, etc that will affect
    the enviroment the indicators will be painted on. In the example bellow, we're transforming the canvas
    the indicators are build on to transform horizontally based on the net drag
  */
  @override
  beforeIndicatorsRender(Canvas canvas, Size size) {
    if (translate) {
      final xTranslation = netDragPercent * pagesLength * (-lineWidth);
      canvas.transform(Matrix4.translationValues(xTranslation, 0, 0).storage);
    }
  }

  /*This will paint the active indicators as the name suggests
  */
  @override
  paintActiveIndicators(Canvas canvas, Size size, Paint paint, Path path) {
    final activeOffset1 = Offset(netDragPercent * lineWidth * pagesLength, 0.0);
    final activeOffset2 = Offset(activeOffset1.dx + lineWidth, 0.0);
    canvas.drawLine(activeOffset1, activeOffset2, paint);
  }

  /*This will paint the in-active indicators
  */
  @override
  paintInactiveIndicators(Canvas canvas, Size size, Paint paint, Path path) {
    final inActiveOffset = Offset(lineWidth * pagesLength, 0.0);
    canvas.drawLine(Offset.zero, inActiveOffset, paint);
  }
}
