import 'package:client_deployment_app/domain/entities/company_entities.dart';
import 'package:client_deployment_app/domain/repositories/company_repository.dart';

class GetAllCompanies {
  final CompanyRepository repository;

  GetAllCompanies({required this.repository});

  Future<List<ExistingCompany>> call() {
    return repository.getAllCompanies();
  }
}
