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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: WizardScaffold(
            title: 'Step 1: Client Details',
            isNextEnabled: state.clientName.isNotEmpty,
            onNext: () {
              if (_formKey.currentState!.validate()) {
                context.push('/step2');
              }
            },
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
                  initialValue: state.clientName,
                  onChanged: (value) {
                    context.read<OnboardingCubit>().updateClientName(value);
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
                // NEW: Dropdown for selecting the Database Prefix.
                DropdownButtonFormField<String>(
                  value: state.databaseTypePrefix,
                  decoration: const InputDecoration(
                    labelText: 'Database Prefix',
                    border: OutlineInputBorder(),
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
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
