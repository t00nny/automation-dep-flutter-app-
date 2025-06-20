import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';

class DeployClient {
  final DeploymentRepository repository;

  DeployClient({required this.repository});

  Future<DeploymentResult> call(ClientDeploymentRequest request) {
    return repository.deployClient(request);
  }
}