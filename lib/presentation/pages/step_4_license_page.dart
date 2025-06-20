import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';
import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  Future<void> _selectDate(BuildContext context) async {
    final cubit = context.read<OnboardingCubit>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.license.endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != cubit.state.license.endDate) {
      cubit.updateLicenseInfo(endDate: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return WizardScaffold(
          title: 'Step 4: License',
          onNext: () => context.push('/step5'),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure the software license and user limits for this client.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              CustomTextFormField(
                labelText: 'Number of Users',
                initialValue: state.license.numberOfUsers.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final users = int.tryParse(value);
                  if (users != null) {
                    context.read<OnboardingCubit>().updateLicenseInfo(numberOfUsers: users);
                  }
                },
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('License End Date'),
                subtitle: Text(DateFormat.yMMMd().format(state.license.endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Use New Encryption'),
                value: state.license.usesNewEncryption,
                onChanged: (bool value) {
                  context.read<OnboardingCubit>().updateLicenseInfo(usesNewEncryption: value);
                },
                secondary: const Icon(Icons.enhanced_encryption),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}