// lib/main.dart

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
        // MODIFIED: Changed the app title
        title: 'Deploy 360',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
