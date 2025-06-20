import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:client_deployment_app/data/datasources/api_service.dart';
import 'package:client_deployment_app/data/repositories/deployment_repository_impl.dart';
import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';
import 'package:client_deployment_app/domain/usecases/deploy_client.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

final sl = GetIt.instance;

Future<void> setup() async {
  //==================
  // Cubits
  //==================
  sl.registerFactory(() => OnboardingCubit(deployClient: sl()));

  //==================
  // Use Cases
  //==================
  sl.registerLazySingleton(() => DeployClient(repository: sl()));

  //==================
  // Repositories
  //==================
  sl.registerLazySingleton<DeploymentRepository>(
    () => DeploymentRepositoryImpl(apiService: sl()),
  );

  //==================
  // Services
  //==================
  sl.registerLazySingleton<ApiService>(() => ApiService(dio: sl()));

  //==================
  // External
  //==================

  String baseUrl;
  if (Platform.isAndroid) {
    baseUrl = 'https://10.0.2.2:4335/';
  } else {
    baseUrl = 'https://192.168.1.13:4335/';
  }

  // --- START OF FIX ---
  // Increased the receive timeout to 15 minutes to accommodate a very
  // long-running server-side deployment process.
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      // The time to establish a connection with the server (remains short).
      connectTimeout: const Duration(seconds: 30),
      // The time to wait for a response after the connection is established.
      // MODIFIED: Increased to 15 minutes.
      receiveTimeout: const Duration(minutes: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  // --- END OF FIX ---

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));
  }

  sl.registerLazySingleton(() => dio);
}
