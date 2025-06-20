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