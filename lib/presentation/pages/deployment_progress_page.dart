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