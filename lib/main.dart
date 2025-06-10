import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/cubits/app_schedule/app_schedule_cubit.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/core/theme/theme.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/home_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/logs_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_list_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/settings_screen.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
import 'package:flutter_vermicomposting/features/worm_activity/presentation/bloc/worm_activity_bloc.dart';
import 'package:flutter_vermicomposting/init_dependencies.dart';
import 'package:logging/logging.dart';

final log = Logger('System Logs');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AppScheduleCubit>()..initializeApp(),
        ),
        BlocProvider(
          create: (_) => sl<CompostScheduleBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<FoodWasteBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<SensorReadingBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<LogBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<WormActivityBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );

  // runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burmi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routes: {
        '/': (context) =>
            BlocSelector<AppScheduleCubit, AppScheduleState, bool>(
              selector: (state) {
                return state is AppScheduleActive;
              },
              builder: (context, isActive) {
                if (isActive) {
                  return SafeArea(child: HomeScreen());
                }

                return Scaffold(
                  body: Center(
                    child: EmptyDisplayWidget(
                        icon: FluentIcons.cloud_sync_24_regular,
                        title: "Loading application data",
                        description:
                            "The application is initializing. Please wait while we fetch the latest data. If this takes too long, kindly try again shortly"),
                  ),
                );
              },
            ),
        '/schedule': (context) => SafeArea(child: const ScheduleListScreen()),
        '/controls': (context) => SafeArea(child: const ControlScreen()),
        '/logs': (context) => SafeArea(child: const LogsScreen()),
        '/settings': (context) => SafeArea(child: SettingsScreen()),
      },
    );
  }
}
