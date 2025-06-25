import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';

class CheckDatabaseExists {
  final DeploymentRepository repository;

  CheckDatabaseExists({required this.repository});

  Future<bool> call(String databaseTypePrefix, String clientName) async {
    return await repository.checkDatabaseExists(databaseTypePrefix, clientName);
  }
}
