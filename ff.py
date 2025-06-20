import os
import textwrap

# ==============================================================================
#  PYTHON SCRIPT TO AUTOMATE FLUTTER PROJECT CREATION
#  Author: Gemini
#  Date: June 20, 2025
#  Instructions:
#  1. Create a new, empty folder for your project.
#  2. Save this script as 'create_flutter_project.py' inside that folder.
#  3. Run the script from your terminal: python create_flutter_project.py
#  4. After it finishes, run 'flutter pub get' in the terminal.
# ==============================================================================

# A dictionary mapping file paths to their content.
# Using textwrap.dedent to handle multiline strings cleanly.
PROJECT_FILES = {
    "pubspec.yaml": """
        name: client_deployment_app
        description: A Flutter application to automate the client deployment process.
        publish_to: 'none' 
        version: 1.0.0+1

        environment:
          sdk: '>=3.2.0 <4.0.0'

        dependencies:
          flutter:
            sdk: flutter

          # Core Utilities
          equatable: ^2.0.5
          get_it: ^7.6.7
          go_router: ^13.2.0
          intl: ^0.19.0
          
          # State Management
          flutter_bloc: ^8.1.4

          # Networking
          dio: ^5.4.1

          # UI/UX
          flutter_svg: ^2.0.10+1
          
          # File & Sharing
          pdf: ^3.10.8
          path_provider: ^2.1.2
          share_plus: ^7.2.2

        dev_dependencies:
          flutter_test:
            sdk: flutter
          flutter_lints: ^3.0.1

        flutter:
          uses-material-design: true
          assets:
            - assets/icons/
    """,
    "lib/main.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:client_deployment_app/core/di.dart' as di;
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:client_deployment_app/core/app_router.dart';
        import 'package:client_deployment_app/core/app_theme.dart';

        void main() async {
          // Ensure Flutter is initialized.
          WidgetsFlutterBinding.ensureInitialized();
          
          // Initialize dependencies.
          await di.setup();

          runApp(const ClientDeploymentApp());
        }

        class ClientDeploymentApp extends StatelessWidget {
          const ClientDeploymentApp({super.key});

          @override
          Widget build(BuildContext context) {
            // Provide the OnboardingCubit to the entire widget tree.
            return BlocProvider(
              create: (context) => di.sl<OnboardingCubit>(),
              child: MaterialApp.router(
                title: 'Client Deployment',
                theme: AppTheme.lightTheme,
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.router,
              ),
            );
          }
        }
    """,
    "lib/core/di.dart": """
        import 'package:get_it/get_it.dart';
        import 'package:dio/dio.dart';
        import 'package:client_deployment_app/data/datasources/api_service.dart';
        import 'package:client_deployment_app/data/repositories/deployment_repository_impl.dart';
        import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';
        import 'package:client_deployment_app/domain/usecases/deploy_client.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:flutter/foundation.dart';

        final sl = GetIt.instance;

        Future<void> setup() async {
          //==================
          // Cubits
          //==================
          sl.registerFactory(() => OnboardingCubit(deployClient: sl()));

          //==================
          // Use Cases
          //==================
          sl.registerLazySingleton(() => DeployClient(repository: sl()));

          //==================
          // Repositories
          //==================
          sl.registerLazySingleton<DeploymentRepository>(
            () => DeploymentRepositoryImpl(apiService: sl()),
          );

          //==================
          // Services
          //==================
          sl.registerLazySingleton<ApiService>(() => ApiService(dio: sl()));

          //==================
          // External
          //==================
          final dio = Dio(
            BaseOptions(
              baseUrl: 'https://192.168.1.13:4335/',
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

          if (kDebugMode) {
            dio.interceptors.add(LogInterceptor(
              requestBody: true,
              responseBody: true,
              logPrint: (o) => debugPrint(o.toString()),
            ));
          }
          
          sl.registerLazySingleton(() => dio);
        }
    """,
    "lib/core/app_router.dart": """
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/presentation/pages/splash_page.dart';
        import 'package:client_deployment_app/presentation/pages/welcome_page.dart';
        import 'package:client_deployment_app/presentation/pages/step_1_client_details_page.dart';
        import 'package:client_deployment_app/presentation/pages/step_2_company_info_page.dart';
        import 'package:client_deployment_app/presentation/pages/company_form_page.dart';
        import 'package:client_deployment_app/presentation/pages/step_3_admin_credentials_page.dart';
        import 'package:client_deployment_app/presentation/pages/step_4_license_page.dart';
        import 'package:client_deployment_app/presentation/pages/step_5_urls_page.dart';
        import 'package:client_deployment_app/presentation/pages/step_6_modules_page.dart';
        import 'package:client_deployment_app/presentation/pages/step_7_review_page.dart';
        import 'package:client_deployment_app/presentation/pages/deployment_progress_page.dart';
        import 'package:client_deployment_app/presentation/pages/deployment_result_page.dart';

        class AppRouter {
          static final router = GoRouter(
            initialLocation: '/splash',
            routes: [
              GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
              GoRoute(path: '/welcome', builder: (context, state) => const WelcomePage()),
              GoRoute(path: '/step1', builder: (context, state) => const ClientDetailsPage()),
              GoRoute(path: '/step2', builder: (context, state) => const CompanyInfoPage()),
              GoRoute(
                path: '/company-form',
                builder: (context, state) {
                  final index = state.extra as int?;
                  return CompanyFormPage(companyIndex: index);
                },
              ),
              GoRoute(path: '/step3', builder: (context, state) => const AdminCredentialsPage()),
              GoRoute(path: '/step4', builder: (context, state) => const LicensePage()),
              GoRoute(path: '/step5', builder: (context, state) => const UrlsPage()),
              GoRoute(path: '/step6', builder: (context, state) => const ModulesPage()),
              GoRoute(path: '/review', builder: (context, state) => const ReviewPage()),
              GoRoute(path: '/deploying', builder: (context, state) => const DeploymentProgressPage()),
              GoRoute(path: '/result', builder: (context, state) => const DeploymentResultPage()),
            ],
          );
        }
    """,
    "lib/core/app_theme.dart": """
        import 'package:flutter/material.dart';

        class AppTheme {
          static final lightTheme = ThemeData(
            primaryColor: const Color(0xFF0D47A1),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Inter',
            
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              secondary: Color(0xFF1976D2),
              background: Colors.white,
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Color(0xFF333333),
              onSurface: Color(0xFF333333),
              error: Color(0xFFD32F2F),
              onError: Colors.white,
            ),

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D47A1),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
              ),
              labelStyle: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),

            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),

            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0)
            ),
          );
        }
    """,
    "lib/core/constants.dart": """
        class AppConstants {
          static const Map<int, String> systemModules = {
            1: 'CRM',
            2: 'Sales',
            3: 'Procurement',
            4: 'Inventory',
            5: 'User Management',
            6: 'Finance',
            7: 'HR & Payroll',
          };

          static const int userManagementModuleId = 5;
        }
    """,
    "lib/domain/entities/deployment_entities.dart": """
        import 'package:equatable/equatable.dart';

        class ClientDeploymentRequest extends Equatable {
          final String clientName;
          final String databaseTypePrefix;
          final List<CompanyInfo> companies;
          final AdminUserInfo adminUser;
          final LicenseInfo license;
          final List<int> selectedModuleIds;
          final CompanyUrls urls;

          const ClientDeploymentRequest({
            required this.clientName,
            this.databaseTypePrefix = "Pro",
            required this.companies,
            required this.adminUser,
            required this.license,
            required this.selectedModuleIds,
            required this.urls,
          });

          Map<String, dynamic> toJson() => {
                'clientName': clientName,
                'databaseTypePrefix': databaseTypePrefix,
                'companies': companies.map((c) => c.toJson()).toList(),
                'adminUser': adminUser.toJson(),
                'license': license.toJson(),
                'selectedModuleIds': selectedModuleIds,
                'urls': urls.toJson(),
              };

          @override
          List<Object?> get props => [
                clientName,
                databaseTypePrefix,
                companies,
                adminUser,
                license,
                selectedModuleIds,
                urls
              ];
        }

        class CompanyInfo extends Equatable {
          final String companyName;
          final String address1;
          final String address2;
          final String city;
          final String country;
          final String phoneNumber;
          final String logoUrl;

          const CompanyInfo({
            this.companyName = '',
            this.address1 = '',
            this.address2 = '',
            this.city = '',
            this.country = '',
            this.phoneNumber = '',
            this.logoUrl = '',
          });
          
          CompanyInfo copyWith({
            String? companyName,
            String? address1,
            String? address2,
            String? city,
            String? country,
            String? phoneNumber,
          }) {
            return CompanyInfo(
              companyName: companyName ?? this.companyName,
              address1: address1 ?? this.address1,
              address2: address2 ?? this.address2,
              city: city ?? this.city,
              country: country ?? this.country,
              phoneNumber: phoneNumber ?? this.phoneNumber,
              logoUrl: logoUrl,
            );
          }

          Map<String, dynamic> toJson() => {
                'companyName': companyName,
                'address1': address1,
                'address2': address2,
                'city': city,
                'country': country,
                'phoneNumber': phoneNumber,
                'logoUrl': logoUrl,
              };

          @override
          List<Object?> get props =>
              [companyName, address1, address2, city, country, phoneNumber, logoUrl];
        }

        class AdminUserInfo extends Equatable {
          final String email;
          final String contactNumber;
          final String branch;
          final String password;

          const AdminUserInfo({
            this.email = '',
            this.contactNumber = '',
            this.branch = 'HO',
            this.password = '',
          });

          Map<String, dynamic> toJson() => {
                'email': email,
                'contactNumber': contactNumber,
                'branch': branch,
                'password': password,
              };

          @override
          List<Object?> get props => [email, contactNumber, branch, password];
        }

        class LicenseInfo extends Equatable {
          final DateTime endDate;
          final int numberOfUsers;
          final bool usesNewEncryption;

          const LicenseInfo({
            required this.endDate,
            this.numberOfUsers = 1000,
            this.usesNewEncryption = true,
          });

          Map<String, dynamic> toJson() => {
                'endDate': endDate.toIso8601String(),
                'numberOfUsers': numberOfUsers,
                'usesNewEncryption': usesNewEncryption,
              };

          @override
          List<Object?> get props => [endDate, numberOfUsers, usesNewEncryption];
        }

        class CompanyUrls extends Equatable {
          final String crmurl;
          final String tradingURL;
          final String integrationURL;

          const CompanyUrls({
            this.crmurl = '',
            this.tradingURL = '',
            this.integrationURL = '',
          });

          Map<String, dynamic> toJson() => {
                'crmurl': crmurl,
                'tradingURL': tradingURL,
                'integrationURL': integrationURL,
              };
                
          @override
          List<Object?> get props => [crmurl, tradingURL, integrationURL];
        }

        class DeploymentResult extends Equatable {
          final bool isSuccess;
          final String errorMessage;
          final String clientHubDatabase;
          final List<String> createdCompanyDatabases;
          final List<String> logMessages;

          const DeploymentResult({
            required this.isSuccess,
            this.errorMessage = '',
            this.clientHubDatabase = '',
            this.createdCompanyDatabases = const [],
            this.logMessages = const [],
          });

          factory DeploymentResult.fromJson(Map<String, dynamic> json) =>
              DeploymentResult(
                isSuccess: json['isSuccess'] ?? false,
                errorMessage: json['errorMessage'] ?? '',
                clientHubDatabase: json['clientHubDatabase'] ?? '',
                createdCompanyDatabases:
                    List<String>.from(json['createdCompanyDatabases'] ?? []),
                logMessages: List<String>.from(json['logMessages'] ?? []),
              );

          @override
          List<Object?> get props => [
                isSuccess,
                errorMessage,
                clientHubDatabase,
                createdCompanyDatabases,
                logMessages
              ];
        }
    """,
    "lib/domain/repositories/deployment_repository.dart": """
        import 'package:client_deployment_app/domain/entities/deployment_entities.dart';

        abstract class DeploymentRepository {
          Future<DeploymentResult> deployClient(ClientDeploymentRequest request);
        }
    """,
    "lib/domain/usecases/deploy_client.dart": """
        import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
        import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';

        class DeployClient {
          final DeploymentRepository repository;

          DeployClient({required this.repository});

          Future<DeploymentResult> call(ClientDeploymentRequest request) {
            return repository.deployClient(request);
          }
        }
    """,
    "lib/data/datasources/api_service.dart": """
        import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
        import 'package:dio/dio.dart';

        class ApiService {
          final Dio dio;

          ApiService({required this.dio});

          Future<DeploymentResult> deployClient(ClientDeploymentRequest request) async {
            const endpoint = 'api/ClientDeployment/deploy';
            final response = await dio.post(endpoint, data: request.toJson());
            return DeploymentResult.fromJson(response.data);
          }
        }
    """,
    "lib/data/repositories/deployment_repository_impl.dart": """
        import 'package:client_deployment_app/data/datasources/api_service.dart';
        import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
        import 'package:client_deployment_app/domain/repositories/deployment_repository.dart';
        import 'package:dio/dio.dart';

        class DeploymentRepositoryImpl implements DeploymentRepository {
          final ApiService apiService;

          DeploymentRepositoryImpl({required this.apiService});

          @override
          Future<DeploymentResult> deployClient(ClientDeploymentRequest request) async {
            try {
              return await apiService.deployClient(request);
            } on DioException catch (e) {
              return DeploymentResult(
                isSuccess: false,
                errorMessage: e.response?.data?['errorMessage'] ?? 'A network error occurred: ${e.message}',
              );
            } catch (e) {
              return DeploymentResult(
                isSuccess: false,
                errorMessage: 'An unexpected error occurred: ${e.toString()}',
              );
            }
          }
        }
    """,
    "lib/presentation/cubits/onboarding_cubit.dart": """
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
          
          void addCompany(CompanyInfo company) {
            final List<CompanyInfo> updatedCompanies = List.from(state.companies);
            updatedCompanies.add(company);
            
            final testCompany = company.copyWith(companyName: '${company.companyName} Test');
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

          void updateAdminInfo({String? email, String? contactNumber, String? password, String? branch}) {
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
          
          void updateLicenseInfo({DateTime? endDate, int? numberOfUsers, bool? usesNewEncryption}) {
            final currentLicense = state.license;
            emit(state.copyWith(
              license: LicenseInfo(
                endDate: endDate ?? currentLicense.endDate,
                numberOfUsers: numberOfUsers ?? currentLicense.numberOfUsers,
                usesNewEncryption: usesNewEncryption ?? currentLicense.usesNewEncryption,
              )
            ));
          }

          void updateUrls({String? crmUrl, String? tradingUrl, String? integrationUrl}) {
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
              companies: state.companies,
              adminUser: state.adminUser,
              license: state.license,
              selectedModuleIds: state.selectedModuleIds,
              urls: state.urls,
            );

            final result = await _deployClient(request);

            emit(state.copyWith(
              deploymentStatus: result.isSuccess ? DeploymentStatus.success : DeploymentStatus.failure,
              deploymentResult: result,
              errorMessage: result.errorMessage,
            ));
          }
        }
    """,
    "lib/presentation/cubits/onboarding_state.dart": """
        part of 'onboarding_cubit.dart';

        enum DeploymentStatus { initial, loading, success, failure }

        class OnboardingState extends Equatable {
          final String clientName;
          final List<CompanyInfo> companies;
          final AdminUserInfo adminUser;
          final LicenseInfo license;
          final List<int> selectedModuleIds;
          final CompanyUrls urls;
          
          final DeploymentStatus deploymentStatus;
          final DeploymentResult? deploymentResult;
          final String? errorMessage;

          const OnboardingState({
            required this.clientName,
            required this.companies,
            required this.adminUser,
            required this.license,
            required this.selectedModuleIds,
            required this.urls,
            this.deploymentStatus = DeploymentStatus.initial,
            this.deploymentResult,
            this.errorMessage,
          });

          factory OnboardingState.initial() {
            return OnboardingState(
              clientName: '',
              companies: const [],
              adminUser: const AdminUserInfo(),
              license: LicenseInfo(endDate: DateTime.now().add(const Duration(days: 730))),
              selectedModuleIds: const [5],
              urls: const CompanyUrls(),
            );
          }

          OnboardingState copyWith({
            String? clientName,
            List<CompanyInfo>? companies,
            AdminUserInfo? adminUser,
            LicenseInfo? license,
            List<int>? selectedModuleIds,
            CompanyUrls? urls,
            DeploymentStatus? deploymentStatus,
            DeploymentResult? deploymentResult,
            String? errorMessage,
          }) {
            return OnboardingState(
              clientName: clientName ?? this.clientName,
              companies: companies ?? this.companies,
              adminUser: adminUser ?? this.adminUser,
              license: license ?? this.license,
              selectedModuleIds: selectedModuleIds ?? this.selectedModuleIds,
              urls: urls ?? this.urls,
              deploymentStatus: deploymentStatus ?? this.deploymentStatus,
              deploymentResult: deploymentResult ?? this.deploymentResult,
              errorMessage: errorMessage ?? this.errorMessage,
            );
          }

          @override
          List<Object?> get props => [
                clientName,
                companies,
                adminUser,
                license,
                selectedModuleIds,
                urls,
                deploymentStatus,
                deploymentResult,
                errorMessage,
              ];
        }
    """,
    "lib/presentation/pages/splash_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:go_router/go_router.dart';

        class SplashPage extends StatefulWidget {
          const SplashPage({super.key});

          @override
          State<SplashPage> createState() => _SplashPageState();
        }

        class _SplashPageState extends State<SplashPage> {
          @override
          void initState() {
            super.initState();
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                context.go('/welcome');
              }
            });
          }

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_rounded, size: 120, color: Color(0xFF0D47A1)),
                    const SizedBox(height: 20),
                    Text(
                      'Client Deployment Tool',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          }
        }
    """,
    "lib/presentation/pages/welcome_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';


        class WelcomePage extends StatelessWidget {
          const WelcomePage({super.key});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch_rounded, size: 100, color: Color(0xFF1976D2)),
                      const SizedBox(height: 24),
                      Text(
                        'Automated Client Onboarding',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This wizard will guide you through the process of setting up and deploying a new client environment.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          context.read<OnboardingCubit>().startNewSession();
                          context.push('/step1');
                        },
                        child: const Text('Start New Onboarding'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
    """,
    "lib/presentation/pages/step_1_client_details_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';
        import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

        class ClientDetailsPage extends StatefulWidget {
          const ClientDetailsPage({super.key});

          @override
          State<ClientDetailsPage> createState() => _ClientDetailsPageState();
        }

        class _ClientDetailsPageState extends State<ClientDetailsPage> {
          final _formKey = GlobalKey<FormState>();

          @override
          Widget build(BuildContext context) {
            final clientName = context.select((OnboardingCubit cubit) => cubit.state.clientName);
            
            return Form(
              key: _formKey,
              child: WizardScaffold(
                title: 'Step 1: Client Details',
                isNextEnabled: clientName.isNotEmpty,
                onNext: () {
                  if (_formKey.currentState!.validate()) {
                    context.push('/step2');
                  }
                },
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter the name of the new client. This will be used to generate database names and other identifiers.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    CustomTextFormField(
                      labelText: 'Client Name',
                      initialValue: context.read<OnboardingCubit>().state.clientName,
                      onChanged: (value) {
                        context.read<OnboardingCubit>().updateClientName(value);
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Client name is required.';
                        }
                        if (value.length < 2) {
                          return 'Client name must be at least 2 characters.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        }
    """,
    "lib/presentation/pages/step_2_company_info_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
        import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';

        class CompanyInfoPage extends StatelessWidget {
          const CompanyInfoPage({super.key});

          @override
          Widget build(BuildContext context) {
            return BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                return WizardScaffold(
                  title: 'Step 2: Company Info',
                  isNextEnabled: state.companies.isNotEmpty,
                  onNext: () => context.push('/step3'),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Add one or more companies. A "Test" version will be auto-generated.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 16),
                          FloatingActionButton.small(
                            onPressed: () => context.push('/company-form'),
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state.companies.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No companies added yet. Tap the + button to start.'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.companies.length,
                          itemBuilder: (context, index) {
                            final company = state.companies[index];
                            return CompanyInfoTile(
                              company: company,
                              onTap: () => context.push('/company-form', extra: index),
                              onDelete: () => context.read<OnboardingCubit>().deleteCompany(index),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          }
        }

        class CompanyInfoTile extends StatelessWidget {
          final CompanyInfo company;
          final VoidCallback onTap;
          final VoidCallback onDelete;

          const CompanyInfoTile({
            super.key,
            required this.company,
            required this.onTap,
            required this.onDelete,
          });

          @override
          Widget build(BuildContext context) {
            return Card(
              child: ListTile(
                title: Text(company.companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(company.city.isNotEmpty && company.country.isNotEmpty
                    ? '${company.city}, ${company.country}'
                    : 'No location details'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: onTap,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                onTap: onTap,
              ),
            );
          }
        }
    """,
    "lib/presentation/pages/company_form_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

        class CompanyFormPage extends StatefulWidget {
          final int? companyIndex;

          const CompanyFormPage({super.key, this.companyIndex});

          @override
          State<CompanyFormPage> createState() => _CompanyFormPageState();
        }

        class _CompanyFormPageState extends State<CompanyFormPage> {
          final _formKey = GlobalKey<FormState>();
          late final TextEditingController _nameController;
          late final TextEditingController _address1Controller;
          late final TextEditingController _cityController;
          late final TextEditingController _countryController;
          late final TextEditingController _phoneController;

          @override
          void initState() {
            super.initState();
            final cubit = context.read<OnboardingCubit>();
            CompanyInfo company = const CompanyInfo();

            if (widget.companyIndex != null) {
              company = cubit.state.companies[widget.companyIndex!];
            }

            _nameController = TextEditingController(text: company.companyName);
            _address1Controller = TextEditingController(text: company.address1);
            _cityController = TextEditingController(text: company.city);
            _countryController = TextEditingController(text: company.country);
            _phoneController = TextEditingController(text: company.phoneNumber);
          }

          @override
          void dispose() {
            _nameController.dispose();
            _address1Controller.dispose();
            _cityController.dispose();
            _countryController.dispose();
            _phoneController.dispose();
            super.dispose();
          }

          void _onSave() {
            if (_formKey.currentState!.validate()) {
              final cubit = context.read<OnboardingCubit>();
              final newCompanyInfo = CompanyInfo(
                companyName: _nameController.text,
                address1: _address1Controller.text,
                city: _cityController.text,
                country: _countryController.text,
                phoneNumber: _phoneController.text,
              );

              if (widget.companyIndex != null) {
                cubit.updateCompany(widget.companyIndex!, newCompanyInfo);
              } else {
                cubit.addCompany(newCompanyInfo);
              }
              context.pop();
            }
          }

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.companyIndex == null ? 'Add Company' : 'Edit Company'),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextFormField(
                        controller: _nameController,
                        labelText: 'Company Name',
                        validator: (val) => val!.isEmpty ? 'Required field' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _address1Controller,
                        labelText: 'Address',
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _cityController,
                        labelText: 'City',
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _countryController,
                        labelText: 'Country',
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _phoneController,
                        labelText: 'Phone Number',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _onSave,
                        child: const Text('Save Company'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
    """,
    "lib/presentation/pages/step_3_admin_credentials_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';
        import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

        class AdminCredentialsPage extends StatefulWidget {
          const AdminCredentialsPage({super.key});

          @override
          State<AdminCredentialsPage> createState() => _AdminCredentialsPageState();
        }

        class _AdminCredentialsPageState extends State<AdminCredentialsPage> {
          final _formKey = GlobalKey<FormState>();

          @override
          Widget build(BuildContext context) {
            final adminUser = context.select((OnboardingCubit cubit) => cubit.state.adminUser);
            
            return Form(
              key: _formKey,
              child: WizardScaffold(
                title: 'Step 3: Admin Credentials',
                isNextEnabled: adminUser.email.isNotEmpty && adminUser.password.isNotEmpty && adminUser.contactNumber.isNotEmpty,
                onNext: () {
                  if (_formKey.currentState!.validate()) {
                    context.push('/step4');
                  }
                },
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set up the primary administrator account for this client.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    CustomTextFormField(
                      labelText: 'Admin Email',
                      initialValue: adminUser.email,
                      onChanged: (value) => context.read<OnboardingCubit>().updateAdminInfo(email: value),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required.';
                        if (!RegExp(r'^[^@]+@[^@]+\\.[^@]+').hasMatch(value)) return 'Enter a valid email.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      labelText: 'Admin Contact Number',
                      initialValue: adminUser.contactNumber,
                      onChanged: (value) => context.read<OnboardingCubit>().updateAdminInfo(contactNumber: value),
                      keyboardType: TextInputType.phone,
                       validator: (val) => val!.isEmpty ? 'Contact number is required.' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      labelText: 'Password',
                      initialValue: adminUser.password,
                      obscureText: true,
                      onChanged: (value) => context.read<OnboardingCubit>().updateAdminInfo(password: value),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required.';
                        if (value.length < 6) return 'Password must be at least 6 characters.';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        }
    """,
    "lib/presentation/pages/step_4_license_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:intl/intl.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';
        import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

        class LicensePage extends StatelessWidget {
          const LicensePage({super.key});

          Future<void> _selectDate(BuildContext context) async {
            final cubit = context.read<OnboardingCubit>();
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: cubit.state.license.endDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != cubit.state.license.endDate) {
              cubit.updateLicenseInfo(endDate: picked);
            }
          }

          @override
          Widget build(BuildContext context) {
            return BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                return WizardScaffold(
                  title: 'Step 4: License',
                  onNext: () => context.push('/step5'),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configure the software license and user limits for this client.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        labelText: 'Number of Users',
                        initialValue: state.license.numberOfUsers.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final users = int.tryParse(value);
                          if (users != null) {
                            context.read<OnboardingCubit>().updateLicenseInfo(numberOfUsers: users);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        title: const Text('License End Date'),
                        subtitle: Text(DateFormat.yMMMd().format(state.license.endDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Use New Encryption'),
                        value: state.license.usesNewEncryption,
                        onChanged: (bool value) {
                          context.read<OnboardingCubit>().updateLicenseInfo(usesNewEncryption: value);
                        },
                        secondary: const Icon(Icons.enhanced_encryption),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
    """,
    "lib/presentation/pages/step_5_urls_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';
        import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

        class UrlsPage extends StatelessWidget {
          const UrlsPage({super.key});

          @override
          Widget build(BuildContext context) {
            final urls = context.read<OnboardingCubit>().state.urls;
            return WizardScaffold(
              title: 'Step 5: System URLs',
              onNext: () => context.push('/step6'),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Provide the URLs for the client\\'s different system endpoints.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  CustomTextFormField(
                    labelText: 'CRM URL',
                    initialValue: urls.crmurl,
                    onChanged: (value) =>
                        context.read<OnboardingCubit>().updateUrls(crmUrl: value),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    labelText: 'Trading URL',
                    initialValue: urls.tradingURL,
                    onChanged: (value) =>
                        context.read<OnboardingCubit>().updateUrls(tradingUrl: value),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    labelText: 'Integration URL',
                    initialValue: urls.integrationURL,
                    onChanged: (value) => context
                        .read<OnboardingCubit>()
                        .updateUrls(integrationUrl: value),
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            );
          }
        }
    """,
    "lib/presentation/pages/step_6_modules_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/core/constants.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';

        class ModulesPage extends StatelessWidget {
          const ModulesPage({super.key});

          @override
          Widget build(BuildContext context) {
            return BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                return WizardScaffold(
                  title: 'Step 6: Select Modules',
                  onNext: () => context.push('/review'),
                  nextButtonText: 'Review',
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select the modules to be enabled for this client. "User Management" is required and cannot be deselected.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: AppConstants.systemModules.entries.map((entry) {
                          final moduleId = entry.key;
                          final moduleName = entry.value;
                          final isSelected = state.selectedModuleIds.contains(moduleId);
                          final isMandatory = moduleId == AppConstants.userManagementModuleId;

                          return Card(
                            elevation: isSelected ? 4 : 1,
                            color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                            child: CheckboxListTile(
                              title: Text(moduleName, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              value: isSelected,
                              onChanged: isMandatory ? null : (bool? value) {
                                context.read<OnboardingCubit>().toggleModule(moduleId);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
    """,
    "lib/presentation/pages/step_7_review_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:intl/intl.dart';
        import 'package:client_deployment_app/core/constants.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';

        class ReviewPage extends StatelessWidget {
          const ReviewPage({super.key});

          @override
          Widget build(BuildContext context) {
            final state = context.watch<OnboardingCubit>().state;

            return Scaffold(
              appBar: AppBar(title: const Text('Review & Deploy')),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _ReviewSection(
                                title: 'Client Details',
                                onEdit: () => context.go('/step1'),
                                children: [
                                  _buildReviewRow('Client Name:', state.clientName),
                                ],
                              ),
                              _ReviewSection(
                                title: 'Companies',
                                onEdit: () => context.go('/step2'),
                                children: state.companies
                                    .map((c) => _buildReviewRow('• ${c.companyName}', c.city.isNotEmpty ? '${c.city}, ${c.country}' : c.address1))
                                    .toList(),
                              ),
                              _ReviewSection(
                                title: 'Admin Credentials',
                                onEdit: () => context.go('/step3'),
                                children: [
                                  _buildReviewRow('Email:', state.adminUser.email),
                                  _buildReviewRow('Contact:', state.adminUser.contactNumber),
                                  _buildReviewRow('Password:', '********'),
                                ],
                              ),
                              _ReviewSection(
                                title: 'License',
                                onEdit: () => context.go('/step4'),
                                children: [
                                  _buildReviewRow('Users:', state.license.numberOfUsers.toString()),
                                  _buildReviewRow('End Date:', DateFormat.yMMMd().format(state.license.endDate)),
                                  _buildReviewRow('New Encryption:', state.license.usesNewEncryption ? 'Yes' : 'No'),
                                ],
                              ),
                               _ReviewSection(
                                title: 'System URLs',
                                onEdit: () => context.go('/step5'),
                                children: [
                                   _buildReviewRow('CRM:', state.urls.crmurl.isEmpty ? 'Not Set' : state.urls.crmurl),
                                   _buildReviewRow('Trading:', state.urls.tradingURL.isEmpty ? 'Not Set' : state.urls.tradingURL),
                                   _buildReviewRow('Integration:', state.urls.integrationURL.isEmpty ? 'Not Set' : state.urls.integrationURL),
                                ],
                              ),
                              _ReviewSection(
                                title: 'Selected Modules',
                                onEdit: () => context.go('/step6'),
                                children: state.selectedModuleIds
                                    .map((id) => _buildReviewRow('•', AppConstants.systemModules[id] ?? 'Unknown Module'))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(onPressed: () => context.pop(), child: const Text('Back')),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.rocket_launch),
                            label: const Text('Deploy Client'),
                            onPressed: () {
                              context.read<OnboardingCubit>().submitDeployment();
                              context.push('/deploying');
                            },
                             style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15)
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          Widget _buildReviewRow(String label, String value) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Text(value)),
                ],
              ),
            );
          }
        }

        class _ReviewSection extends StatelessWidget {
          final String title;
          final VoidCallback onEdit;
          final List<Widget> children;

          const _ReviewSection({required this.title, required this.onEdit, required this.children});

          @override
          Widget build(BuildContext context) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleLarge),
                        TextButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          onPressed: onEdit,
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    ...children,
                  ],
                ),
              ),
            );
          }
        }
    """,
    "lib/presentation/pages/deployment_progress_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';

        class DeploymentProgressPage extends StatelessWidget {
          const DeploymentProgressPage({super.key});

          @override
          Widget build(BuildContext context) {
            return BlocListener<OnboardingCubit, OnboardingState>(
              listener: (context, state) {
                if (state.deploymentStatus != DeploymentStatus.loading) {
                  context.go('/result');
                }
              },
              child: const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(strokeWidth: 5),
                      SizedBox(height: 24),
                      Text(
                        'Deployment in progress...',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      Text('Please wait, this may take a few minutes.'),
                    ],
                  ),
                ),
              ),
            );
          }
        }
    """,
    "lib/presentation/pages/deployment_result_page.dart": """
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
        import 'package:client_deployment_app/core/utils/report_generator.dart';

        class DeploymentResultPage extends StatelessWidget {
          const DeploymentResultPage({super.key});

          @override
          Widget build(BuildContext context) {
            return BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                final result = state.deploymentResult;
                final isSuccess = state.deploymentStatus == DeploymentStatus.success;
                final colorScheme = Theme.of(context).colorScheme;

                return Scaffold(
                  appBar: AppBar(
                    title: Text(isSuccess ? 'Deployment Successful' : 'Deployment Failed'),
                    backgroundColor: isSuccess ? Colors.green.shade700 : colorScheme.error,
                    automaticallyImplyLeading: false,
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                            color: isSuccess ? Colors.green.shade700 : colorScheme.error,
                            size: 100,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isSuccess
                                ? 'The new client environment has been successfully deployed.'
                                : 'There was an error during deployment. Please review the logs.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          if (result != null) ...[
                            if (!isSuccess && result.errorMessage.isNotEmpty)
                              Card(
                                color: colorScheme.error.withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    result.errorMessage,
                                    style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text('Deployment Log:', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                itemCount: result.logMessages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Text('• ${result.logMessages[index]}'),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text('Share Report as PDF'),
                            onPressed: result != null
                                ? () => ReportGenerator.generateAndShareReport(result)
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              context.read<OnboardingCubit>().startNewSession();
                              context.go('/welcome');
                            },
                            child: const Text('Start Another Onboarding'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
    """,
    "lib/core/utils/report_generator.dart": """
        import 'dart:io';
        import 'package:pdf/pdf.dart';
        import 'package:pdf/widgets.dart' as pw;
        import 'package:path_provider/path_provider.dart';
        import 'package:share_plus/share_plus.dart';
        import 'package:client_deployment_app/domain/entities/deployment_entities.dart';

        class ReportGenerator {
          static Future<void> generateAndShareReport(DeploymentResult result) async {
            final pdf = pw.Document();

            pdf.addPage(
              pw.MultiPage(
                pageFormat: PdfPageFormat.a4,
                margin: const pw.EdgeInsets.all(32),
                build: (context) => [
                  _buildHeader(result),
                  pw.SizedBox(height: 20),
                  _buildSummary(result),
                  pw.SizedBox(height: 20),
                  if (result.isSuccess) ...[
                    _buildDatabasesSection(result),
                    pw.SizedBox(height: 20),
                  ],
                  _buildLogSection(result.logMessages),
                  if (!result.isSuccess) ...[
                    pw.SizedBox(height: 20),
                    _buildErrorSection(result.errorMessage),
                  ],
                ],
              ),
            );

            final directory = await getTemporaryDirectory();
            final file = File('${directory.path}/deployment_report.pdf');
            await file.writeAsBytes(await pdf.save());

            await Share.shareXFiles(
              [XFile(file.path)],
              text: 'Client Deployment Report',
            );
          }

          static pw.Widget _buildHeader(DeploymentResult result) {
            return pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Client Deployment Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    DateTime.now().toIso8601String().split('T').first,
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                  ),
                ],
              ),
            );
          }

          static pw.Widget _buildSummary(DeploymentResult result) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: result.isSuccess ? PdfColors.green50 : PdfColors.red50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Deployment Summary',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Divider(height: 10, color: PdfColors.grey400),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Status:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        result.isSuccess ? 'SUCCESS' : 'FAILURE',
                        style: pw.TextStyle(
                          color: result.isSuccess ? PdfColors.green : PdfColors.red,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          static pw.Widget _buildDatabasesSection(DeploymentResult result) {
            if (result.clientHubDatabase.isEmpty && result.createdCompanyDatabases.isEmpty) {
              return pw.Container();
            }
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Created Databases',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Table.fromTextArray(
                  headers: ['Type', 'Database Name'],
                  data: [
                    if (result.clientHubDatabase.isNotEmpty)
                      ['Client Hub', result.clientHubDatabase],
                    ...result.createdCompanyDatabases.map((db) => ['Company', db]).toList(),
                  ],
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.all(5),
                ),
              ],
            );
          }

          static pw.Widget _buildLogSection(List<String> logMessages) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Deployment Log',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: logMessages
                        .map((log) => pw.Text('• $log', style: const pw.TextStyle(fontSize: 10)))
                        .toList(),
                  ),
                ),
              ],
            );
          }

          static pw.Widget _buildErrorSection(String errorMessage) {
            if (errorMessage.isEmpty) return pw.Container();
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Error Message',
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red),
                ),
                pw.SizedBox(height: 5),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                    color: PdfColors.red50,
                  ),
                  child: pw.Text(
                    errorMessage,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.red800),
                  ),
                ),
              ],
            );
          }
        }
    """,
    "lib/presentation/widgets/wizard_scaffold.dart": """
        import 'package:flutter/material.dart';
        import 'package:go_router/go_router.dart';

        class WizardScaffold extends StatelessWidget {
          final String title;
          final Widget body;
          final VoidCallback? onNext;
          final String nextButtonText;
          final bool isNextEnabled;

          const WizardScaffold({
            super.key,
            required this.title,
            required this.body,
            this.onNext,
            this.nextButtonText = 'Next',
            this.isNextEnabled = true,
          });

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(title),
                automaticallyImplyLeading: context.canPop(),
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: body,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (context.canPop())
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Back'),
                            ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: isNextEnabled ? onNext : null,
                            child: Text(nextButtonText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
    """,
    "lib/presentation/widgets/custom_text_form_field.dart": """
        import 'package:flutter/material.dart';

        class CustomTextFormField extends StatelessWidget {
          final TextEditingController? controller;
          final String labelText;
          final String? initialValue;
          final bool obscureText;
          final ValueChanged<String>? onChanged;
          final FormFieldValidator<String>? validator;
          final TextInputType keyboardType;

          const CustomTextFormField({
            super.key,
            this.controller,
            required this.labelText,
            this.initialValue,
            this.obscureText = false,
            this.onChanged,
            this.validator,
            this.keyboardType = TextInputType.text,
          });

          @override
          Widget build(BuildContext context) {
            return TextFormField(
              controller: controller,
              initialValue: initialValue,
              obscureText: obscureText,
              onChanged: onChanged,
              validator: validator,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: labelText,
              ),
            );
          }
        }
    """,
}


