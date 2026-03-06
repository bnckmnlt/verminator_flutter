import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_schedule/app_schedule_cubit.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_settings/app_settings_cubit.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/theme/theme.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/calibration_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/home_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/logs_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_list_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/settings_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/test_pages/raw_data_screen.dart';
import 'package:flutter_vermicomposting/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/status/presentation/bloc/status_record_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:flutter_vermicomposting/init_dependencies.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final log = Logger('System Logs');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.INFO;

  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });

  await initDependencies();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AppScheduleCubit>()..initializeApp()),
        BlocProvider(create: (_) => sl<CompostScheduleBloc>()),
        BlocProvider(create: (_) => sl<AppSettingsCubit>()),
        BlocProvider(create: (_) => sl<FoodWasteBloc>()),
        BlocProvider(create: (_) => sl<SensorReadingBloc>()),
        BlocProvider(
          create: (_) => sl<LogBloc>(),
        ),
        BlocProvider(create: (_) => sl<WormActivityBloc>()),
        BlocProvider(create: (_) => sl<StatusRecordBloc>()),
        BlocProvider(create: (_) => sl<NotificationBloc>()),
      ],
      child: Phoenix(
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    WakelockPlus.enable();

    super.initState();
  }

  final String _loadingDescription =
      "The application is initializing. Please wait while we fetch the latest data. If this takes too long, kindly try again shortly";

  Widget _buildHomeRoute(BuildContext context) {
    return BlocSelector<AppScheduleCubit, AppScheduleState, bool>(
      selector: (state) => state is AppScheduleActive,
      builder: (context, scheduleActive) {
        if (scheduleActive) {
          return const SafeArea(child: HomeScreen());
        }
        return Scaffold(
          body: Center(
            child: EmptyDisplayWidget(
              icon: FluentIcons.cloud_sync_24_regular,
              title: "Loading application data",
              description: _loadingDescription,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vermiture PH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark,
      routes: {
        '/': _buildHomeRoute,
        '/schedule': (context) => const SafeArea(child: ScheduleListScreen()),
        '/controls': (context) => const SafeArea(child: ControlScreen()),
        '/logs': (context) => const SafeArea(child: LogsScreen()),
        '/dev': (context) => const SafeArea(child: RawDataScreen()),
        '/settings': (context) => SafeArea(child: SettingsScreen()),
        '/calibration': (context) => SafeArea(child: CalibrationWidget()),
      },
    );
  }
}
