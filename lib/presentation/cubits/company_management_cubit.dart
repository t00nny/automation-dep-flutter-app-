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

    try {
      final companies = await _getAllCompanies();
      emit(state.copyWith(
        status: CompanyManagementStatus.success,
        companies: companies,
        filteredCompanies: companies,
        selectedCompanies: const {},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyManagementStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadCompanyDetails(int companyId) async {
    emit(state.copyWith(detailsStatus: CompanyDetailsStatus.loading));

    try {
      final company = await _getCompanyById(companyId);
      emit(state.copyWith(
        detailsStatus: CompanyDetailsStatus.success,
        selectedCompanyDetails: company,
      ));
    } catch (e) {
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

    try {
      await _updateCompany(id, request);
      emit(state.copyWith(updateStatus: CompanyUpdateStatus.success));
      // Reload companies to reflect changes
      await loadCompanies();
    } catch (e) {
      emit(state.copyWith(
        updateStatus: CompanyUpdateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> bulkUpdate(BulkUpdateRequest request) async {
    emit(state.copyWith(updateStatus: CompanyUpdateStatus.loading));

    try {
      await _bulkUpdateCompanies(request);
      emit(state.copyWith(
        updateStatus: CompanyUpdateStatus.success,
        selectedCompanies: const {},
      ));
      // Reload companies to reflect changes
      await loadCompanies();
    } catch (e) {
      emit(state.copyWith(
        updateStatus: CompanyUpdateStatus.failure,
        errorMessage: e.toString(),
      ));
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
}
