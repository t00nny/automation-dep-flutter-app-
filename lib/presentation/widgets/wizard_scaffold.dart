import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WizardScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onNext;
  final String nextButtonText;
  final bool isNextEnabled;

  const WizardScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onNext,
    this.nextButtonText = 'Next',
    this.isNextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: context.canPop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: body,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (context.canPop())
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: isNextEnabled ? onNext : null,
                    child: Text(nextButtonText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}