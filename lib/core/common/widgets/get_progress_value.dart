import 'package:flutter_vermicomposting/core/constants/constants.dart';

double getProgressValue(CompostingStatus status) {
  switch (status) {
    case CompostingStatus.initial:
      return 0.25;
    case CompostingStatus.active:
      return 0.50;
    case CompostingStatus.ready:
      return 0.75;
    case CompostingStatus.released:
      return 1.0;
  }
}
