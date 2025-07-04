import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:client_deployment_app/data/datasources/api_service.dart';
import 'package:client_deployment_app/data/repositories/deployment_repository_impl.dart';
import 'package:client_deployment_app/data/repositories/company_repository_impl.dart';
import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';
import 'package:client_deployment_app/domain/repositories/company_repository.dart';
import 'package:client_deployment_app/domain/usecases/deploy_client.dart';
import 'package:client_deployment_app/domain/usecases/check_database_exists.dart';
import 'package:client_deployment_app/domain/usecases/upload_logo.dart';
import 'package:client_deployment_app/domain/usecases/get_all_companies.dart';
import 'package:client_deployment_app/domain/usecases/get_company_by_id.dart';
import 'package:client_deployment_app/domain/usecases/update_company.dart';
import 'package:client_deployment_app/domain/usecases/bulk_update_companies.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/presentation/cubits/company_management_cubit.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

final sl = GetIt.instance;

Future<void> setup() async {
  // Cubits
  sl.registerFactory(() => OnboardingCubit(
        deployClient: sl(),
        checkDatabaseExists: sl(),
        uploadLogo: sl(),
      ));

  sl.registerFactory(() => CompanyManagementCubit(
        getAllCompanies: sl(),
        getCompanyById: sl(),
        updateCompany: sl(),
        bulkUpdateCompanies: sl(),
      ));

  // Use Cases - Deployment
  sl.registerLazySingleton(() => DeployClient(repository: sl()));
  sl.registerLazySingleton(() => CheckDatabaseExists(repository: sl()));
  sl.registerLazySingleton(() => UploadLogo(repository: sl()));

  // Use Cases - Company Management
  sl.registerLazySingleton(() => GetAllCompanies(repository: sl()));
  sl.registerLazySingleton(() => GetCompanyById(repository: sl()));
  sl.registerLazySingleton(() => UpdateCompany(repository: sl()));
  sl.registerLazySingleton(() => BulkUpdateCompanies(repository: sl()));

  // Repositories
  sl.registerLazySingleton<DeploymentRepository>(
    () => DeploymentRepositoryImpl(apiService: sl()),
  );
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(apiService: sl()),
  );

  // Services
  sl.registerLazySingleton<ApiService>(() => ApiService(dio: sl()));

  // External
  String baseUrl;
  if (Platform.isAndroid) {
    baseUrl = 'https://deploy.apps.pro360erp.com/';
  } else if (Platform.isWindows) {
    // For Windows desktop, use the deployed API
    baseUrl = 'https://deploy.apps.pro360erp.com/';
  } else {
    baseUrl = 'https://deploy.apps.pro360erp.com/';
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

  // Remove SSL certificate bypass for production API
  // The deployed API should have proper SSL certificates

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));
  }

  sl.registerLazySingleton(() => dio);
}
