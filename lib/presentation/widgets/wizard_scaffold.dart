import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WizardScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onNext;
  final String nextButtonText;
  final bool isNextEnabled;
  final int currentStep; // ADDED
  final int totalSteps; // ADDED

  const WizardScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onNext,
    this.nextButtonText = 'Next',
    this.isNextEnabled = true,
    this.currentStep = 0, // ADDED
    this.totalSteps = 0, // ADDED
  });

  // ADDED: Helper widget for the step indicator
  Widget _buildStepIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index + 1 == currentStep ? 24 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: index + 1 == currentStep
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: context.canPop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (totalSteps > 0) _buildStepIndicator(context), // ADDED
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SingleChildScrollView(
                  child: body,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (context.canPop())
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: isNextEnabled ? onNext : null,
                    label: Text(nextButtonText),
                    icon: Icon(nextButtonText == 'Review'
                        ? Icons.check
                        : Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
