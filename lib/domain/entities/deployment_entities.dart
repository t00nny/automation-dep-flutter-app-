import 'package:equatable/equatable.dart';

class ClientDeploymentRequest extends Equatable {
  final String clientName;
  final String databaseTypePrefix;
  final List<CompanyInfo> companies;
  final AdminUserInfo adminUser;
  final LicenseInfo license;
  final List<int> selectedModuleIds;
  final CompanyUrls urls;

  const ClientDeploymentRequest({
    required this.clientName,
    this.databaseTypePrefix = "Pro",
    required this.companies,
    required this.adminUser,
    required this.license,
    required this.selectedModuleIds,
    required this.urls,
  });

  Map<String, dynamic> toJson() => {
        'clientName': clientName,
        'databaseTypePrefix': databaseTypePrefix,
        'companies': companies.map((c) => c.toJson()).toList(),
        'adminUser': adminUser.toJson(),
        'license': license.toJson(),
        'selectedModuleIds': selectedModuleIds,
        'urls': urls.toJson(),
      };

  @override
  List<Object?> get props => [
        clientName,
        databaseTypePrefix,
        companies,
        adminUser,
        license,
        selectedModuleIds,
        urls
      ];
}

class CompanyInfo extends Equatable {
  final String companyName;
  final String address1;
  final String address2;
  final String city;
  final String country;
  final String phoneNumber;
  final String logoUrl;

  const CompanyInfo({
    this.companyName = '',
    this.address1 = '',
    this.address2 = '',
    this.city = '',
    this.country = '',
    this.phoneNumber = '',
    this.logoUrl = '',
  });

  CompanyInfo copyWith({
    String? companyName,
    String? address1,
    String? address2,
    String? city,
    String? country,
    String? phoneNumber,
  }) {
    return CompanyInfo(
      companyName: companyName ?? this.companyName,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      logoUrl: logoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'address1': address1,
        'address2': address2,
        'city': city,
        'country': country,
        'phoneNumber': phoneNumber,
        'logoUrl': logoUrl,
      };

  @override
  List<Object?> get props =>
      [companyName, address1, address2, city, country, phoneNumber, logoUrl];
}

class AdminUserInfo extends Equatable {
  final String email;
  final String contactNumber;
  final String branch;
  final String password;

  const AdminUserInfo({
    this.email = '',
    this.contactNumber = '',
    this.branch = 'HO',
    this.password = '',
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'contactNumber': contactNumber,
        'branch': branch,
        'password': password,
      };

  @override
  List<Object?> get props => [email, contactNumber, branch, password];
}

class LicenseInfo extends Equatable {
  final DateTime endDate;
  final int numberOfUsers;
  final bool usesNewEncryption;

  const LicenseInfo({
    required this.endDate,
    this.numberOfUsers = 1000,
    this.usesNewEncryption = true,
  });

  Map<String, dynamic> toJson() => {
        'endDate': endDate.toIso8601String(),
        'numberOfUsers': numberOfUsers,
        'usesNewEncryption': usesNewEncryption,
      };

  @override
  List<Object?> get props => [endDate, numberOfUsers, usesNewEncryption];
}

class CompanyUrls extends Equatable {
  final String crmurl;
  final String tradingURL;
  final String integrationURL;

  const CompanyUrls({
    this.crmurl = '',
    this.tradingURL = '',
    this.integrationURL = '',
  });

  Map<String, dynamic> toJson() => {
        'crmurl': crmurl,
        'tradingURL': tradingURL,
        'integrationURL': integrationURL,
      };

  @override
  List<Object?> get props => [crmurl, tradingURL, integrationURL];
}

class DeploymentResult extends Equatable {
  final bool isSuccess;
  final String errorMessage;
  final String clientHubDatabase;
  final List<String> createdCompanyDatabases;
  final List<String> logMessages;

  const DeploymentResult({
    required this.isSuccess,
    this.errorMessage = '',
    this.clientHubDatabase = '',
    this.createdCompanyDatabases = const [],
    this.logMessages = const [],
  });

  factory DeploymentResult.fromJson(Map<String, dynamic> json) =>
      DeploymentResult(
        isSuccess: json['isSuccess'] ?? false,
        errorMessage: json['errorMessage'] ?? '',
        clientHubDatabase: json['clientHubDatabase'] ?? '',
        createdCompanyDatabases:
            List<String>.from(json['createdCompanyDatabases'] ?? []),
        logMessages: List<String>.from(json['logMessages'] ?? []),
      );

  @override
  List<Object?> get props => [
        isSuccess,
        errorMessage,
        clientHubDatabase,
        createdCompanyDatabases,
        logMessages
      ];
}