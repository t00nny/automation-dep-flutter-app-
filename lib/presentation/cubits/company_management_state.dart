part of 'company_management_cubit.dart';

enum CompanyManagementStatus { initial, loading, success, failure }

enum CompanyDetailsStatus { initial, loading, success, failure }

enum CompanyUpdateStatus { initial, loading, success, failure }

class CompanyManagementState extends Equatable {
  final CompanyManagementStatus status;
  final CompanyDetailsStatus detailsStatus;
  final CompanyUpdateStatus updateStatus;
  final List<ExistingCompany> companies;
  final List<ExistingCompany> filteredCompanies;
  final Set<int> selectedCompanies;
  final ExistingCompany? selectedCompanyDetails;
  final String searchQuery;
  final String? errorMessage;

  const CompanyManagementState({
    this.status = CompanyManagementStatus.initial,
    this.detailsStatus = CompanyDetailsStatus.initial,
    this.updateStatus = CompanyUpdateStatus.initial,
    this.companies = const [],
    this.filteredCompanies = const [],
    this.selectedCompanies = const {},
    this.selectedCompanyDetails,
    this.searchQuery = '',
    this.errorMessage,
  });

  CompanyManagementState copyWith({
    CompanyManagementStatus? status,
    CompanyDetailsStatus? detailsStatus,
    CompanyUpdateStatus? updateStatus,
    List<ExistingCompany>? companies,
    List<ExistingCompany>? filteredCompanies,
    Set<int>? selectedCompanies,
    ExistingCompany? selectedCompanyDetails,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CompanyManagementState(
      status: status ?? this.status,
      detailsStatus: detailsStatus ?? this.detailsStatus,
      updateStatus: updateStatus ?? this.updateStatus,
      companies: companies ?? this.companies,
      filteredCompanies: filteredCompanies ?? this.filteredCompanies,
      selectedCompanies: selectedCompanies ?? this.selectedCompanies,
      selectedCompanyDetails:
          selectedCompanyDetails ?? this.selectedCompanyDetails,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  bool get hasSelectedCompanies => selectedCompanies.isNotEmpty;

  bool get isAllSelected =>
      filteredCompanies.isNotEmpty &&
      selectedCompanies.length == filteredCompanies.length &&
      filteredCompanies
          .every((company) => selectedCompanies.contains(company.id));

  @override
  List<Object?> get props => [
        status,
        detailsStatus,
        updateStatus,
        companies,
        filteredCompanies,
        selectedCompanies,
        selectedCompanyDetails,
        searchQuery,
        errorMessage,
      ];
}
