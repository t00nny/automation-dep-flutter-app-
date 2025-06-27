import 'package:client_deployment_app/domain/entities/company_entities.dart';
import 'package:client_deployment_app/domain/repositories/company_repository.dart';

class BulkUpdateCompanies {
  final CompanyRepository repository;

  BulkUpdateCompanies({required this.repository});

  Future<void> call(BulkUpdateRequest request) {
    return repository.bulkUpdateCompanies(request);
  }
}
