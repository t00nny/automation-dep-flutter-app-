import 'package:equatable/equatable.dart';

class ExistingCompany extends Equatable {
  final int id;
  final String companyNo;
  final String companyName;
  final String email;
  final String contactNo;
  final String country;
  final String city;
  final String address;
  final String status;
  final bool usesNewEncryption;
  final int numberOfUsers;
  final DateTime? startJoinDate;
  final DateTime? endJoinDate;
  final String baseDB;
  final String dataDB;
  final String webURL;
  final String apiurl;
  final String crmurl;
  final String procurementURL;
  final String reportsURL;
  final String leasingURL;
  final String tradingURL;
  final String integrationURL;
  final String fnbPosURL;
  final String retailPOSUrl;

  const ExistingCompany({
    required this.id,
    required this.companyNo,
    required this.companyName,
    this.email = '',
    this.contactNo = '',
    this.country = '',
    this.city = '',
    this.address = '',
    required this.status,
    this.usesNewEncryption = false,
    required this.numberOfUsers,
    this.startJoinDate,
    this.endJoinDate,
    this.baseDB = '',
    this.dataDB = '',
    this.webURL = '',
    this.apiurl = '',
    this.crmurl = '',
    this.procurementURL = '',
    this.reportsURL = '',
    this.leasingURL = '',
    this.tradingURL = '',
    this.integrationURL = '',
    this.fnbPosURL = '',
    this.retailPOSUrl = '',
  });

