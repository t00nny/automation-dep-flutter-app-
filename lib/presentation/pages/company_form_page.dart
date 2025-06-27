import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
import 'package:client_deployment_app/presentation/cubits/onboarding_cubit.dart';
import 'package:client_deployment_app/presentation/widgets/custom_text_form_field.dart';

class CompanyFormPage extends StatefulWidget {
  final int? companyIndex;

  const CompanyFormPage({super.key, this.companyIndex});

  @override
  State<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;
  late final TextEditingController _logoTextController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<OnboardingCubit>();
    CompanyInfo company = const CompanyInfo();

    if (widget.companyIndex != null) {
      company = cubit.state.companies[widget.companyIndex!];
    }

    _nameController = TextEditingController(text: company.companyName);
    _address1Controller = TextEditingController(text: company.address1);
    _cityController = TextEditingController(text: company.city);
    _countryController = TextEditingController(text: company.country);
    _phoneController = TextEditingController(text: company.phoneNumber);

    // Initialize logoText with client name if it's empty (new company) or use existing value
    final initialLogoText =
        company.logoText.isEmpty ? cubit.state.clientName : company.logoText;
    _logoTextController = TextEditingController(text: initialLogoText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _logoTextController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<OnboardingCubit>();

      // Use client name as fallback if logoText is empty
      final logoText = _logoTextController.text.trim().isEmpty
          ? cubit.state.clientName
          : _logoTextController.text.trim();

      final newCompanyInfo = CompanyInfo(
        companyName: _nameController.text,
        address1: _address1Controller.text,
        city: _cityController.text,
        country: _countryController.text,
        phoneNumber: _phoneController.text,
        logoText: logoText,
      );

      if (widget.companyIndex != null) {
        cubit.updateCompany(widget.companyIndex!, newCompanyInfo);
      } else {
        cubit.addCompany(newCompanyInfo);
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientName =
        context.select((OnboardingCubit cubit) => cubit.state.clientName);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.companyIndex == null ? 'Add Company' : 'Edit Company'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Company Name',
                prefixIcon: Icons.business_outlined, // ADDED
                validator: (val) => val!.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _address1Controller,
                labelText: 'Address',
                prefixIcon: Icons.location_on_outlined, // ADDED
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _cityController,
                labelText: 'City',
                prefixIcon: Icons.location_city_outlined, // ADDED
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _countryController,
                labelText: 'Country',
                prefixIcon: Icons.flag_outlined, // ADDED
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _phoneController,
                labelText: 'Phone Number',
                prefixIcon: Icons.phone_outlined, // ADDED
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _logoTextController,
                labelText: 'Logo Text',
                hintText: 'Leave empty to use: $clientName',
                prefixIcon: Icons.text_fields_outlined,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _onSave,
                icon: const Icon(Icons.save),
                label: const Text('Save Company'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
