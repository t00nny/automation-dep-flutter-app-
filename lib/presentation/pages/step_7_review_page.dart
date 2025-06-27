import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/core/constants.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.deploymentStatus == DeploymentStatus.success ||
            state.deploymentStatus == DeploymentStatus.failure) {
          context.go('/result');
        }
      },
      builder: (context, state) {
        final isDeploying = state.deploymentStatus == DeploymentStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Review & Deploy'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: isDeploying
                  ? null
                  : () => context
                      .pop(), // UPDATED: Disable back button during deployment
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDeploying
                            ? 'Deploying Configuration'
                            : 'Review Configuration', // UPDATED: Dynamic title
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isDeploying
                            ? 'Please wait while we deploy your client environment...'
                            : 'Please review all settings before deploying the client environment.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress indicator
                      Row(
                        children: [
                          Icon(
                            isDeploying ? Icons.sync : Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isDeploying
                                ? 'Deployment in Progress...'
                                : 'Step 7 of 7 - Final Review',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24), // Client Information
                _buildSectionCard(
                  context,
                  'Client Information',
                  Icons.business,
                  '/step1',
                  isDeploying, // UPDATED: Pass deployment status
                  [
                    _buildInfoRow('Client Name', state.clientName),
                    _buildInfoRow('Database Prefix', state.databaseTypePrefix),
                    if (state.clientLogoFile != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Client Logo:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                              image: DecorationImage(
                                image: FileImage(state.clientLogoFile!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Logo will be uploaded during deployment',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                // Company Information
                _buildSectionCard(
                  context,
                  'Company Information',
                  Icons.domain,
                  '/step2',
                  isDeploying, // UPDATED: Pass deployment status
                  [
                    _buildInfoRow(
                      'Companies',
                      '${state.companies.length + (state.testCompany != null ? 1 : 0)} configured',
                    ),
                    const SizedBox(height: 12),
                    ...state.companies.asMap().entries.map((entry) {
                      final company = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.companyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (company.city.isNotEmpty &&
                                company.country.isNotEmpty)
                              Text(
                                '${company.city}, ${company.country}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            if (company.logoText.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.text_fields,
                                      size: 12, color: Colors.blue.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Logo Text: ${company.logoText}',
                                      style: TextStyle(
                                        color: Colors.blue.shade600,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    if (state.testCompany != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.testCompany!.companyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Auto-generated test company',
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (state.testCompany!.logoText.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.text_fields,
                                      size: 12, color: Colors.green.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Logo Text: ${state.testCompany!.logoText}',
                                      style: TextStyle(
                                        color: Colors.green.shade600,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),

                // Administrator Information
                _buildSectionCard(
                  context,
                  'Administrator Information',
                  Icons.admin_panel_settings,
                  '/step3',
                  isDeploying, // UPDATED: Pass deployment status
                  [
                    _buildInfoRow('Email', state.adminUser.email),
                    _buildInfoRow(
                        'Contact Number', state.adminUser.contactNumber),
                    _buildInfoRow('Branch', state.adminUser.branch),
                    _buildInfoRow('Password', '••••••••'),
                  ],
                ),

                // License Information
                _buildSectionCard(
                  context,
                  'License Information',
                  Icons.card_membership,
                  '/step4',
                  isDeploying, // UPDATED: Pass deployment status
                  [
                    _buildInfoRow('Number of Users',
                        state.license.numberOfUsers.toString()),
                    _buildInfoRow('License End Date',
                        DateFormat.yMMMd().format(state.license.endDate)),
                    _buildInfoRow(
                        'New Encryption',
                        state.license.usesNewEncryption
                            ? 'Enabled'
                            : 'Disabled'),
                  ],
                ),

                // URL Configuration
                _buildSectionCard(
                  context,
                  'URL Configuration',
                  Icons.link,
                  '/step5',
                  isDeploying, // UPDATED: Pass deployment status
                  [
                    _buildUrlConfigurationSection(state.urls),
                  ],
                ),

                // Module Selection
                _buildSectionCard(
                  context,
                  'Selected Modules',
                  Icons.extension,
                  '/step6',
                  isDeploying, // UPDATED: Pass deployment status
                  [
                    _buildInfoRow('Modules',
                        '${state.selectedModuleIds.length} selected'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.selectedModuleIds.map((moduleId) {
                        final moduleName =
                            AppConstants.systemModules[moduleId] ??
                                'Unknown Module';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            moduleName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Deploy Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDeploying
                          ? [Colors.grey.shade400, Colors.grey.shade500]
                          : [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isDeploying
                        ? null
                        : () {
                            context.read<OnboardingCubit>().submitDeployment();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isDeploying
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Deploying Client Environment...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rocket_launch, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Deploy Client Environment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // UPDATED: Added isDeploying parameter to disable edit buttons during deployment
  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    String editRoute,
    bool isDeploying, // UPDATED: New parameter
    List<Widget> children,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            // Header with edit button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDeploying
                    ? Colors.grey.shade100
                    : Colors.grey
                        .shade50, // UPDATED: Different color when deploying
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isDeploying
                        ? Colors.grey.shade500
                        : Theme.of(context)
                            .primaryColor, // UPDATED: Grey when deploying
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDeploying
                            ? Colors.grey.shade600
                            : Theme.of(context)
                                .primaryColor, // UPDATED: Grey when deploying
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: isDeploying
                        ? null
                        : () => context.push(
                            editRoute), // UPDATED: Disabled when deploying
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDeploying
                          ? Colors.grey.shade400
                          : Theme.of(context)
                              .primaryColor, // UPDATED: Grey when disabled
                      side: BorderSide(
                        color: isDeploying
                            ? Colors.grey.shade300
                            : Theme.of(context)
                                .primaryColor, // UPDATED: Grey border when disabled
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlConfigurationSection(urls) {
    final enabledCount = _getEnabledUrlCount(urls);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$enabledCount of 10 URLs configured',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // URL Grid
        Column(
          children: [
            _buildUrlRow('Web Portal', urls.webURLEnabled, urls.webURL),
            _buildUrlRow('API Service', urls.apiURLEnabled, urls.apiURL),
            _buildUrlRow('CRM System', urls.crmurlEnabled, urls.crmurl),
            _buildUrlRow(
                'Procurement', urls.procurementURLEnabled, urls.procurementURL),
            _buildUrlRow('Reports', urls.reportsURLEnabled, urls.reportsURL),
            _buildUrlRow('Leasing', urls.leasingURLEnabled, urls.leasingURL),
            _buildUrlRow('Trading', urls.tradingURLEnabled, urls.tradingURL),
            _buildUrlRow(
                'Integration', urls.integrationURLEnabled, urls.integrationURL),
            _buildUrlRow('F&B POS', urls.fnbPosURLEnabled, urls.fnbPosURL),
            _buildUrlRow(
                'Retail POS', urls.retailPOSUrlEnabled, urls.retailPOSUrl),
          ],
        ),
      ],
    );
  }

  Widget _buildUrlRow(String serviceName, bool isEnabled, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              serviceName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.green.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isEnabled ? 'Enabled' : 'Disabled',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isEnabled ? Colors.green.shade700 : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEnabled ? url : 'Not configured',
              style: TextStyle(
                fontSize: 11,
                color: isEnabled ? Colors.black87 : Colors.grey.shade500,
                fontStyle: isEnabled ? FontStyle.normal : FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int _getEnabledUrlCount(urls) {
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
