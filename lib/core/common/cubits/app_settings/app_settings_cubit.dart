import 'package:flutter_vermicomposting/core/common/entities/app_settings_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AppSettingsCubit extends HydratedCubit<AppSettingsModel> {
  AppSettingsCubit() : super(AppSettingsModel(feedingTimer: 120));

  void updateAppSettings(AppSettingsModel appSettings) => emit(appSettings);

  @override
  AppSettingsModel? fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      feedingTimer: json["feeding_timer"] as int,
    );
  }

  @override
  Map<String, dynamic>? toJson(AppSettingsModel state) {
    return {
      "feeding_timer": state.feedingTimer,
    };
  }
}
