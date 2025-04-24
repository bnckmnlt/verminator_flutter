import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/theme/theme.dart';
import 'package:flutter_vermicomposting/init_dependencies.dart';

import 'features/main/presentation/layouts/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();

  // runApp(
  //   MultiBlocProvider(
  //     providers: [
  //       // BlocProvider(
  //       //   create: (_) => sl(),
  //       // ),
  //     ],
  //     child: const MyApp(),
  //   ),
  // );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Burmi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const MainLayout());
  }
}
