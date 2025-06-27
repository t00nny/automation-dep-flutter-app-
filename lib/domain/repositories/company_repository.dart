import 'package:client_deployment_app/domain/entities/company_entities.dart';

abstract class CompanyRepository {
  Future<List<ExistingCompany>> getAllCompanies();
  Future<ExistingCompany> getCompanyById(int id);
  Future<void> updateCompany(int id, CompanyUpdateRequest request);
  Future<void> bulkUpdateCompanies(BulkUpdateRequest request);
}