  factory ExistingCompany.fromJson(Map<String, dynamic> json) {
    return ExistingCompany(
      id: json['id'] ?? 0,
      companyNo: json['companyNo'] ?? '',
      companyName: json['companyName'] ?? '',
      email: json['email'] ?? '',
      contactNo: json['contactNo'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      usesNewEncryption: json['usesNewEncryption'] ?? false,
      numberOfUsers: json['numberOfUsers'] ?? 0,
      startJoinDate: json['startJoinDate'] != null
          ? DateTime.parse(json['startJoinDate'])
          : null,
      endJoinDate: json['endJoinDate'] != null
          ? DateTime.parse(json['endJoinDate'])
          : null,
      baseDB: json['baseDB'] ?? '',
      dataDB: json['dataDB'] ?? '',
      webURL: json['webURL'] ?? '',
      apiurl: json['apiurl'] ?? '',
      crmurl: json['crmurl'] ?? '',
      procurementURL: json['procurementURL'] ?? '',
      reportsURL: json['reportsURL'] ?? '',
      leasingURL: json['leasingURL'] ?? '',
      tradingURL: json['tradingURL'] ?? '',
      integrationURL: json['integrationURL'] ?? '',
      fnbPosURL: json['fnbPosURL'] ?? '',
      retailPOSUrl: json['retailPOSUrl'] ?? '',
    );
  }

  ExistingCompany copyWith({
    int? id,
    String? companyNo,
    String? companyName,
    String? email,
    String? contactNo,
    String? country,
    String? city,
    String? address,
    String? status,
    bool? usesNewEncryption,
    int? numberOfUsers,
    DateTime? startJoinDate,
    DateTime? endJoinDate,
    String? baseDB,
    String? dataDB,
    String? webURL,
    String? apiurl,
    String? crmurl,
    String? procurementURL,
    String? reportsURL,
    String? leasingURL,
    String? tradingURL,
    String? integrationURL,
    String? fnbPosURL,
    String? retailPOSUrl,
  }) {
    return ExistingCompany(
      id: id ?? this.id,
      companyNo: companyNo ?? this.companyNo,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      contactNo: contactNo ?? this.contactNo,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      status: status ?? this.status,
      usesNewEncryption: usesNewEncryption ?? this.usesNewEncryption,
      numberOfUsers: numberOfUsers ?? this.numberOfUsers,
      startJoinDate: startJoinDate ?? this.startJoinDate,
      endJoinDate: endJoinDate ?? this.endJoinDate,
      baseDB: baseDB ?? this.baseDB,
      dataDB: dataDB ?? this.dataDB,
      webURL: webURL ?? this.webURL,
      apiurl: apiurl ?? this.apiurl,
      crmurl: crmurl ?? this.crmurl,
      procurementURL: procurementURL ?? this.procurementURL,
      reportsURL: reportsURL ?? this.reportsURL,
      leasingURL: leasingURL ?? this.leasingURL,
      tradingURL: tradingURL ?? this.tradingURL,
      integrationURL: integrationURL ?? this.integrationURL,
      fnbPosURL: fnbPosURL ?? this.fnbPosURL,
      retailPOSUrl: retailPOSUrl ?? this.retailPOSUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyNo,
        companyName,
        email,
        contactNo,
        country,
        city,
        address,
        status,
        usesNewEncryption,
        numberOfUsers,
        startJoinDate,
        endJoinDate,
        baseDB,
        dataDB,
        webURL,
        apiurl,
        crmurl,
        procurementURL,
        reportsURL,
        leasingURL,
        tradingURL,
        integrationURL,
        fnbPosURL,
        retailPOSUrl,
      ];
}

class CompanyUpdateRequest extends Equatable {
  final String? companyName;
  final String? email;
  final String? contactNo;
  final String? country;
  final String? city;
  final String? address;
  final String? webURL;
  final String? apiurl;
  final DateTime? endJoinDate;
  final String? status;
  final String? modifiedBy;
  final String? crmurl;
  final String? procurementURL;
  final String? reportsURL;
  final String? leasingURL;
  final String? logoText;
  final String? tradingURL;
  final String? integrationURL;
  final bool? usesNewEncryption;
  final String? fnbPosURL;
  final String? retailPOSUrl;
  final int? numberOfUsers;

  const CompanyUpdateRequest({
    this.companyName,
    this.email,
    this.contactNo,
    this.country,
    this.city,
    this.address,
    this.webURL,
    this.apiurl,
    this.endJoinDate,
    this.status,
    this.modifiedBy,
    this.crmurl,
    this.procurementURL,
    this.reportsURL,
    this.leasingURL,
    this.logoText,
    this.tradingURL,
    this.integrationURL,
    this.usesNewEncryption,
    this.fnbPosURL,
    this.retailPOSUrl,
    this.numberOfUsers,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (companyName != null) json['companyName'] = companyName;
    if (email != null) json['email'] = email;
    if (contactNo != null) json['contactNo'] = contactNo;
    if (country != null) json['country'] = country;
    if (city != null) json['city'] = city;
    if (address != null) json['address'] = address;
    if (webURL != null) json['webURL'] = webURL;
    if (apiurl != null) json['apiurl'] = apiurl;
    if (endJoinDate != null)
      json['endJoinDate'] = endJoinDate!.toIso8601String();
    if (status != null) json['status'] = status;
    if (modifiedBy != null) json['modifiedBy'] = modifiedBy;
    if (crmurl != null) json['crmurl'] = crmurl;
    if (procurementURL != null) json['procurementURL'] = procurementURL;
    if (reportsURL != null) json['reportsURL'] = reportsURL;
    if (leasingURL != null) json['leasingURL'] = leasingURL;
    if (logoText != null) json['logoText'] = logoText;
    if (tradingURL != null) json['tradingURL'] = tradingURL;
    if (integrationURL != null) json['integrationURL'] = integrationURL;
    if (usesNewEncryption != null)
      json['usesNewEncryption'] = usesNewEncryption;
    if (fnbPosURL != null) json['fnbPosURL'] = fnbPosURL;
    if (retailPOSUrl != null) json['retailPOSUrl'] = retailPOSUrl;
    if (numberOfUsers != null) json['numberOfUsers'] = numberOfUsers;

    return json;
  }

  @override
  List<Object?> get props => [
        companyName,
        email,
        contactNo,
        country,
        city,
        address,
        webURL,
        apiurl,
        endJoinDate,
        status,
        modifiedBy,
        crmurl,
        procurementURL,
        reportsURL,
        leasingURL,
        logoText,
        tradingURL,
        integrationURL,
        usesNewEncryption,
        fnbPosURL,
        retailPOSUrl,
        numberOfUsers,
      ];
}

class BulkUpdateRequest extends Equatable {
  final List<int> companyIds;
  final int? numberOfUsers;
  final DateTime? endJoinDate;
  final String? status;
  final bool? usesNewEncryption;

  const BulkUpdateRequest({
    required this.companyIds,
    this.numberOfUsers,
    this.endJoinDate,
    this.status,
    this.usesNewEncryption,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'companyIds': companyIds,
    };

    if (numberOfUsers != null) json['numberOfUsers'] = numberOfUsers;
    if (endJoinDate != null)
      json['endJoinDate'] = endJoinDate!.toIso8601String();
    if (status != null) json['status'] = status;
    if (usesNewEncryption != null)
      json['usesNewEncryption'] = usesNewEncryption;

    return json;
  }

  @override
  List<Object?> get props => [
        companyIds,
        numberOfUsers,
        endJoinDate,
        status,
        usesNewEncryption,
      ];
}
