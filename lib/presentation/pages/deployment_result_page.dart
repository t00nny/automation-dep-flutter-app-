import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/core/utils/report_generator.dart';
import 'package:client_deployment_app/core/constants.dart';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';

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
                  // Status Icon and Message
                  Icon(
                    isSuccess
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color:
                        isSuccess ? Colors.green.shade700 : colorScheme.error,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSuccess
                        ? 'Deployment Completed Successfully!'
                        : 'Deployment Failed',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSuccess
                              ? Colors.green.shade700
                              : colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSuccess
                        ? 'Your client environment is ready to use.'
                        : 'Please review the error details below.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 32),

                  if (result != null && request != null) ...[
                    // Error Message (if deployment failed)
                    if (!isSuccess && result.errorMessage.isNotEmpty) ...[
                      Card(
                        color: colorScheme.error.withAlpha((255 * 0.1).round()),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: colorScheme.error),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Error Details',
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result.errorMessage,
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Deployment Report
                    _buildReportSection('📋 Deployment Report', [
                      _buildReportCard('Client Information', Icons.business, [
                        _buildReportItem('Client Name', state.clientName),
                        _buildReportItem(
                            'Database Prefix', state.databaseTypePrefix),
                        _buildReportItem('Deployment Date',
                            DateTime.now().toString().split(' ')[0]),
                        _buildReportItem(
                            'Status',
                            isSuccess ? 'Success' : 'Failed',
                            isSuccess ? Colors.green : Colors.red),
                      ]),
                      if (isSuccess) ...[
                        _buildReportCard('Created Resources', Icons.dns, [
                          if (result.clientHubDatabase.isNotEmpty)
                            _buildReportItem('Client Hub Database',
                                result.clientHubDatabase),
                          if (result.createdCompanyDatabases.isNotEmpty)
                            _buildReportItem('Company Databases',
                                '${result.createdCompanyDatabases.length} created'),
                          if (result.createdCompanyDatabases.isNotEmpty)
                            ...result.createdCompanyDatabases.map(
                                (db) => _buildReportItem('  • Database', db)),
                        ]),
                      ],
                      _buildReportCard(
                          'Companies Configuration', Icons.domain, [
                        _buildReportItem('Total Companies',
                            '${request.companies.length + (state.testCompany != null ? 1 : 0)}'),
                        ...request.companies.map((company) => Column(
                              children: [
                                const Divider(),
                                _buildReportItem(
                                    'Company Name', company.companyName),
                                _buildReportItem('Address',
                                    '${company.address1}, ${company.city}'),
                                _buildReportItem('Phone', company.phoneNumber),
                                _buildReportItem('Country', company.country),
                              ],
                            )),
                      ]),
                      _buildReportCard(
                          'Administrator Account', Icons.admin_panel_settings, [
                        _buildReportItem('Email', request.adminUser.email),
                        _buildReportItem(
                            'Contact Number', request.adminUser.contactNumber),
                        _buildReportItem('Branch', request.adminUser.branch),
                      ]),
                      _buildReportCard('License Configuration', Icons.key, [
                        _buildReportItem('License Users',
                            '${request.license.numberOfUsers}'),
                        _buildReportItem('End Date',
                            request.license.endDate.toString().split(' ')[0]),
                        _buildReportItem(
                            'Encryption',
                            request.license.usesNewEncryption
                                ? 'Enabled'
                                : 'Disabled'),
                      ]),
                      _buildReportCard('Selected Modules', Icons.extension, [
                        _buildReportItem('Total Modules',
                            '${request.selectedModuleIds.length}'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: request.selectedModuleIds.map((moduleId) {
                            final moduleName =
                                AppConstants.systemModules[moduleId] ??
                                    'Unknown Module';
                            final isMandatory =
                                moduleId == AppConstants.userManagementModuleId;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isMandatory
                                    ? colorScheme.primary
                                        .withAlpha((255 * 0.1).round())
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isMandatory
                                      ? colorScheme.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isMandatory) ...[
                                    Icon(Icons.star,
                                        size: 12, color: colorScheme.primary),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    moduleName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isMandatory
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isMandatory
                                          ? colorScheme.primary
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ]),
                      _buildReportCard('URL Configuration', Icons.link, [
                        _buildReportItem('Configured URLs',
                            '${_getEnabledUrlCount(request.urls)} of 10'),
                        const SizedBox(height: 8),
                        if (request.urls.webURLEnabled)
                          _buildUrlItem('Web Portal', request.urls.webURL),
                        if (request.urls.apiURLEnabled)
                          _buildUrlItem('API Service', request.urls.apiURL),
                        if (request.urls.crmurlEnabled)
                          _buildUrlItem('CRM System', request.urls.crmurl),
                        if (request.urls.procurementURLEnabled)
                          _buildUrlItem(
                              'Procurement', request.urls.procurementURL),
                        if (request.urls.reportsURLEnabled)
                          _buildUrlItem('Reports', request.urls.reportsURL),
                        if (request.urls.leasingURLEnabled)
                          _buildUrlItem('Leasing', request.urls.leasingURL),
                        if (request.urls.tradingURLEnabled)
                          _buildUrlItem('Trading', request.urls.tradingURL),
                        if (request.urls.integrationURLEnabled)
                          _buildUrlItem(
                              'Integration', request.urls.integrationURL),
                        if (request.urls.fnbPosURLEnabled)
                          _buildUrlItem('F&B POS', request.urls.fnbPosURL),
                        if (request.urls.retailPOSUrlEnabled)
                          _buildUrlItem(
                              'Retail POS', request.urls.retailPOSUrl),
                      ]),
                    ]),
                  ],

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Share Report as PDF'),
                          onPressed: (result != null && request != null)
                              ? () => ReportGenerator.generateAndShareReport(
                                  result, request)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_business),
                          label: const Text('Start Another Onboarding'),
                          onPressed: () {
                            context.read<OnboardingCubit>().startNewSession();
                            context.go('/welcome');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build a report section
  Widget _buildReportSection(String title, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...cards.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: card,
            )),
      ],
    );
  }

  // Helper method to build a report card
  Widget _buildReportCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper method to build a report item
  Widget _buildReportItem(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight:
                    valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a URL item
  Widget _buildUrlItem(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              url,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to count enabled URLs
  int _getEnabledUrlCount(CompanyUrls urls) {
    int count = 0;
    if (urls.webURLEnabled) count++;
    if (urls.apiURLEnabled) count++;
    if (urls.crmurlEnabled) count++;
    if (urls.procurementURLEnabled) count++;
    if (urls.reportsURLEnabled) count++;
    if (urls.leasingURLEnabled) count++;
    if (urls.tradingURLEnabled) count++;
    if (urls.integrationURLEnabled) count++;
    if (urls.fnbPosURLEnabled) count++;
    if (urls.retailPOSUrlEnabled) count++;
    return count;
  }
}
