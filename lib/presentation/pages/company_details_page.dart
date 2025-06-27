import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_deployment_app/core/di.dart' as di;
import 'package:client_deployment_app/domain/entities/company_entities.dart';
import 'package:client_deployment_app/presentation/cubits/company_management_cubit.dart';
import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

class CompanyDetailsPage extends StatelessWidget {
  final int companyId;

  const CompanyDetailsPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<CompanyManagementCubit>()..loadCompanyDetails(companyId),
      child: _CompanyDetailsView(companyId: companyId),
    );
  }
}

class _CompanyDetailsView extends StatelessWidget {
  final int companyId;

  const _CompanyDetailsView({required this.companyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Company Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF005A9C), // Using the app's primary blue color
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          BlocBuilder<CompanyManagementCubit, CompanyManagementState>(
            builder: (context, state) {
              if (state.selectedCompanyDetails != null) {
                return IconButton(
                  icon: const Icon(Icons.push_pin, color: Colors.white),
                  tooltip: 'Edit Company',
                  onPressed: () =>
                      _showEditDialog(context, state.selectedCompanyDetails!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CompanyManagementCubit, CompanyManagementState>(
        listener: (context, state) {
          if (state.detailsStatus == CompanyDetailsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    state.errorMessage ?? 'Failed to load company details'),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state.updateStatus == CompanyUpdateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Company updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<CompanyManagementCubit>().resetUpdateStatus();
            // Reload the company details
            context
                .read<CompanyManagementCubit>()
                .loadCompanyDetails(companyId);
          }
        },
        builder: (context, state) {
          if (state.detailsStatus == CompanyDetailsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.detailsStatus == CompanyDetailsStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load company details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(state.errorMessage ?? 'Unknown error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<CompanyManagementCubit>()
                        .loadCompanyDetails(companyId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final company = state.selectedCompanyDetails;
          if (company == null) {
            return const Center(
              child: Text('No company details available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context, company),
                const SizedBox(height: 16),
                // Use a responsive layout instead of fixed two columns
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideScreen = constraints.maxWidth > 800;
                    
                    if (isWideScreen) {
                      // Wide screen: use two columns
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildBasicInfoCard(context, company),
                                    const SizedBox(height: 16),
                                    _buildContactInfoCard(context, company),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildLicenseInfoCard(context, company),
                                    const SizedBox(height: 16),
                                    _buildDatabaseInfoCard(context, company),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildUrlsCard(context, company),
                        ],
                      );
                    } else {
                      // Narrow screen: use single column
                      return Column(
                        children: [
                          _buildBasicInfoCard(context, company),
                          const SizedBox(height: 16),
                          _buildContactInfoCard(context, company),
                          const SizedBox(height: 16),
                          _buildLicenseInfoCard(context, company),
                          const SizedBox(height: 16),
                          _buildDatabaseInfoCard(context, company),
                          const SizedBox(height: 16),
                          _buildUrlsCard(context, company),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ExistingCompany company) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.companyName,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Company No: ${company.companyNo}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: company.status.toLowerCase() == 'active'
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    company.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildQuickInfo(Icons.people, '${company.numberOfUsers} Users'),
                _buildQuickInfo(
                    Icons.security,
                    company.usesNewEncryption
                        ? 'New Encryption'
                        : 'Legacy Encryption'),
                if (company.endJoinDate != null)
                  _buildQuickInfo(Icons.schedule,
                      'Expires: ${_formatDate(company.endJoinDate!)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context, ExistingCompany company) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Company Name', company.companyName),
            _buildDetailRow('Email', company.email),
            _buildDetailRow('Contact Number', company.contactNo),
            _buildDetailRow('Address', company.address),
            _buildDetailRow('City', company.city),
            _buildDetailRow('Country', company.country),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context, ExistingCompany company) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.contact_phone, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Email', company.email),
            _buildDetailRow('Contact Number', company.contactNo),
            _buildDetailRow('Country', company.country),
            _buildDetailRow('City', company.city),
            _buildDetailRow('Address', company.address),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInfoCard(BuildContext context, ExistingCompany company) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.card_membership, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'License Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Number of Users', '${company.numberOfUsers}'),
            _buildDetailRow('Uses New Encryption',
                company.usesNewEncryption ? 'Yes' : 'No'),
            if (company.startJoinDate != null)
              _buildDetailRow(
                  'Start Date', _formatDate(company.startJoinDate!)),
            if (company.endJoinDate != null)
              _buildDetailRow('End Date', _formatDate(company.endJoinDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseInfoCard(BuildContext context, ExistingCompany company) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Database Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Base Database', company.baseDB),
            _buildDetailRow('Data Database', company.dataDB),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlsCard(BuildContext context, ExistingCompany company) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Application URLs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (company.webURL.isNotEmpty)
              _buildDetailRow('Web URL', company.webURL),
            if (company.apiurl.isNotEmpty)
              _buildDetailRow('API URL', company.apiurl),
            if (company.crmurl.isNotEmpty)
              _buildDetailRow('CRM URL', company.crmurl),
            if (company.procurementURL.isNotEmpty)
              _buildDetailRow('Procurement URL', company.procurementURL),
            if (company.reportsURL.isNotEmpty)
              _buildDetailRow('Reports URL', company.reportsURL),
            if (company.leasingURL.isNotEmpty)
              _buildDetailRow('Leasing URL', company.leasingURL),
            if (company.tradingURL.isNotEmpty)
              _buildDetailRow('Trading URL', company.tradingURL),
            if (company.integrationURL.isNotEmpty)
              _buildDetailRow('Integration URL', company.integrationURL),
            if (company.fnbPosURL.isNotEmpty)
              _buildDetailRow('F&B POS URL', company.fnbPosURL),
            if (company.retailPOSUrl.isNotEmpty)
              _buildDetailRow('Retail POS URL', company.retailPOSUrl),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey.shade600 : Colors.black87,
                fontSize: 14,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditDialog(BuildContext context, ExistingCompany company) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CompanyManagementCubit>(),
        child: _EditCompanyDialog(company: company),
      ),
    );
  }
}

class _EditCompanyDialog extends StatefulWidget {
  final ExistingCompany company;

  const _EditCompanyDialog({required this.company});

  @override
  State<_EditCompanyDialog> createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<_EditCompanyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _contactNoController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _webURLController;
  late final TextEditingController _apiurlController;
  late final TextEditingController _crmurlController;
  late final TextEditingController _procurementURLController;
  late final TextEditingController _reportsURLController;
  late final TextEditingController _leasingURLController;
  late final TextEditingController _tradingURLController;
  late final TextEditingController _integrationURLController;
  late final TextEditingController _fnbPosURLController;
  late final TextEditingController _retailPOSUrlController;
  late final TextEditingController _numberOfUsersController;

  String? _selectedStatus;
  DateTime? _selectedEndDate;
  bool? _usesNewEncryption;

  // Track if any fields have been changed
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final company = widget.company;

    _companyNameController = TextEditingController(text: company.companyName);
    _emailController = TextEditingController(text: company.email);
    _contactNoController = TextEditingController(text: company.contactNo);
    _countryController = TextEditingController(text: company.country);
    _cityController = TextEditingController(text: company.city);
    _addressController = TextEditingController(text: company.address);
    _webURLController = TextEditingController(text: company.webURL);
    _apiurlController = TextEditingController(text: company.apiurl);
    _crmurlController = TextEditingController(text: company.crmurl);
    _procurementURLController =
        TextEditingController(text: company.procurementURL);
    _reportsURLController = TextEditingController(text: company.reportsURL);
    _leasingURLController = TextEditingController(text: company.leasingURL);
    _tradingURLController = TextEditingController(text: company.tradingURL);
    _integrationURLController =
        TextEditingController(text: company.integrationURL);
    _fnbPosURLController = TextEditingController(text: company.fnbPosURL);
    _retailPOSUrlController = TextEditingController(text: company.retailPOSUrl);
    _numberOfUsersController =
        TextEditingController(text: company.numberOfUsers.toString());

    _selectedStatus = company.status;
    _selectedEndDate = company.endJoinDate;
    _usesNewEncryption = company.usesNewEncryption;

    // Add listeners to detect changes
    _companyNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _contactNoController.addListener(_onFieldChanged);
    _countryController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _webURLController.addListener(_onFieldChanged);
    _apiurlController.addListener(_onFieldChanged);
    _crmurlController.addListener(_onFieldChanged);
    _procurementURLController.addListener(_onFieldChanged);
    _reportsURLController.addListener(_onFieldChanged);
    _leasingURLController.addListener(_onFieldChanged);
    _tradingURLController.addListener(_onFieldChanged);
    _integrationURLController.addListener(_onFieldChanged);
    _fnbPosURLController.addListener(_onFieldChanged);
    _retailPOSUrlController.addListener(_onFieldChanged);
    _numberOfUsersController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final original = widget.company;
    final hasTextChanges = _companyNameController.text != original.companyName ||
        _emailController.text != original.email ||
        _contactNoController.text != original.contactNo ||
        _countryController.text != original.country ||
        _cityController.text != original.city ||
        _addressController.text != original.address ||
        _webURLController.text != original.webURL ||
        _apiurlController.text != original.apiurl ||
        _crmurlController.text != original.crmurl ||
        _procurementURLController.text != original.procurementURL ||
        _reportsURLController.text != original.reportsURL ||
        _leasingURLController.text != original.leasingURL ||
        _tradingURLController.text != original.tradingURL ||
        _integrationURLController.text != original.integrationURL ||
        _fnbPosURLController.text != original.fnbPosURL ||
        _retailPOSUrlController.text != original.retailPOSUrl ||
        (_numberOfUsersController.text.isNotEmpty && 
         int.tryParse(_numberOfUsersController.text) != original.numberOfUsers);

    final hasDropdownChanges = _selectedStatus != original.status ||
        _selectedEndDate != original.endJoinDate ||
        _usesNewEncryption != original.usesNewEncryption;

    setState(() {
      _hasChanges = hasTextChanges || hasDropdownChanges;
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _contactNoController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _webURLController.dispose();
    _apiurlController.dispose();
    _crmurlController.dispose();
    _procurementURLController.dispose();
    _reportsURLController.dispose();
    _leasingURLController.dispose();
    _tradingURLController.dispose();
    _integrationURLController.dispose();
    _fnbPosURLController.dispose();
    _retailPOSUrlController.dispose();
    _numberOfUsersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyManagementCubit, CompanyManagementState>(
      listener: (context, state) {
        if (state.updateStatus == CompanyUpdateStatus.success) {
          Navigator.of(context).pop();
          // Reload the company details to reflect the changes from the database
          context.read<CompanyManagementCubit>().loadCompanyDetails(widget.company.id);
        }
      },
      child: AlertDialog(
        title: Text('Edit ${widget.company.companyName}'),
        content: SizedBox(
          width: 500,
          height: 600,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSection('Basic Information', [
                    CustomTextFormField(
                      controller: _companyNameController,
                      labelText: 'Company Name',
                      prefixIcon: Icons.business,
                      validator: (value) =>
                          value?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _contactNoController,
                      labelText: 'Contact Number',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Location', [
                    CustomTextFormField(
                      controller: _countryController,
                      labelText: 'Country',
                      prefixIcon: Icons.flag,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _cityController,
                      labelText: 'City',
                      prefixIcon: Icons.location_city,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _addressController,
                      labelText: 'Address',
                      prefixIcon: Icons.location_on,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('License Settings', [
                    CustomTextFormField(
                      controller: _numberOfUsersController,
                      labelText: 'Number of Users',
                      prefixIcon: Icons.people,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isNotEmpty == true) {
                          final number = int.tryParse(value!);
                          if (number == null || number <= 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.power_settings_new),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Active', child: Text('Active')),
                        DropdownMenuItem(
                            value: 'Inactive', child: Text('Inactive')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStatus = value);
                        _onFieldChanged();
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedEndDate ??
                              DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          setState(() => _selectedEndDate = date);
                          _onFieldChanged();
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'License End Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedEndDate != null
                              ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                              : 'Select date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<bool>(
                      value: _usesNewEncryption,
                      decoration: const InputDecoration(
                        labelText: 'Uses New Encryption',
                        prefixIcon: Icon(Icons.security),
                      ),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Yes')),
                        DropdownMenuItem(value: false, child: Text('No')),
                      ],
                      onChanged: (value) {
                        setState(() => _usesNewEncryption = value);
                        _onFieldChanged();
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Application URLs', [
                    CustomTextFormField(
                      controller: _webURLController,
                      labelText: 'Web URL',
                      prefixIcon: Icons.web,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _apiurlController,
                      labelText: 'API URL',
                      prefixIcon: Icons.api,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _crmurlController,
                      labelText: 'CRM URL',
                      prefixIcon: Icons.support_agent,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _procurementURLController,
                      labelText: 'Procurement URL',
                      prefixIcon: Icons.shopping_cart,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _reportsURLController,
                      labelText: 'Reports URL',
                      prefixIcon: Icons.analytics,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _leasingURLController,
                      labelText: 'Leasing URL',
                      prefixIcon: Icons.apartment,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _tradingURLController,
                      labelText: 'Trading URL',
                      prefixIcon: Icons.trending_up,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _integrationURLController,
                      labelText: 'Integration URL',
                      prefixIcon: Icons.integration_instructions,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _fnbPosURLController,
                      labelText: 'F&B POS URL',
                      prefixIcon: Icons.restaurant,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: _retailPOSUrlController,
                      labelText: 'Retail POS URL',
                      prefixIcon: Icons.store,
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<CompanyManagementCubit, CompanyManagementState>(
            builder: (context, state) {
              final isLoading = state.updateStatus == CompanyUpdateStatus.loading;
              final canUpdate = _hasChanges && !isLoading;
              
              return ElevatedButton(
                onPressed: canUpdate ? _submitUpdate : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canUpdate ? const Color(0xFF005A9C) : null,
                  foregroundColor: canUpdate ? Colors.white : null,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  void _submitUpdate() {
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please make at least one change before updating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Only include fields that have changed
      final original = widget.company;
      final Map<String, dynamic> updates = {};

      if (_companyNameController.text != original.companyName) {
        updates['companyName'] = _companyNameController.text;
      }
      if (_emailController.text != original.email) {
        updates['email'] = _emailController.text;
      }
      if (_contactNoController.text != original.contactNo) {
        updates['contactNo'] = _contactNoController.text;
      }
      if (_countryController.text != original.country) {
        updates['country'] = _countryController.text;
      }
      if (_cityController.text != original.city) {
        updates['city'] = _cityController.text;
      }
      if (_addressController.text != original.address) {
        updates['address'] = _addressController.text;
      }
      if (_webURLController.text != original.webURL) {
        updates['webURL'] = _webURLController.text;
      }
      if (_apiurlController.text != original.apiurl) {
        updates['apiurl'] = _apiurlController.text;
      }
      if (_crmurlController.text != original.crmurl) {
        updates['crmurl'] = _crmurlController.text;
      }
      if (_procurementURLController.text != original.procurementURL) {
        updates['procurementURL'] = _procurementURLController.text;
      }
      if (_reportsURLController.text != original.reportsURL) {
        updates['reportsURL'] = _reportsURLController.text;
      }
      if (_leasingURLController.text != original.leasingURL) {
        updates['leasingURL'] = _leasingURLController.text;
      }
      if (_tradingURLController.text != original.tradingURL) {
        updates['tradingURL'] = _tradingURLController.text;
      }
      if (_integrationURLController.text != original.integrationURL) {
        updates['integrationURL'] = _integrationURLController.text;
      }
      if (_fnbPosURLController.text != original.fnbPosURL) {
        updates['fnbPosURL'] = _fnbPosURLController.text;
      }
      if (_retailPOSUrlController.text != original.retailPOSUrl) {
        updates['retailPOSUrl'] = _retailPOSUrlController.text;
      }
      if (_numberOfUsersController.text.isNotEmpty) {
        final newUsers = int.parse(_numberOfUsersController.text);
        if (newUsers != original.numberOfUsers) {
          updates['numberOfUsers'] = newUsers;
        }
      }
      if (_selectedStatus != original.status) {
        updates['status'] = _selectedStatus;
      }
      if (_selectedEndDate != original.endJoinDate) {
        updates['endJoinDate'] = _selectedEndDate;
      }
      if (_usesNewEncryption != original.usesNewEncryption) {
        updates['usesNewEncryption'] = _usesNewEncryption;
      }

      final request = CompanyUpdateRequest(
        companyName: updates['companyName'],
        email: updates['email'],
        contactNo: updates['contactNo'],
        country: updates['country'],
        city: updates['city'],
        address: updates['address'],
        webURL: updates['webURL'],
        apiurl: updates['apiurl'],
        crmurl: updates['crmurl'],
        procurementURL: updates['procurementURL'],
        reportsURL: updates['reportsURL'],
        leasingURL: updates['leasingURL'],
        tradingURL: updates['tradingURL'],
        integrationURL: updates['integrationURL'],
        fnbPosURL: updates['fnbPosURL'],
        retailPOSUrl: updates['retailPOSUrl'],
        numberOfUsers: updates['numberOfUsers'],
        status: updates['status'],
        endJoinDate: updates['endJoinDate'],
        usesNewEncryption: updates['usesNewEncryption'],
        modifiedBy: 'Admin', // You might want to get this from user context
      );

      context
          .read<CompanyManagementCubit>()
          .updateSingleCompany(widget.company.id, request);
    }
  }
}
