import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/theme/theme.dart';
import 'package:flutter_vermicomposting/features/compost_schedule/presentation/bloc/compost_schedule_bloc.dart';
import 'package:flutter_vermicomposting/features/food_waste/presentation/bloc/food_waste_bloc.dart';
import 'package:flutter_vermicomposting/features/logs/presentation/bloc/log_bloc.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/control_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/home_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/logs_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/schedule_screen.dart';
import 'package:flutter_vermicomposting/features/main/presentation/pages/settings_screen.dart';
import 'package:flutter_vermicomposting/features/sensor_reading/presentation/bloc/sensor_reading_bloc.dart';
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burmi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routes: {
        '/': (context) => const HomeScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/controls': (context) => const ControlScreen(),
        '/logs': (context) => const LogsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
