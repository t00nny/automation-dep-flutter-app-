import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
import 'package:client_deployment_app/domain/usecases/deploy_client.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final DeployClient _deployClient;

  OnboardingCubit({required DeployClient deployClient})
      : _deployClient = deployClient,
        super(OnboardingState.initial());

  void startNewSession() {
    emit(OnboardingState.initial());
  }

  void updateClientName(String name) {
    emit(state.copyWith(clientName: name));
  }

  // NEW: Method to update the database prefix.
  void updateDatabasePrefix(String prefix) {
    emit(state.copyWith(databaseTypePrefix: prefix));
  }

  void addCompany(CompanyInfo company) {
    final List<CompanyInfo> updatedCompanies = List.from(state.companies);
    updatedCompanies.add(company);

    final testCompany =
        company.copyWith(companyName: '${company.companyName} Test');
    updatedCompanies.add(testCompany);

    emit(state.copyWith(companies: updatedCompanies));
  }

  void updateCompany(int index, CompanyInfo company) {
    final List<CompanyInfo> updatedCompanies = List.from(state.companies);
    if (index < updatedCompanies.length) {
      updatedCompanies[index] = company;
      emit(state.copyWith(companies: updatedCompanies));
    }
  }

  void deleteCompany(int index) {
    final List<CompanyInfo> updatedCompanies = List.from(state.companies);
    if (index < updatedCompanies.length) {
      updatedCompanies.removeAt(index);
      emit(state.copyWith(companies: updatedCompanies));
    }
  }

  void updateAdminInfo(
      {String? email,
      String? contactNumber,
      String? password,
      String? branch}) {
    final currentUser = state.adminUser;
    emit(state.copyWith(
      adminUser: AdminUserInfo(
        email: email ?? currentUser.email,
        contactNumber: contactNumber ?? currentUser.contactNumber,
        password: password ?? currentUser.password,
        branch: branch ?? currentUser.branch,
      ),
    ));
  }

  void updateLicenseInfo(
      {DateTime? endDate, int? numberOfUsers, bool? usesNewEncryption}) {
    final currentLicense = state.license;
    emit(state.copyWith(
        license: LicenseInfo(
      endDate: endDate ?? currentLicense.endDate,
      numberOfUsers: numberOfUsers ?? currentLicense.numberOfUsers,
      usesNewEncryption: usesNewEncryption ?? currentLicense.usesNewEncryption,
    )));
  }

  void updateUrls(
      {String? crmUrl, String? tradingUrl, String? integrationUrl}) {
    final currentUrls = state.urls;
    emit(state.copyWith(
        urls: CompanyUrls(
      crmurl: crmUrl ?? currentUrls.crmurl,
      tradingURL: tradingUrl ?? currentUrls.tradingURL,
      integrationURL: integrationUrl ?? currentUrls.integrationURL,
    )));
  }

  void toggleModule(int moduleId) {
    final updatedModules = List<int>.from(state.selectedModuleIds);
    if (updatedModules.contains(moduleId)) {
      if (moduleId != 5) {
        updatedModules.remove(moduleId);
      }
    } else {
      updatedModules.add(moduleId);
    }
    emit(state.copyWith(selectedModuleIds: updatedModules));
  }

  Future<void> submitDeployment() async {
    emit(state.copyWith(deploymentStatus: DeploymentStatus.loading));

    final request = ClientDeploymentRequest(
      clientName: state.clientName,
      // Pass the selected prefix to the request object.
      databaseTypePrefix: state.databaseTypePrefix,
      companies: state.companies,
      adminUser: state.adminUser,
      license: state.license,
      selectedModuleIds: state.selectedModuleIds,
      urls: state.urls,
    );

    final result = await _deployClient(request);

    emit(state.copyWith(
      deploymentStatus: result.isSuccess
          ? DeploymentStatus.success
          : DeploymentStatus.failure,
      deploymentResult: result,
      errorMessage: result.errorMessage,
    ));
  }
}
