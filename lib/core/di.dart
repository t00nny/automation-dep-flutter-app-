import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:client_deployment_app/data/datasources/api_service.dart';
import 'package:client_deployment_app/data/repositories/deployment_repository_impl.dart';
import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';
import 'package:client_deployment_app/domain/usecases/deploy_client.dart';
import 'package:client_deployment_app/domain/usecases/check_database_exists.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:flutter/foundation.dart';
// --- START OF FIX ---
// Added the necessary imports for HttpClient, X509Certificate, and IOHttpClientAdapter
import 'dart:io' show HttpClient, Platform, X509Certificate;
import 'package:dio/io.dart';
// --- END OF FIX ---

final sl = GetIt.instance;

Future<void> setup() async {
  // Cubits
  sl.registerFactory(() => OnboardingCubit(
        deployClient: sl(),
        checkDatabaseExists: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => DeployClient(repository: sl()));
  sl.registerLazySingleton(() => CheckDatabaseExists(repository: sl()));

  // Repositories
  sl.registerLazySingleton<DeploymentRepository>(
    () => DeploymentRepositoryImpl(apiService: sl()),
  );

  // Services
  sl.registerLazySingleton<ApiService>(() => ApiService(dio: sl()));

  // External
  String baseUrl;
  if (Platform.isAndroid) {
    baseUrl = 'https://10.0.2.2:4335/';
  } else {
    baseUrl = 'https://192.168.1.13:4335/';
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(minutes: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // This block for bypassing SSL certificate validation is now correct
  // because the required classes have been imported.
  if (kDebugMode) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));
  }

  sl.registerLazySingleton(() => dio);
}
