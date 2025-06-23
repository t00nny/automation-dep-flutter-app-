import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';

class UrlsPage extends StatefulWidget {
  const UrlsPage({super.key});

  @override
  State<UrlsPage> createState() => _UrlsPageState();
}

class _UrlsPageState extends State<UrlsPage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for all URL fields
  late TextEditingController _webURLController;
  late TextEditingController _apiURLController;
  late TextEditingController _crmurlController;
  late TextEditingController _procurementURLController;
  late TextEditingController _reportsURLController;
  late TextEditingController _leasingURLController;
  late TextEditingController _tradingURLController;
  late TextEditingController _integrationURLController;
  late TextEditingController _fnbPosURLController;
  late TextEditingController _retailPOSUrlController;

  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingCubit>().state;

    // Initialize controllers with current values
    _webURLController = TextEditingController(text: state.urls.webURL);
    _apiURLController = TextEditingController(text: state.urls.apiURL);
    _crmurlController = TextEditingController(text: state.urls.crmurl);
    _procurementURLController =
        TextEditingController(text: state.urls.procurementURL);
    _reportsURLController = TextEditingController(text: state.urls.reportsURL);
    _leasingURLController = TextEditingController(text: state.urls.leasingURL);
    _tradingURLController = TextEditingController(text: state.urls.tradingURL);
    _integrationURLController =
        TextEditingController(text: state.urls.integrationURL);
    _fnbPosURLController = TextEditingController(text: state.urls.fnbPosURL);
    _retailPOSUrlController =
        TextEditingController(text: state.urls.retailPOSUrl);
  }

  @override
  void dispose() {
    _webURLController.dispose();
    _apiURLController.dispose();
    _crmurlController.dispose();
    _procurementURLController.dispose();
    _reportsURLController.dispose();
    _leasingURLController.dispose();
    _tradingURLController.dispose();
    _integrationURLController.dispose();
    _fnbPosURLController.dispose();
    _retailPOSUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return WizardScaffold(
          title: 'URL Configuration',
          currentStep: 5,
          totalSteps: 7,
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure System URLs',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enable or disable specific URLs and customize their values for this client deployment.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),

                  // URL Configuration Widgets
                  _buildUrlConfigWidget(
                    label: 'WebURL',
                    controller: _webURLController,
                    isEnabled: state.urls.webURLEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(webURLEnabled: value),
                    onUrlChanged: (value) => _updateUrl(webURL: value),
                  ),

                  _buildUrlConfigWidget(
                    label: 'APIURL',
                    controller: _apiURLController,
                    isEnabled: state.urls.apiURLEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(apiURLEnabled: value),
                    onUrlChanged: (value) => _updateUrl(apiURL: value),
                  ),

                  _buildUrlConfigWidget(
                    label: 'CRMURL',
                    controller: _crmurlController,
                    isEnabled: state.urls.crmurlEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(crmurlEnabled: value),
                    onUrlChanged: (value) => _updateUrl(crmurl: value),
                  ),

                  _buildUrlConfigWidget(
                    label: 'ProcurementURL',
                    controller: _procurementURLController,
                    isEnabled: state.urls.procurementURLEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(procurementURLEnabled: value),
                    onUrlChanged: (value) => _updateUrl(procurementURL: value),
                  ),

                  _buildUrlConfigWidget(
                    label: 'ReportsURL',
                    controller: _reportsURLController,
                    isEnabled: state.urls.reportsURLEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(reportsURLEnabled: value),
                    onUrlChanged: (value) => _updateUrl(reportsURL: value),
                  ),

                  _buildUrlConfigWidget(
                    label: 'LeasingURL',
                    controller: _leasingURLController,
                    isEnabled: state.urls.leasingURLEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(leasingURLEnabled: value),
                    onUrlChanged: (value) => _updateUrl(leasingURL: value),
                  ),

                  _buildUrlConfigWidget(
                    label: 'TradingURL',
                    controller: _tradingURLController,
                    isEnabled: state.urls.tradingURLEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(tradingURLEnabled: value),
                    onUrlChanged: (value) => _updateUrl(tradingURL: value),
                  ),

                  _buildUrlConfigWidget(
                    label: 'IntegrationURL',
                    controller: _integrationURLController,
                    isEnabled: state.urls.integrationURLEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(integrationURLEnabled: value),
                    onUrlChanged: (value) => _updateUrl(integrationURL: value),
                  ),

                  _buildUrlConfigWidget(
                    label: 'FnbPosURL',
                    controller: _fnbPosURLController,
                    isEnabled: state.urls.fnbPosURLEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(fnbPosURLEnabled: value),
                    onUrlChanged: (value) => _updateUrl(fnbPosURL: value),
                  ),

                  _buildUrlConfigWidget(
                    label: 'RetailPOSUrl',
                    controller: _retailPOSUrlController,
                    isEnabled: state.urls.retailPOSUrlEnabled,
                    onEnabledChanged: (value) =>
                        _updateUrl(retailPOSUrlEnabled: value),
                    onUrlChanged: (value) => _updateUrl(retailPOSUrl: value),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          onNext: () {
            if (_formKey.currentState?.validate() ?? false) {
              context.push('/step6');
            }
          },
        );
      },
    );
  }

  Widget _buildUrlConfigWidget({
    required String label,
    required TextEditingController controller,
    required bool isEnabled,
    required ValueChanged<bool?> onEnabledChanged,
    required ValueChanged<String> onUrlChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isEnabled,
                  onChanged: onEnabledChanged,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              enabled: isEnabled,
              onChanged: onUrlChanged,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: isEnabled ? 'Enter URL' : 'Disabled',
                filled: true,
                fillColor: isEnabled ? null : Colors.grey[100],
              ),
              // FIXED: Simplified URL validation - no validation for disabled fields
              validator: !isEnabled
                  ? null
                  : (value) {
                      // Only validate if the field is enabled
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a URL';
                      }

                      // FIXED: Much simpler URL validation
                      final trimmedValue = value.trim();
                      if (!trimmedValue.startsWith('http://') &&
                          !trimmedValue.startsWith('https://')) {
                        return 'URL must start with http:// or https://';
                      }

                      // Basic validation - just check if it's a valid URI
                      try {
                        final uri = Uri.parse(trimmedValue);
                        if (uri.host.isEmpty) {
                          return 'Please enter a valid URL';
                        }
                      } catch (e) {
                        return 'Please enter a valid URL';
                      }

                      return null;
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _updateUrl({
    String? webURL,
    bool? webURLEnabled,
    String? apiURL,
    bool? apiURLEnabled,
    String? crmurl,
    bool? crmurlEnabled,
    String? procurementURL,
    bool? procurementURLEnabled,
    String? reportsURL,
    bool? reportsURLEnabled,
    String? leasingURL,
    bool? leasingURLEnabled,
    String? tradingURL,
    bool? tradingURLEnabled,
    String? integrationURL,
    bool? integrationURLEnabled,
    String? fnbPosURL,
    bool? fnbPosURLEnabled,
    String? retailPOSUrl,
    bool? retailPOSUrlEnabled,
  }) {
    context.read<OnboardingCubit>().updateUrls(
          webURL: webURL,
          webURLEnabled: webURLEnabled,
          apiURL: apiURL,
          apiURLEnabled: apiURLEnabled,
          crmurl: crmurl,
          crmurlEnabled: crmurlEnabled,
          procurementURL: procurementURL,
          procurementURLEnabled: procurementURLEnabled,
          reportsURL: reportsURL,
          reportsURLEnabled: reportsURLEnabled,
          leasingURL: leasingURL,
          leasingURLEnabled: leasingURLEnabled,
          tradingURL: tradingURL,
          tradingURLEnabled: tradingURLEnabled,
          integrationURL: integrationURL,
          integrationURLEnabled: integrationURLEnabled,
          fnbPosURL: fnbPosURL,
          fnbPosURLEnabled: fnbPosURLEnabled,
          retailPOSUrl: retailPOSUrl,
          retailPOSUrlEnabled: retailPOSUrlEnabled,
        );
  }
}
