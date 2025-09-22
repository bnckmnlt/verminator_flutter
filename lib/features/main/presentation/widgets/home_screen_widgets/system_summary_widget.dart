import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/glassmorphism.dart';
import 'package:flutter_vermicomposting/core/constants/constants.dart';

class SystemSummaryWidget extends StatefulWidget {
  final List<SummaryCardItem> summaryItems;

  const SystemSummaryWidget({
    super.key,
    required this.summaryItems,
  });

  @override
  State<SystemSummaryWidget> createState() => _SystemSummaryWidgetState();
}

class _SystemSummaryWidgetState extends State<SystemSummaryWidget> {
  late List<SummaryCardItem> _summaryItems;

  @override
  void initState() {
    _summaryItems = widget.summaryItems;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 18,
      children: [
        Text(
          "Summary",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          spacing: 12,
          children: [
            ..._summaryItems.map((item) {
              return Glassmorphism(
                blur: 32,
                opacity: 0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHigh
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(64),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        spacing: 2.5,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textHeightBehavior: TextHeightBehavior(
                              applyHeightToLastDescent: false,
                              applyHeightToFirstAscent: true,
                            ),
                            "${item.value}${item.unit}",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(164),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.icon,
                          size: 28,
                          color: Colors.black87,
                        ),
                      )
                    ],
                  ),
                ),
              );
            })
          ],
        ),
      ],
    );
  }
}
