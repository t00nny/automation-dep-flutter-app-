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