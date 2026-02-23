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
      spacing: 14,
      children: [
        Text(
          "Summary",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 470,
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ..._summaryItems.map((item) {
                return Expanded(
                  child: Glassmorphism(
                    blur: 12,
                    opacity: 0.2,
                    child: AnimatedContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh
                              .withAlpha(64),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withAlpha(10),
                            width: 1.5,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withAlpha(28),
                              Colors.white.withAlpha(24),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              spacing: 4,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  textHeightBehavior: TextHeightBehavior(
                                    applyHeightToLastDescent: false,
                                    applyHeightToFirstAscent: true,
                                  ),
                                  "${item.value}${item.unit}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontFamily: "Zenbones Mono",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  overflow: TextOverflow.ellipsis,
                                  item.label,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(164),
                                    fontSize: 14,
                                    height: 0.75,
                                  ),
                                ),
                              ],
                            ),
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
                  ),
                );
              })
            ],
          ),
        ),
      ],
    );
  }
}
