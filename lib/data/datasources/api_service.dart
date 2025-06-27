import 'dart:io';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
import 'package:client_deployment_app/domain/entities/company_entities.dart';
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

  // Company Management APIs
  Future<List<ExistingCompany>> getAllCompanies() async {
    const endpoint = 'api/Companies';
    final response = await dio.get(endpoint);

    if (response.data is List) {
      return (response.data as List)
          .map((json) => ExistingCompany.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<ExistingCompany> getCompanyById(int id) async {
    final endpoint = 'api/Companies/$id';
    final response = await dio.get(endpoint);
    return ExistingCompany.fromJson(response.data);
  }

  Future<void> updateCompany(int id, CompanyUpdateRequest request) async {
    final endpoint = 'api/Companies/$id';
    print('DEBUG: Updating company with ID: $id');
    print('DEBUG: Endpoint: $endpoint');
    print('DEBUG: Request data: ${request.toJson()}');
    
    try {
      final response = await dio.put(endpoint, data: request.toJson());
      print('DEBUG: Update response status: ${response.statusCode}');
      print('DEBUG: Update response data: ${response.data}');
      
      // Check if the response indicates success
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Update failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Update error: $e');
      rethrow;
    }
  }

  Future<void> bulkUpdateCompanies(BulkUpdateRequest request) async {
    const endpoint = 'api/Companies/bulk-update';
    print('DEBUG: Bulk updating companies');
    print('DEBUG: Endpoint: $endpoint');
    print('DEBUG: Request data: ${request.toJson()}');
    
    try {
      final response = await dio.put(endpoint, data: request.toJson());
      print('DEBUG: Bulk update response status: ${response.statusCode}');
      print('DEBUG: Bulk update response data: ${response.data}');
      
      // Check if the response indicates success
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Bulk update failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Bulk update error: $e');
      rethrow;
    }
  }
}
