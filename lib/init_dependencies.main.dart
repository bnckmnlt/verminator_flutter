part of 'init_dependencies.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  _initCompostSchedule();

  await dotenv.load(fileName: ".env");

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  /**  **/
  sl.registerLazySingleton(() => supabase.client);
  sl.registerLazySingleton(() => MqttService());

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
    );
}
