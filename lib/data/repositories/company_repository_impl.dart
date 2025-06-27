import 'package:client_deployment_app/data/datasources/api_service.dart';
import 'package:client_deployment_app/domain/entities/company_entities.dart';
import 'package:client_deployment_app/domain/repositories/company_repository.dart';
import 'package:dio/dio.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final ApiService apiService;

  CompanyRepositoryImpl({required this.apiService});

  @override
  Future<List<ExistingCompany>> getAllCompanies() async {
    try {
      return await apiService.getAllCompanies();
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch companies: ${e.response?.data?['errorMessage'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<ExistingCompany> getCompanyById(int id) async {
    try {
      return await apiService.getCompanyById(id);
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch company details: ${e.response?.data?['errorMessage'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCompany(int id, CompanyUpdateRequest request) async {
    try {
      await apiService.updateCompany(id, request);
    } on DioException catch (e) {
      throw Exception(
          'Failed to update company: ${e.response?.data?['errorMessage'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> bulkUpdateCompanies(BulkUpdateRequest request) async {
    try {
      await apiService.bulkUpdateCompanies(request);
    } on DioException catch (e) {
      throw Exception(
          'Failed to bulk update companies: ${e.response?.data?['errorMessage'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
