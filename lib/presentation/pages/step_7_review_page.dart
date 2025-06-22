import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:client_deployment_app/core/constants.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingCubit>().state;

    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.deploymentStatus != DeploymentStatus.loading && _isLoading) {
          if (mounted) {
            setState(() => _isLoading = false);
            context.go('/result');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Step 7: Review & Deploy')),
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
                          isEditingEnabled: !_isLoading, // MODIFIED
                          onEdit: () => context.go('/step1'),
                          children: [
                            _buildReviewRow('Client Name:', state.clientName),
                            _buildReviewRow(
                                'DB Prefix:', state.databaseTypePrefix),
                          ],
                        ),
                        _ReviewSection(
                          title: 'Companies',
                          isEditingEnabled: !_isLoading, // MODIFIED
                          onEdit: () => context.go('/step2'),
                          children: [
                            ...state.companies.map((c) => _buildReviewRow(
                                '• ${c.companyName}',
                                c.city.isNotEmpty
                                    ? '${c.city}, ${c.country}'
                                    : c.address1)),
                            if (state.testCompany != null)
                              _buildReviewRow(
                                  '• ${state.testCompany!.companyName}',
                                  '(Test Environment)'),
                          ],
                        ),
                        _ReviewSection(
                          title: 'Admin Credentials',
                          isEditingEnabled: !_isLoading, // MODIFIED
                          onEdit: () => context.go('/step3'),
                          children: [
                            _buildReviewRow('Email:', state.adminUser.email),
                            _buildReviewRow(
                                'Contact:', state.adminUser.contactNumber),
                            _buildReviewRow('Password:', '********'),
                          ],
                        ),
                        _ReviewSection(
                          title: 'License',
                          isEditingEnabled: !_isLoading, // MODIFIED
                          onEdit: () => context.go('/step4'),
                          children: [
                            _buildReviewRow('Users:',
                                state.license.numberOfUsers.toString()),
                            _buildReviewRow(
                                'End Date:',
                                DateFormat.yMMMd()
                                    .format(state.license.endDate)),
                            _buildReviewRow('New Encryption:',
                                state.license.usesNewEncryption ? 'Yes' : 'No'),
                          ],
                        ),
                        _ReviewSection(
                          title: 'System URLs',
                          isEditingEnabled: !_isLoading, // MODIFIED
                          onEdit: () => context.go('/step5'),
                          children: [
                            _buildReviewRow(
                                'CRM:',
                                state.urls.crmurl.isEmpty
                                    ? 'Not Set'
                                    : state.urls.crmurl),
                            _buildReviewRow(
                                'Trading:',
                                state.urls.tradingURL.isEmpty
                                    ? 'Not Set'
                                    : state.urls.tradingURL),
                            _buildReviewRow(
                                'Integration:',
                                state.urls.integrationURL.isEmpty
                                    ? 'Not Set'
                                    : state.urls.integrationURL),
                          ],
                        ),
                        _ReviewSection(
                          title: 'Selected Modules',
                          isEditingEnabled: !_isLoading, // MODIFIED
                          onEdit: () => context.go('/step6'),
                          children: state.selectedModuleIds
                              .map((id) => _buildReviewRow(
                                  '•',
                                  AppConstants.systemModules[id] ??
                                      'Unknown Module'))
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
                    TextButton(
                        onPressed: _isLoading ? null : () => context.pop(),
                        child: const Text('Back')),
                    ElevatedButton.icon(
                      icon: _isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(Icons.rocket_launch),
                      label:
                          Text(_isLoading ? 'Deploying...' : 'Deploy Client'),
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _isLoading = true);
                              context
                                  .read<OnboardingCubit>()
                                  .submitDeployment();
                            },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 15)),
                    ),
                  ],
                ),
              ],
            ),
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
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
  final bool isEditingEnabled; // ADDED

  const _ReviewSection({
    required this.title,
    required this.onEdit,
    required this.children,
    this.isEditingEnabled = true, // ADDED
  });

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
                  // MODIFIED: Disable the button when isEditingEnabled is false
                  onPressed: isEditingEnabled ? onEdit : null,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
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
