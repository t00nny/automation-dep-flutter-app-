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
        final request =
            state.deploymentRequest; // ADDED: Get the deployment request
        final isSuccess = state.deploymentStatus == DeploymentStatus.success;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title:
                Text(isSuccess ? 'Deployment Successful' : 'Deployment Failed'),
            backgroundColor:
                isSuccess ? Colors.green.shade700 : colorScheme.error,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color:
                        isSuccess ? Colors.green.shade700 : colorScheme.error,
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
                        color: colorScheme.error.withAlpha((255 * 0.1).round()),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            result.errorMessage,
                            style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // MODIFIED: Updated to show a summary instead of logs
                    Text('Deployment Summary:',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((255 * 0.05).round()),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Client: ${state.clientName}'),
                          Text(
                              '• Database Prefix: ${state.databaseTypePrefix}'),
                          Text(
                              '• Companies: ${state.companies.length + (state.testCompany != null ? 1 : 0)}'),
                          Text(
                              '• License Users: ${state.license.numberOfUsers}'),
                          Text(
                              '• Enabled Modules: ${state.selectedModuleIds.length}'),
                          if (result.clientHubDatabase.isNotEmpty)
                            Text(
                                '• Client Hub DB: ${result.clientHubDatabase}'),
                          if (result.createdCompanyDatabases.isNotEmpty)
                            Text(
                                '• Company DBs: ${result.createdCompanyDatabases.length}'),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share Report as PDF'),
                    // MODIFIED: Pass both result and request to the report generator
                    onPressed: (result != null && request != null)
                        ? () => ReportGenerator.generateAndShareReport(
                            result, request)
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
