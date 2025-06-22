import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/presentation/widgets/wizard_scaffold.dart';
import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

class UrlsPage extends StatelessWidget {
  const UrlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final urls = context.read<OnboardingCubit>().state.urls;
    return WizardScaffold(
      title: 'Step 5: System URLs',
      currentStep: 5, // ADDED
      totalSteps: 7, // ADDED
      onNext: () => context.push('/step6'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provide the URLs for the client\'s different system endpoints.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          CustomTextFormField(
            labelText: 'CRM URL',
            prefixIcon: Icons.link, // ADDED
            initialValue: urls.crmurl,
            onChanged: (value) =>
                context.read<OnboardingCubit>().updateUrls(crmUrl: value),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            labelText: 'Trading URL',
            prefixIcon: Icons.link, // ADDED
            initialValue: urls.tradingURL,
            onChanged: (value) =>
                context.read<OnboardingCubit>().updateUrls(tradingUrl: value),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            labelText: 'Integration URL',
            prefixIcon: Icons.link, // ADDED
            initialValue: urls.integrationURL,
            onChanged: (value) => context
                .read<OnboardingCubit>()
                .updateUrls(integrationUrl: value),
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}
