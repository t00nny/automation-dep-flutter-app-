import 'dart:io';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;

  ApiService({required this.dio});

  Future<DeploymentResult> deployClient(ClientDeploymentRequest request) async {
    const endpoint = 'api/ClientDeployment/deploy';
    final response = await dio.post(endpoint, data: request.toJson());
    return DeploymentResult.fromJson(response.data);
  }

  Future<bool> checkDatabaseExists(
      String databaseTypePrefix, String clientName) async {
    final endpoint = 'api/ClientDeployment/check-database/$databaseTypePrefix';
    final response = await dio.get(
      endpoint,
      queryParameters: {'clientName': clientName},
    );
    return response.data as bool;
  }

  Future<String?> uploadLogo(File logoFile) async {
    try {
      const endpoint = 'api/LogoUpload/upload';

      // Create form data for file upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          logoFile.path,
          filename: logoFile.path.split('/').last,
        ),
      });

      final response = await dio.post(endpoint, data: formData);

      if (response.statusCode == 200 && response.data is Map) {
        return response.data['url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
