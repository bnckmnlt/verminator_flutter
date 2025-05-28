import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  final BuildContext context;

  ToastHelper(this.context);

  void show({
    required String title,
    required String description,
    required bool isError,
    bool isInformation = false,
    int duration = 5,
  }) {
    toastification.show(
      context: context,
      type: isError
          ? ToastificationType.error
          : isInformation
              ? ToastificationType.info
              : ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      description: Text(
        description,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: Duration(seconds: duration),
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
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        width: 1,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(4.0),
      showProgressBar: true,
      dragToClose: true,
    );
  }
}
