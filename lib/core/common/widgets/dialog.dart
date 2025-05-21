import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class GeneralDialog extends StatefulWidget {
  final String? title;
  final String description;
  final String? confirmButtonLabel;
  final VoidCallback? approvedFunction;
  final Widget widget;
  final bool isDismissable;
  final bool withTitle;

  const GeneralDialog({
    super.key,
    this.title,
    required this.description,
    this.confirmButtonLabel,
    this.approvedFunction,
    this.widget = const SizedBox(),
    this.isDismissable = true,
    this.withTitle = true,
  });

  @override
  State<GeneralDialog> createState() => _GeneralDialogState();
}

class _GeneralDialogState extends State<GeneralDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 5,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          width: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          FluentIcons.flash_24_filled,
                          size: 16,
                          color: Colors.lightBlueAccent,
                        ),
                        SizedBox(width: 2),
                        Text(
                          " SYSTEM MANAGEMENT",
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.025,
                          ),
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        FluentIcons.dismiss_24_regular,
                        size: 20,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.5),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.withTitle
                          ? Column(
                              children: [
                                Text(
                                  widget.title ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.025,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            )
                          : const SizedBox(),
                      Text(widget.description),
                      const SizedBox(height: 12),
                      widget.widget
                    ],
                  ),
                ),
              ),
              /** Footer Buttons **/
              widget.isDismissable
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: const ButtonStyle(
                              splashFactory: NoSplash.splashFactory,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Dismiss',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.025,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: widget.approvedFunction,
                            style: const ButtonStyle(
                              splashFactory: NoSplash.splashFactory,
                              shape: WidgetStatePropertyAll(
                                StadiumBorder(),
                              ),
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 32,
                                ),
                              ),
                            ),
                            child: Text(
                              widget.confirmButtonLabel ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
