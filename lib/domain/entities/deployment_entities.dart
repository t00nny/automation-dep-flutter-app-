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

// UPDATED: Comprehensive URL configuration with enable/disable functionality
class CompanyUrls extends Equatable {
  final String webURL;
  final bool webURLEnabled;
  final String apiURL;
  final bool apiURLEnabled;
  final String crmurl;
  final bool crmurlEnabled;
  final String procurementURL;
  final bool procurementURLEnabled;
  final String reportsURL;
  final bool reportsURLEnabled;
  final String leasingURL;
  final bool leasingURLEnabled;
  final String tradingURL;
  final bool tradingURLEnabled;
  final String integrationURL;
  final bool integrationURLEnabled;
  final String fnbPosURL;
  final bool fnbPosURLEnabled;
  final String retailPOSUrl;
  final bool retailPOSUrlEnabled;
  final String logoUrl;

  const CompanyUrls({
    this.webURL = 'https://web.pro360erp.com',
    this.webURLEnabled = true,
    this.apiURL = 'https://api.pro360erp.com',
    this.apiURLEnabled = true,
    this.crmurl = 'https://crm.pro360erp.com',
    this.crmurlEnabled = true,
    this.procurementURL = 'https://proc.pro360erp.com',
    this.procurementURLEnabled = true,
    this.reportsURL = 'https://reports.pro360erp.com',
    this.reportsURLEnabled = true,
    this.leasingURL = 'https://lease.pro360erp.com',
    this.leasingURLEnabled = true,
    this.tradingURL = 'https://trading.pro360erp.com',
    this.tradingURLEnabled = true,
    this.integrationURL = 'https://integration.apps.pro360erp.com',
    this.integrationURLEnabled = true,
    this.fnbPosURL = 'https://pos.pro360erp.com',
    this.fnbPosURLEnabled = true,
    this.retailPOSUrl = 'https://retail.apps.pro360erp.com',
    this.retailPOSUrlEnabled = true,
    this.logoUrl = '',
  });
  CompanyUrls copyWith({
    String? webURL,
    bool? webURLEnabled,
    String? apiURL,
    bool? apiURLEnabled,
    String? crmurl,
    bool? crmurlEnabled,
    String? procurementURL,
    bool? procurementURLEnabled,
    String? reportsURL,
    bool? reportsURLEnabled,
    String? leasingURL,
    bool? leasingURLEnabled,
    String? tradingURL,
    bool? tradingURLEnabled,
    String? integrationURL,
    bool? integrationURLEnabled,
    String? fnbPosURL,
    bool? fnbPosURLEnabled,
    String? retailPOSUrl,
    bool? retailPOSUrlEnabled,
    String? logoUrl,
  }) {
    return CompanyUrls(
      webURL: webURL ?? this.webURL,
      webURLEnabled: webURLEnabled ?? this.webURLEnabled,
      apiURL: apiURL ?? this.apiURL,
      apiURLEnabled: apiURLEnabled ?? this.apiURLEnabled,
      crmurl: crmurl ?? this.crmurl,
      crmurlEnabled: crmurlEnabled ?? this.crmurlEnabled,
      procurementURL: procurementURL ?? this.procurementURL,
      procurementURLEnabled:
          procurementURLEnabled ?? this.procurementURLEnabled,
      reportsURL: reportsURL ?? this.reportsURL,
      reportsURLEnabled: reportsURLEnabled ?? this.reportsURLEnabled,
      leasingURL: leasingURL ?? this.leasingURL,
      leasingURLEnabled: leasingURLEnabled ?? this.leasingURLEnabled,
      tradingURL: tradingURL ?? this.tradingURL,
      tradingURLEnabled: tradingURLEnabled ?? this.tradingURLEnabled,
      integrationURL: integrationURL ?? this.integrationURL,
      integrationURLEnabled:
          integrationURLEnabled ?? this.integrationURLEnabled,
      fnbPosURL: fnbPosURL ?? this.fnbPosURL,
      fnbPosURLEnabled: fnbPosURLEnabled ?? this.fnbPosURLEnabled,
      retailPOSUrl: retailPOSUrl ?? this.retailPOSUrl,
      retailPOSUrlEnabled: retailPOSUrlEnabled ?? this.retailPOSUrlEnabled,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'webURL': webURLEnabled ? webURL : '',
        'apiURL': apiURLEnabled ? apiURL : '',
        'crmurl': crmurlEnabled ? crmurl : '',
        'procurementURL': procurementURLEnabled ? procurementURL : '',
        'reportsURL': reportsURLEnabled ? reportsURL : '',
        'leasingURL': leasingURLEnabled ? leasingURL : '',
        'tradingURL': tradingURLEnabled ? tradingURL : '',
        'integrationURL': integrationURLEnabled ? integrationURL : '',
        'fnbPosURL': fnbPosURLEnabled ? fnbPosURL : '',
        'retailPOSUrl': retailPOSUrlEnabled ? retailPOSUrl : '',
        'logoUrl': logoUrl,
      };
  @override
  List<Object?> get props => [
        webURL,
        webURLEnabled,
        apiURL,
        apiURLEnabled,
        crmurl,
        crmurlEnabled,
        procurementURL,
        procurementURLEnabled,
        reportsURL,
        reportsURLEnabled,
        leasingURL,
        leasingURLEnabled,
        tradingURL,
        tradingURLEnabled,
        integrationURL,
        integrationURLEnabled,
        fnbPosURL,
        fnbPosURLEnabled,
        retailPOSUrl,
        retailPOSUrlEnabled,
        logoUrl,
      ];
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
