import 'dart:io';
import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';

class UploadLogo {
  final DeploymentRepository repository;

  UploadLogo({required this.repository});

  Future<String?> call(File logoFile, {String? customFilename}) {
    return repository.uploadLogo(logoFile, customFilename: customFilename);
  }
}
