import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client_deployment_app/core/constants.dart';
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

  void _onNextPressed() async {
    if (_formKey.currentState!.validate()) {
      // Check if logo is selected
      final state = context.read<OnboardingCubit>().state;
      if (state.clientLogoFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a client logo before proceeding.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Clear any previous validation errors
      context.read<OnboardingCubit>().clearDatabaseValidationError();

      // Validate the database
      await context.read<OnboardingCubit>().validateClientDatabase();

      // Check if validation passed
      final updatedState = context.read<OnboardingCubit>().state;
      if (updatedState.databaseValidationError == null) {
        context.push('/step2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: WizardScaffold(
            title: 'Step 1: Client Details',
            currentStep: 1, // ADDED
            totalSteps: 7, // ADDED
            isNextEnabled: state.clientName.isNotEmpty &&
                state.clientLogoFile != null &&
                !state.isCheckingDatabase,
            onNext: _onNextPressed,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the client name and select the database prefix.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                CustomTextFormField(
                  labelText: 'Client Name',
                  prefixIcon: Icons.business_center_outlined, // ADDED
                  initialValue: state.clientName,
                  onChanged: (value) {
                    context.read<OnboardingCubit>().updateClientName(value);
                    // Clear validation error when user types
                    if (state.databaseValidationError != null) {
                      context
                          .read<OnboardingCubit>()
                          .clearDatabaseValidationError();
                    }
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
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: state.databaseTypePrefix,
                  decoration: InputDecoration(
                    // MODIFIED for consistency
                    labelText: 'Database Prefix',
                    prefixIcon: Icon(Icons.dns_outlined,
                        color: Theme.of(context).primaryColor),
                  ),
                  items: AppConstants.databasePrefixes
                      .map((prefix) => DropdownMenuItem(
                            value: prefix,
                            child: Text(prefix),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<OnboardingCubit>()
                          .updateDatabasePrefix(value);
                      // Clear validation error when user changes prefix
                      if (state.databaseValidationError != null) {
                        context
                            .read<OnboardingCubit>()
                            .clearDatabaseValidationError();
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Client Logo Section
                Row(
                  children: [
                    Text(
                      'Client Logo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '*',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (state.clientLogoFile != null) ...[
                        // Display selected logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                              image: FileImage(state.clientLogoFile!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () => context
                                  .read<OnboardingCubit>()
                                  .pickClientLogo(),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Change Logo'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => context
                                  .read<OnboardingCubit>()
                                  .removeClientLogo(),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remove'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Upload button
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Upload a logo for this client (Required)',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recommended: JPG, JPEG, or PNG (max 1024x1024)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              context.read<OnboardingCubit>().pickClientLogo(),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Logo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            foregroundColor: Theme.of(context).primaryColor,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Database validation loading indicator
                if (state.isCheckingDatabase)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Checking database availability...'),
                    ],
                  ),

                // Database validation error
                if (state.databaseValidationError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.databaseValidationError!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
