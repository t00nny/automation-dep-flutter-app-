import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client_deployment_app/domain/entities/company_entities.dart';
import 'package:client_deployment_app/domain/usecases/get_all_companies.dart';
import 'package:client_deployment_app/domain/usecases/get_company_by_id.dart';
import 'package:client_deployment_app/domain/usecases/update_company.dart';
import 'package:client_deployment_app/domain/usecases/bulk_update_companies.dart';

part 'company_management_state.dart';

class CompanyManagementCubit extends Cubit<CompanyManagementState> {
  final GetAllCompanies _getAllCompanies;
  final GetCompanyById _getCompanyById;
  final UpdateCompany _updateCompany;
  final BulkUpdateCompanies _bulkUpdateCompanies;

  CompanyManagementCubit({
    required GetAllCompanies getAllCompanies,
    required GetCompanyById getCompanyById,
    required UpdateCompany updateCompany,
    required BulkUpdateCompanies bulkUpdateCompanies,
  })  : _getAllCompanies = getAllCompanies,
        _getCompanyById = getCompanyById,
        _updateCompany = updateCompany,
        _bulkUpdateCompanies = bulkUpdateCompanies,
        super(const CompanyManagementState());

  Future<void> loadCompanies() async {
    emit(state.copyWith(status: CompanyManagementStatus.loading));
    print('DEBUG: Loading companies from API');

    try {
      final companies = await _getAllCompanies();
      print('DEBUG: Loaded ${companies.length} companies from API');
      print(
          'DEBUG: First few companies: ${companies.take(3).map((c) => '${c.id}: ${c.companyName}').toList()}');

      emit(state.copyWith(
        status: CompanyManagementStatus.success,
        companies: companies,
        filteredCompanies: companies,
        selectedCompanies: const {},
      ));
    } catch (e) {
      print('DEBUG: Failed to load companies: $e');
      emit(state.copyWith(
        status: CompanyManagementStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadCompanyDetails(int companyId) async {
    emit(state.copyWith(detailsStatus: CompanyDetailsStatus.loading));
    print('DEBUG: Loading company details for ID: $companyId');

    try {
      final company = await _getCompanyById(companyId);
      print(
          'DEBUG: Loaded company details: ${company.companyName} (${company.id})');
      print(
          'DEBUG: Company status: ${company.status}, Users: ${company.numberOfUsers}');

      emit(state.copyWith(
        detailsStatus: CompanyDetailsStatus.success,
        selectedCompanyDetails: company,
      ));
    } catch (e) {
      print('DEBUG: Failed to load company details: $e');
      emit(state.copyWith(
        detailsStatus: CompanyDetailsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void searchCompanies(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(
        filteredCompanies: state.companies,
        searchQuery: '',
      ));
    } else {
      final lowerQuery = query.toLowerCase();
      final filtered = state.companies
          .where((company) =>
              company.companyName.toLowerCase().contains(lowerQuery) ||
              company.companyNo.toLowerCase().contains(lowerQuery) ||
              company.status.toLowerCase().contains(lowerQuery) ||
              company.baseDB.toLowerCase().contains(lowerQuery) ||
              company.dataDB.toLowerCase().contains(lowerQuery) ||
              company.email.toLowerCase().contains(lowerQuery))
          .toList();
      emit(state.copyWith(
        filteredCompanies: filtered,
        searchQuery: query,
      ));
    }
  }

  void toggleCompanySelection(int companyId) {
    final Set<int> newSelection = Set.from(state.selectedCompanies);
    if (newSelection.contains(companyId)) {
      newSelection.remove(companyId);
    } else {
      newSelection.add(companyId);
    }
    emit(state.copyWith(selectedCompanies: newSelection));
  }

  void selectAllCompanies() {
    final allIds = state.filteredCompanies.map((c) => c.id).toSet();
    emit(state.copyWith(selectedCompanies: allIds));
  }

  void clearSelection() {
    emit(state.copyWith(selectedCompanies: const {}));
  }

  Future<void> updateSingleCompany(int id, CompanyUpdateRequest request) async {
    emit(state.copyWith(updateStatus: CompanyUpdateStatus.loading));
    print('DEBUG: Starting single company update for ID: $id');

    try {
      await _updateCompany(id, request);
      print('DEBUG: Single company update completed successfully');

      // Reload companies to reflect changes first
      print('DEBUG: Reloading companies after single update');
      await _reloadCompaniesAfterUpdate();
      print('DEBUG: Companies reloaded after single update');

      // Then emit success state
      emit(state.copyWith(updateStatus: CompanyUpdateStatus.success));
      print('DEBUG: Update success state emitted');
    } catch (e) {
      print('DEBUG: Single company update failed: $e');
      emit(state.copyWith(
        updateStatus: CompanyUpdateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> bulkUpdate(BulkUpdateRequest request) async {
    emit(state.copyWith(updateStatus: CompanyUpdateStatus.loading));
    print(
        'DEBUG: Starting bulk update for ${request.companyIds.length} companies');

    try {
      await _bulkUpdateCompanies(request);
      print('DEBUG: Bulk update completed successfully');

      // Reload companies to reflect changes first
      print('DEBUG: Reloading companies after bulk update');
      await _reloadCompaniesAfterUpdate();
      print('DEBUG: Companies reloaded after bulk update');

      // Then emit success state
      emit(state.copyWith(
        updateStatus: CompanyUpdateStatus.success,
        selectedCompanies: const {},
      ));
    } catch (e) {
      print('DEBUG: Bulk update failed: $e');
      emit(state.copyWith(
        updateStatus: CompanyUpdateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // Private method to reload companies after update without affecting update status
  Future<void> _reloadCompaniesAfterUpdate() async {
    try {
      final companies = await _getAllCompanies();
      print('DEBUG: Loaded ${companies.length} companies after update');

      // Update companies data without changing the main status or update status
      emit(state.copyWith(
        companies: companies,
        filteredCompanies: state.searchQuery.isEmpty
            ? companies
            : companies.where((company) {
                final lowerQuery = state.searchQuery.toLowerCase();
                return company.companyName.toLowerCase().contains(lowerQuery) ||
                    company.companyNo.toLowerCase().contains(lowerQuery) ||
                    company.email.toLowerCase().contains(lowerQuery);
              }).toList(),
      ));
    } catch (e) {
      print('DEBUG: Failed to reload companies after update: $e');
      // Don't emit failure state here as the update itself was successful
      // The user can manually refresh if needed
    }
  }

  void clearError() {
    emit(state.copyWith(
      status: state.status == CompanyManagementStatus.failure
          ? CompanyManagementStatus.initial
          : state.status,
      detailsStatus: state.detailsStatus == CompanyDetailsStatus.failure
          ? CompanyDetailsStatus.initial
          : state.detailsStatus,
      updateStatus: state.updateStatus == CompanyUpdateStatus.failure
          ? CompanyUpdateStatus.initial
          : state.updateStatus,
      errorMessage: null,
    ));
  }

  void resetDetailsStatus() {
    emit(state.copyWith(
      detailsStatus: CompanyDetailsStatus.initial,
      selectedCompanyDetails: null,
    ));
  }

  void resetUpdateStatus() {
    emit(state.copyWith(updateStatus: CompanyUpdateStatus.initial));
  }

  // Force reload companies (public method)
  Future<void> forceReloadCompanies() async {
    print('DEBUG: Force reloading companies');
    await loadCompanies();
  }
}
