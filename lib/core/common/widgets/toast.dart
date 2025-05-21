import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart';

class ToastWidget extends StatelessWidget {
  final bool isError;
  final String title;
  final String description;

  const ToastWidget({
    super.key,
    this.isError = false,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      toastification.show(
        context: context,
        type: isError ? ToastificationType.error : ToastificationType.success,
        style: isError
            ? ToastificationStyle.flatColored
            : ToastificationStyle.flat,
        title: Text(title),
        description: Text(description),
        alignment: Alignment.topLeft,
        autoCloseDuration: const Duration(seconds: 4),
        animationBuilder: (
          context,
          animation,
          alignment,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        primaryColor: Color(0xff10b981),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: lowModeShadow,
        showProgressBar: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
    });

    return const SizedBox.shrink();
  }
}
