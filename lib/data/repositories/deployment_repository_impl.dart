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
        errorMessage: e.response?.data?['errorMessage'] ?? 'A network error occurred: ${e.message}',
      );
    } catch (e) {
      return DeploymentResult(
        isSuccess: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}