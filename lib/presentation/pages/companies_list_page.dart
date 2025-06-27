import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client_deployment_app/core/di.dart' as di;
import 'package:client_deployment_app/domain/entities/company_entities.dart';
import 'package:client_deployment_app/presentation/cubits/company_management_cubit.dart';
import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

class CompaniesListPage extends StatelessWidget {
  const CompaniesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<CompanyManagementCubit>()..loadCompanies(),
      child: const _CompaniesListView(),
    );
  }
}

class _CompaniesListView extends StatefulWidget {
  const _CompaniesListView();

  @override
  State<_CompaniesListView> createState() => _CompaniesListViewState();
}

class _CompaniesListViewState extends State<_CompaniesListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Companies'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<CompanyManagementCubit, CompanyManagementState>(
        listener: (context, state) {
          if (state.status == CompanyManagementStatus.failure ||
              state.updateStatus == CompanyUpdateStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
            context.read<CompanyManagementCubit>().clearError();
          }

          if (state.updateStatus == CompanyUpdateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Companies updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<CompanyManagementCubit>().resetUpdateStatus();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildSearchAndActions(context, state),
              Expanded(
                child: _buildCompanyList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndActions(
      BuildContext context, CompanyManagementState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search companies...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<CompanyManagementCubit>()
                            .searchCompanies('');
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              context.read<CompanyManagementCubit>().searchCompanies(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: state.isAllSelected,
                tristate: true,
                onChanged: (value) {
                  if (state.isAllSelected) {
                    context.read<CompanyManagementCubit>().clearSelection();
                  } else {
                    context.read<CompanyManagementCubit>().selectAllCompanies();
                  }
                },
              ),
              Text(
                state.hasSelectedCompanies
                    ? '${state.selectedCompanies.length} selected'
                    : 'Select all',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: state.hasSelectedCompanies
                    ? () => _showBulkUpdateDialog(context, state)
                    : null,
                child: const Text('Bulk Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyList(BuildContext context, CompanyManagementState state) {
    if (state.status == CompanyManagementStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CompanyManagementStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load companies',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.errorMessage ?? 'Unknown error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<CompanyManagementCubit>().loadCompanies(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.filteredCompanies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isEmpty
                  ? 'No companies found'
                  : 'No matching companies',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<CompanyManagementCubit>().loadCompanies(),
      child: ListView.builder(
        itemCount: state.filteredCompanies.length,
        itemBuilder: (context, index) {
          final company = state.filteredCompanies[index];
          return _CompanyListItem(
            company: company,
            isSelected: state.selectedCompanies.contains(company.id),
            onSelectionChanged: (selected) {
              context
                  .read<CompanyManagementCubit>()
                  .toggleCompanySelection(company.id);
            },
            onTap: () => context.push('/company-details/${company.id}'),
          );
        },
      ),
    );
  }

  void _showBulkUpdateDialog(
      BuildContext context, CompanyManagementState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CompanyManagementCubit>(),
        child: _BulkUpdateDialog(
            selectedCompanyIds: state.selectedCompanies.toList()),
      ),
    );
  }
}

class _CompanyListItem extends StatelessWidget {
  final ExistingCompany company;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onTap;

  const _CompanyListItem({
    required this.company,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) => onSelectionChanged(value ?? false),
        ),
        title: Text(
          company.companyName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company No: ${company.companyNo}'),
            if (company.endJoinDate != null)
              Text('End Date: ${_formatDate(company.endJoinDate!)}'),
            Text('Base DB: ${company.baseDB} | Data DB: ${company.dataDB}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: company.status.toLowerCase() == 'active'
                    ? Colors.green
                    : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                company.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('${company.numberOfUsers} users'),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _BulkUpdateDialog extends StatefulWidget {
  final List<int> selectedCompanyIds;

  const _BulkUpdateDialog({required this.selectedCompanyIds});

  @override
  State<_BulkUpdateDialog> createState() => _BulkUpdateDialogState();
}

class _BulkUpdateDialogState extends State<_BulkUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberOfUsersController = TextEditingController();
  String? _selectedStatus;
  DateTime? _selectedEndDate;
  bool? _usesNewEncryption;

  @override
  void dispose() {
    _numberOfUsersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyManagementCubit, CompanyManagementState>(
      listener: (context, state) {
        if (state.updateStatus == CompanyUpdateStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        title:
            Text('Bulk Update ${widget.selectedCompanyIds.length} Companies'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: _numberOfUsersController,
                  labelText: 'Number of Users (optional)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Please enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(
                        value: 'Inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedEndDate ??
                          DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _selectedEndDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'License End Date (optional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedEndDate != null
                          ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                          : 'Select end date',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<bool>(
                  value: _usesNewEncryption,
                  decoration: const InputDecoration(
                    labelText: 'Uses New Encryption (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Yes')),
                    DropdownMenuItem(value: false, child: Text('No')),
                  ],
                  onChanged: (value) =>
                      setState(() => _usesNewEncryption = value),
                ),
              ],
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
              return ElevatedButton(
                onPressed: state.updateStatus == CompanyUpdateStatus.loading
                    ? null
                    : _submitBulkUpdate,
                child: state.updateStatus == CompanyUpdateStatus.loading
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

  void _submitBulkUpdate() {
    if (_formKey.currentState!.validate()) {
      final request = BulkUpdateRequest(
        companyIds: widget.selectedCompanyIds,
        numberOfUsers: _numberOfUsersController.text.isNotEmpty
            ? int.parse(_numberOfUsersController.text)
            : null,
        status: _selectedStatus,
        endJoinDate: _selectedEndDate,
        usesNewEncryption: _usesNewEncryption,
      );

      context.read<CompanyManagementCubit>().bulkUpdate(request);
    }
  }
}
