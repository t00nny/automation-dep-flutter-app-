import 'package:client_deployment_app/domain/entities/company_entities.dart';
import 'package:client_deployment_app/domain/repositories/company_repository.dart';

class UpdateCompany {
  final CompanyRepository repository;

  UpdateCompany({required this.repository});

  Future<void> call(int id, CompanyUpdateRequest request) {
    return repository.updateCompany(id, request);
  }
}
