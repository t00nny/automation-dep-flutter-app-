import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';

class CompanyInfoPage extends StatelessWidget {
  const CompanyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return WizardScaffold(
          title: 'Step 2: Company Info',
          isNextEnabled: state.companies.isNotEmpty,
          onNext: () => context.push('/step3'),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Add one or more companies. A Test company will be auto-generated for the first one.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton.small(
                    onPressed: () => context.push('/company-form'),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.companies.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                        'No companies added yet. Tap the + button to start.'),
                  ),
                )
              else ...[
                // Section for User-Added Companies
                Text('Companies',
                    style: Theme.of(context).textTheme.titleLarge),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.companies.length,
                  itemBuilder: (context, index) {
                    final company = state.companies[index];
                    return CompanyInfoTile(
                      company: company,
                      onTap: () => context.push('/company-form', extra: index),
                      onDelete: () =>
                          context.read<OnboardingCubit>().deleteCompany(index),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Section for the Test Company
                if (state.testCompany != null) ...[
                  Text('Test Environment',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  CompanyInfoTile(
                    company: state.testCompany!,
                    onTap: () {
                      // Optionally, show a dialog that this cannot be edited.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'The test company cannot be edited directly.'),
                          backgroundColor: Colors.blueGrey,
                        ),
                      );
                    },
                    // Disable delete functionality for the test company tile.
                    onDelete: () {},
                    isTestCompany: true, // Pass a flag to hide delete icon
                  ),
                ]
              ]
            ],
          ),
        );
      },
    );
  }
}

class CompanyInfoTile extends StatelessWidget {
  final CompanyInfo company;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isTestCompany;

  const CompanyInfoTile({
    super.key,
    required this.company,
    required this.onTap,
    required this.onDelete,
    this.isTestCompany = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(company.companyName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(company.city.isNotEmpty && company.country.isNotEmpty
            ? '${company.city}, ${company.country}'
            : 'No location details'),
        trailing: isTestCompany
            ? const Icon(Icons.science_outlined, color: Colors.blueGrey)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueGrey),
                    onPressed: onTap,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: onDelete,
                  ),
                ],
              ),
        onTap: onTap,
      ),
    );
  }
}
