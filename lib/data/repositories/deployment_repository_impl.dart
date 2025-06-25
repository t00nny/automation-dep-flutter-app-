import 'package:client_deployment_app/data/datasources/api_service.dart';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';
import 'package:dio/dio.dart';

class DeploymentRepositoryImpl implements DeploymentRepository {
  final ApiService apiService;

  DeploymentRepositoryImpl({required this.apiService});

  @override
  Future<DeploymentResult> deployClient(ClientDeploymentRequest request) async {
    try {
      return await apiService.deployClient(request);
    } on DioException catch (e) {
      return DeploymentResult(
        isSuccess: false,
        errorMessage: e.response?.data?['errorMessage'] ??
            'A network error occurred: ${e.message}',
      );
    } catch (e) {
      return DeploymentResult(
        isSuccess: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> checkDatabaseExists(
      String databaseTypePrefix, String clientName) async {
    try {
      return await apiService.checkDatabaseExists(
          databaseTypePrefix, clientName);
    } on DioException catch (e) {
      // If we get a 400 or 500 error, we throw the exception to handle it in the UI
      if (e.response?.statusCode == 400) {
        throw Exception('Database type prefix cannot be empty.');
      } else if (e.response?.statusCode == 500) {
        throw Exception(
            'An internal error occurred while checking the database.');
      }
      // For other errors, rethrow
      rethrow;
    }
  }
}
