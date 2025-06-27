import 'package:client_deployment_app/domain/entities/company_entities.dart';
import 'package:client_deployment_app/domain/repositories/company_repository.dart';

class GetCompanyById {
  final CompanyRepository repository;

  GetCompanyById({required this.repository});

  Future<ExistingCompany> call(int id) {
    return repository.getCompanyById(id);
  }
}
