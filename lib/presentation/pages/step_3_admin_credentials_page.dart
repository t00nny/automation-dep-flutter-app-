import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';
import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

class AdminCredentialsPage extends StatefulWidget {
  const AdminCredentialsPage({super.key});

  @override
  State<AdminCredentialsPage> createState() => _AdminCredentialsPageState();
}

class _AdminCredentialsPageState extends State<AdminCredentialsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final adminUser =
        context.select((OnboardingCubit cubit) => cubit.state.adminUser);

    return Form(
      key: _formKey,
      child: WizardScaffold(
        title: 'Step 3: Admin Credentials',
        currentStep: 3,
        totalSteps: 7,
        isNextEnabled: adminUser.email.isNotEmpty &&
            adminUser.password.isNotEmpty &&
            adminUser.contactNumber.isNotEmpty,
        onNext: () {
          if (_formKey.currentState!.validate()) {
            context.push('/step4');
          }
        },
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up the primary administrator account for this client.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            CustomTextFormField(
              labelText: 'Admin Email',
              prefixIcon: Icons.email_outlined,
              initialValue: adminUser.email,
              onChanged: (value) =>
                  context.read<OnboardingCubit>().updateAdminInfo(email: value),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                // FIXED: Added curly braces
                if (value == null || value.isEmpty) {
                  return 'Email is required.';
                }
                // FIXED: Added curly braces
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              labelText: 'Admin Contact Number',
              prefixIcon: Icons.phone_outlined,
              initialValue: adminUser.contactNumber,
              onChanged: (value) => context
                  .read<OnboardingCubit>()
                  .updateAdminInfo(contactNumber: value),
              keyboardType: TextInputType.phone,
              validator: (val) {
                // FIXED: Added curly braces
                if (val!.isEmpty) {
                  return 'Contact number is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              labelText: 'Password',
              prefixIcon: Icons.password_outlined,
              initialValue: adminUser.password,
              obscureText: true,
              onChanged: (value) => context
                  .read<OnboardingCubit>()
                  .updateAdminInfo(password: value),
              validator: (value) {
                // FIXED: Added curly braces
                if (value == null || value.isEmpty) {
                  return 'Password is required.';
                }
                // FIXED: Added curly braces
                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
