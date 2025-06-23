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

  void updateDatabasePrefix(String prefix) {
    emit(state.copyWith(databaseTypePrefix: prefix));
  }

  void addCompany(CompanyInfo company) {
    final updatedCompanies = List<CompanyInfo>.from(state.companies);
    updatedCompanies.add(company);

    if (state.companies.isEmpty) {
      final testCompany =
          company.copyWith(companyName: 'Test ${state.clientName}');
      emit(state.copyWith(
        companies: updatedCompanies,
        testCompany: testCompany,
      ));
    } else {
      emit(state.copyWith(companies: updatedCompanies));
    }
  }

  void updateCompany(int index, CompanyInfo company) {
    final List<CompanyInfo> updatedCompanies = List.from(state.companies);
    if (index < updatedCompanies.length) {
      updatedCompanies[index] = company;
      emit(state.copyWith(companies: updatedCompanies));
    }
  }

  void deleteCompany(int index) {
    final updatedCompanies = List<CompanyInfo>.from(state.companies);
    if (index < updatedCompanies.length) {
      updatedCompanies.removeAt(index);

      if (updatedCompanies.isEmpty) {
        emit(state.copyWith(
          companies: updatedCompanies,
          testCompany: null,
        ));
      } else {
        emit(state.copyWith(companies: updatedCompanies));
      }
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

  // UPDATED: New comprehensive URL update method
  void updateUrls({
    String? webURL,
    bool? webURLEnabled,
    String? apiURL,
    bool? apiURLEnabled,
    String? crmurl,
    bool? crmurlEnabled,
    String? procurementURL,
    bool? procurementURLEnabled,
    String? reportsURL,
    bool? reportsURLEnabled,
    String? leasingURL,
    bool? leasingURLEnabled,
    String? tradingURL,
    bool? tradingURLEnabled,
    String? integrationURL,
    bool? integrationURLEnabled,
    String? fnbPosURL,
    bool? fnbPosURLEnabled,
    String? retailPOSUrl,
    bool? retailPOSUrlEnabled,
  }) {
    final currentUrls = state.urls;
    emit(state.copyWith(
      urls: currentUrls.copyWith(
        webURL: webURL,
        webURLEnabled: webURLEnabled,
        apiURL: apiURL,
        apiURLEnabled: apiURLEnabled,
        crmurl: crmurl,
        crmurlEnabled: crmurlEnabled,
        procurementURL: procurementURL,
        procurementURLEnabled: procurementURLEnabled,
        reportsURL: reportsURL,
        reportsURLEnabled: reportsURLEnabled,
        leasingURL: leasingURL,
        leasingURLEnabled: leasingURLEnabled,
        tradingURL: tradingURL,
        tradingURLEnabled: tradingURLEnabled,
        integrationURL: integrationURL,
        integrationURLEnabled: integrationURLEnabled,
        fnbPosURL: fnbPosURL,
        fnbPosURLEnabled: fnbPosURLEnabled,
        retailPOSUrl: retailPOSUrl,
        retailPOSUrlEnabled: retailPOSUrlEnabled,
      ),
    ));
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

    final allCompanies = List<CompanyInfo>.from(state.companies);
    if (state.testCompany != null) {
      allCompanies.add(state.testCompany!);
    }

    final request = ClientDeploymentRequest(
      clientName: state.clientName,
      databaseTypePrefix: state.databaseTypePrefix,
      companies: allCompanies,
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
      deploymentRequest: request,
      errorMessage: result.errorMessage,
    ));
  }
}
