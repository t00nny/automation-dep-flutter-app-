part of 'onboarding_cubit.dart';

// Enum to represent the current status of the deployment process.
enum DeploymentStatus { initial, loading, success, failure }

// The immutable state class for the onboarding process.
class OnboardingState extends Equatable {
  // Data for ClientDeploymentRequest
  final String clientName;
  final String databaseTypePrefix;
  final List<CompanyInfo> companies;
  // NEW: A separate property to hold the auto-generated test company.
  final CompanyInfo? testCompany;
  final AdminUserInfo adminUser;
  final LicenseInfo license;
  final List<int> selectedModuleIds;
  final CompanyUrls urls;

  // Logo upload state
  final File? clientLogoFile;

  // UI-specific state
  final DeploymentStatus deploymentStatus;
  final DeploymentResult? deploymentResult;
  final ClientDeploymentRequest?
      deploymentRequest; // ADDED: Store the deployment request
  final String? errorMessage;

  // Database validation state
  final bool isCheckingDatabase;
  final String? databaseValidationError;
  const OnboardingState({
    required this.clientName,
    required this.databaseTypePrefix,
    required this.companies,
    this.testCompany,
    required this.adminUser,
    required this.license,
    required this.selectedModuleIds,
    required this.urls,
    this.clientLogoFile,
    this.deploymentStatus = DeploymentStatus.initial,
    this.deploymentResult,
    this.deploymentRequest, // ADDED
    this.errorMessage,
    this.isCheckingDatabase = false,
    this.databaseValidationError,
  });

  // Factory constructor for the initial state of the wizard.
  factory OnboardingState.initial() {
    return OnboardingState(
      clientName: '',
      databaseTypePrefix: 'Pro',
      companies: const [],
      testCompany: null,
      adminUser: const AdminUserInfo(),
      license:
          LicenseInfo(endDate: DateTime.now().add(const Duration(days: 730))),
      selectedModuleIds: const [5], // Pre-select User Management
      urls: const CompanyUrls(),
      deploymentRequest: null, // ADDED
    );
  }

  // Helper method to create a copy of the state with updated values.
  OnboardingState copyWith({
    String? clientName,
    String? databaseTypePrefix,
    List<CompanyInfo>? companies,
    CompanyInfo? testCompany,
    AdminUserInfo? adminUser,
    LicenseInfo? license,
    List<int>? selectedModuleIds,
    CompanyUrls? urls,
    File? clientLogoFile,
    DeploymentStatus? deploymentStatus,
    DeploymentResult? deploymentResult,
    ClientDeploymentRequest? deploymentRequest, // ADDED
    String? errorMessage,
    bool? isCheckingDatabase,
    String? databaseValidationError,
    bool clearDatabaseError = false, // Add a flag to explicitly clear the error
    bool clearClientLogo = false, // Add a flag to clear the logo
  }) {
    return OnboardingState(
      clientName: clientName ?? this.clientName,
      databaseTypePrefix: databaseTypePrefix ?? this.databaseTypePrefix,
      companies: companies ?? this.companies,
      testCompany: testCompany ?? this.testCompany,
      adminUser: adminUser ?? this.adminUser,
      license: license ?? this.license,
      selectedModuleIds: selectedModuleIds ?? this.selectedModuleIds,
      urls: urls ?? this.urls,
      clientLogoFile:
          clearClientLogo ? null : (clientLogoFile ?? this.clientLogoFile),
      deploymentStatus: deploymentStatus ?? this.deploymentStatus,
      deploymentResult: deploymentResult ?? this.deploymentResult,
      deploymentRequest: deploymentRequest ?? this.deploymentRequest, // ADDED
      errorMessage: errorMessage ?? this.errorMessage,
      isCheckingDatabase: isCheckingDatabase ?? this.isCheckingDatabase,
      databaseValidationError: clearDatabaseError
          ? null
          : (databaseValidationError ?? this.databaseValidationError),
    );
  }

  @override
  List<Object?> get props => [
        clientName,
        databaseTypePrefix,
        companies,
        testCompany,
        adminUser,
        license,
        selectedModuleIds,
        urls,
        clientLogoFile,
        deploymentStatus,
        deploymentResult,
        deploymentRequest, // ADDED
        errorMessage,
        isCheckingDatabase,
        databaseValidationError,
      ];
}
