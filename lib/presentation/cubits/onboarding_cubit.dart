import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
import 'package:client_deployment_app/domain/usecases/deploy_client.dart';
import 'package:client_deployment_app/domain/usecases/check_database_exists.dart';
import 'package:client_deployment_app/domain/usecases/upload_logo.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final DeployClient _deployClient;
  final CheckDatabaseExists _checkDatabaseExists;
  final UploadLogo _uploadLogo;
  final ImagePicker _imagePicker = ImagePicker();

  OnboardingCubit({
    required DeployClient deployClient,
    required CheckDatabaseExists checkDatabaseExists,
    required UploadLogo uploadLogo,
  })  : _deployClient = deployClient,
        _checkDatabaseExists = checkDatabaseExists,
        _uploadLogo = uploadLogo,
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
      final testCompany = company.copyWith(
        companyName: 'Test ${state.clientName}',
        logoText: company.logoText, // Explicitly copy logoText to test company
      );
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

      // If this is the first company and we have a test company, update test company's logoText
      CompanyInfo? updatedTestCompany = state.testCompany;
      if (index == 0 && state.testCompany != null) {
        updatedTestCompany = state.testCompany!.copyWith(
          logoText: company.logoText,
        );
      }

      emit(state.copyWith(
        companies: updatedCompanies,
        testCompany: updatedTestCompany,
      ));
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

  Future<void> validateClientDatabase() async {
    if (state.clientName.trim().isEmpty || state.databaseTypePrefix.isEmpty) {
      return;
    }

    emit(state.copyWith(
      isCheckingDatabase: true,
      clearDatabaseError: true, // Clear any previous error
    ));

    try {
      final databaseExists = await _checkDatabaseExists(
        state.databaseTypePrefix,
        state.clientName.trim(),
      );

      if (databaseExists) {
        emit(state.copyWith(
          isCheckingDatabase: false,
          databaseValidationError:
              'Invalid: This client name already has a database.',
        ));
      } else {
        emit(state.copyWith(
          isCheckingDatabase: false,
          clearDatabaseError: true, // Explicitly clear error on success
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isCheckingDatabase: false,
        databaseValidationError: 'Error checking database: ${e.toString()}',
      ));
    }
  }

  // Logo handling methods
  Future<void> pickClientLogo() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        emit(state.copyWith(clientLogoFile: file));
      }
    } catch (e) {
      // Handle error if needed
    }
  }

  void removeClientLogo() {
    emit(state.copyWith(clearClientLogo: true));
  }

  void clearDatabaseValidationError() {
    emit(state.copyWith(clearDatabaseError: true));
  }

  /// Uploads the client logo and returns the URL
  /// This method ensures the logo is uploaded via POST /api/LogoUpload/upload
  /// before the ClientDeployment process begins
  Future<String?> _uploadClientLogo(File logoFile) async {
    try {
      final logoUrl = await _uploadLogo(logoFile);

      if (logoUrl == null || logoUrl.isEmpty) {
        throw Exception('Logo upload service returned null or empty URL');
      }

      if (!logoUrl.startsWith('http')) {
        throw Exception('Invalid logo URL format received: $logoUrl');
      }

      return logoUrl;
    } catch (e) {
      // Log the error for debugging
      print('Logo upload error: $e');
      return null;
    }
  }

  /// Submits the client deployment request
  ///
  /// CRITICAL FLOW:
  /// 1. First uploads logo via POST /api/LogoUpload/upload (if logo exists)
  /// 2. Obtains logo URL from the upload response
  /// 3. Includes the logo URL in the CompanyUrls.logoUrl field
  /// 4. Then calls POST /api/ClientDeployment/deploy with the complete request
  ///
  /// The ClientDeployment API depends on the logo URL being available,
  /// so logo upload MUST complete successfully before deployment begins.
  Future<void> submitDeployment() async {
    emit(state.copyWith(deploymentStatus: DeploymentStatus.loading));

    try {
      // Step 1: Upload logo first if exists - this is REQUIRED before deployment
      String? logoUrl;
      if (state.clientLogoFile != null) {
        emit(state.copyWith(
          deploymentStatus: DeploymentStatus.loading,
          errorMessage: 'Uploading logo...',
        ));

        logoUrl = await _uploadClientLogo(state.clientLogoFile!);
        if (logoUrl == null || logoUrl.isEmpty) {
          emit(state.copyWith(
            deploymentStatus: DeploymentStatus.failure,
            errorMessage:
                'Failed to upload logo. Logo upload is required before deployment. Please try again.',
          ));
          return;
        }
      }

      // Step 2: Prepare deployment request with logo URL
      emit(state.copyWith(
        deploymentStatus: DeploymentStatus.loading,
        errorMessage: 'Preparing deployment...',
      ));

      final allCompanies = List<CompanyInfo>.from(state.companies);
      if (state.testCompany != null) {
        allCompanies.add(state.testCompany!);
      }

      // CRITICAL: Update company logo URLs if a logo was uploaded
      final updatedCompanies = logoUrl != null
          ? allCompanies.map((c) => c.copyWith(logoUrl: logoUrl)).toList()
          : allCompanies;

      // CRITICAL: Update URLs with logo URL if uploaded
      // The ClientDeployment API requires the logo URL to be included
      final updatedUrls =
          logoUrl != null ? state.urls.copyWith(logoUrl: logoUrl) : state.urls;

      final request = ClientDeploymentRequest(
        clientName: state.clientName,
        databaseTypePrefix: state.databaseTypePrefix,
        companies: updatedCompanies, // Use the updated list
        adminUser: state.adminUser,
        license: state.license,
        selectedModuleIds: state.selectedModuleIds,
        urls: updatedUrls, // Contains the uploaded logo URL
      );

      // Step 3: Deploy client with the logo URL included
      emit(state.copyWith(
        deploymentStatus: DeploymentStatus.loading,
        errorMessage: 'Deploying client...',
      ));

      final result = await _deployClient(request);

      emit(state.copyWith(
        deploymentStatus: result.isSuccess
            ? DeploymentStatus.success
            : DeploymentStatus.failure,
        deploymentResult: result,
        deploymentRequest: request,
        errorMessage: result.errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        deploymentStatus: DeploymentStatus.failure,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }
}
