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