def create_project_structure():
    """Creates the necessary directories for the Flutter project."""
    print("Creating project directories...")
    directories = [
        "lib/core",
        "lib/core/utils",
        "lib/data/datasources",
        "lib/data/repositories",
        "lib/domain/entities",
        "lib/domain/repositories",
        "lib/domain/usecases",
        "lib/presentation/cubits",
        "lib/presentation/pages",
        "lib/presentation/widgets",
        "assets/icons"
    ]
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
    print("Directories created successfully.")


def create_project_files():
    """Creates and writes the content to all project files."""
    print("Generating project files...")
    total_files = len(PROJECT_FILES)
    for i, (path, content) in enumerate(PROJECT_FILES.items()):
        try:
            # textwrap.dedent removes leading whitespace from multiline strings
            with open(path, "w", encoding="utf-8") as f:
                f.write(textwrap.dedent(content).strip())
            print(f"({i+1}/{total_files}) ✓ Created {path}")
        except IOError as e:
            print(f"(!) Error creating file {path}: {e}")
    print("All project files generated successfully.")


def main():
    """Main function to orchestrate the project creation."""
    print("==================================================")
    print("  Flutter Client Deployment App Project Builder   ")
    print("==================================================")
    create_project_structure()
    print("-" * 50)
    create_project_files()
    print("-" * 50)
    print("Project setup is complete!")
    print("\nNext steps:")
    print("1. Open your terminal in this directory.")
    print("2. Run 'flutter pub get' to install dependencies.")
    print("3. Run 'flutter run' to start the application.")
    print("==================================================")


if __name__ == "__main__":
    main()
