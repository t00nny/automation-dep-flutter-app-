import 'package:client_deployment_app/domain/entities/deployment_entities.dart';

abstract class DeploymentRepository {
  Future<DeploymentResult> deployClient(ClientDeploymentRequest request);
}