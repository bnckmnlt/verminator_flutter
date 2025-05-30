part of 'init_dependencies.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  _initCompostSchedule();
  _initFoodWaste();
  _initSensorReading();
  _initLogs();
  _initWormActivity();

  await dotenv.load(fileName: ".env");

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  /**  **/
  sl.registerLazySingleton(() => supabase.client);
  sl.registerLazySingleton(() => MqttService());
  sl.registerFactory(() => InternetConnection());

  await sl<MqttService>().connect();

  sl.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      sl(),
    ),
  );
}

void _initCompostSchedule() {
  sl
    ..registerFactory<CompostScheduleRemoteDatasource>(
      () => CompostScheduleRemoteDatasourceImpl(),
    )
    ..registerFactory<CompostScheduleRepository>(
      () => CompostScheduleRepositoryImpl(
        sl(),
        sl(),
      ),
    )
    ..registerFactory(
      () => ListCompostSchedule(
        sl(),
      ),
    )
    ..registerFactory(
      () => SelectOneCompostSchedule(
        sl(),
      ),
    )
    ..registerFactory(
      () => CreateCompostSchedule(
        sl(),
      ),
    )
    ..registerFactory(
      () => PatchCompostSchedule(
        sl(),
      ),
    )
    ..registerFactory(
      () => RemoveCompostSchedule(
        sl(),
      ),
    )
    ..registerLazySingleton(
      () => CompostScheduleBloc(
        createCompostSchedule: sl(),
        selectOneCompostSchedule: sl(),
        listCompostSchedule: sl(),
        patchCompostSchedule: sl(),
        removeCompostSchedule: sl(),
      ),
    );
}

void _initFoodWaste() {
  sl
    ..registerFactory<FoodWasteRemoteDatasource>(
      () => FoodWasteRemoteDatasourceImpl(),
    )
    ..registerFactory<FoodWasteRepository>(
      () => FoodWasteRepositoryImpl(sl(), sl()),
    )
    ..registerFactory(
      () => ListFoodWaste(
        sl(),
      ),
    )
    ..registerFactory(
      () => SelectOneFoodWaste(
        sl(),
      ),
    )
    ..registerLazySingleton(
      () => FoodWasteBloc(
        selectOneFoodWaste: sl(),
        listFoodWaste: sl(),
      ),
    );
}

void _initSensorReading() {
  sl
    ..registerFactory<SensorReadingRemoteDatasource>(
      () => SensorReadingRemoteDatasourceImpl(),
    )
    ..registerFactory<SensorReadingRepository>(
      () => SensorReadingRepositoryImpl(sl(), sl()),
    )
    ..registerFactory(
      () => ListSensorReading(
        sl(),
      ),
    )
    ..registerLazySingleton(
      () => SensorReadingBloc(
        listSensorReading: sl(),
      ),
    );
}

void _initLogs() {
  sl
    ..registerFactory<LogRemoteDatasource>(
      () => LogRemoteDatasourceImpl(),
    )
    ..registerFactory<LogRepository>(
      () => LogRepositoryImpl(
        sl(),
        sl(),
      ),
    )
    ..registerFactory(
      () => ListLogs(
        sl(),
      ),
    )
    ..registerLazySingleton(
      () => LogBloc(
        listLogs: sl(),
      ),
    );
}

void _initWormActivity() {
  sl
    ..registerFactory<WormActivityRemoteDatasource>(
      () => WormActivityRemoteDatasourceImpl(),
    )
    ..registerFactory<WormActivityRepository>(
      () => WormActivityRepositoryImpl(
        sl(),
        sl(),
      ),
    )
    ..registerFactory(
      () => ListWormActivity(
        sl(),
      ),
    )
    ..registerFactory(
      () => SelectOneWormActivity(
        sl(),
      ),
    )
    ..registerLazySingleton(
      () => WormActivityBloc(
        listWormActivity: sl(),
        selectOneWormActivity: sl(),
      ),
    );
}
