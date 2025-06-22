import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client_deployment_app/core/constants.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';

class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return WizardScaffold(
          title: 'Step 6: Select Modules',
          currentStep: 6,
          totalSteps: 7,
          onNext: () => context.push('/review'),
          nextButtonText: 'Review',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the modules to be enabled for this client. "User Management" is required and cannot be deselected.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: AppConstants.systemModules.entries.map((entry) {
                  final moduleId = entry.key;
                  final moduleName = entry.value;
                  final isSelected = state.selectedModuleIds.contains(moduleId);
                  final isMandatory =
                      moduleId == AppConstants.userManagementModuleId;

                  return Card(
                    elevation: isSelected ? 2 : 1,
                    // FIXED: Replaced deprecated withOpacity
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha((255 * 0.1).round())
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.primary)
                          : BorderSide(color: Colors.grey.shade200),
                    ),
                    child: CheckboxListTile(
                      title: Text(moduleName,
                          style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      value: isSelected,
                      onChanged: isMandatory
                          ? null
                          : (bool? value) {
                              context
                                  .read<OnboardingCubit>()
                                  .toggleModule(moduleId);
                            },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
