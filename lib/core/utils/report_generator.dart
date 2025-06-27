import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';
import 'package:client_deployment_app/core/constants.dart';
import 'package:intl/intl.dart';

class ReportGenerator {
  static Future<void> generateAndShareReport(
    DeploymentResult result,
    ClientDeploymentRequest request,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(request),
          pw.SizedBox(height: 20),
          _buildSummary(result),
          pw.SizedBox(height: 20),
          _buildClientInformation(request),
          pw.SizedBox(height: 20),
          _buildAdministratorCredentials(request.adminUser),
          pw.SizedBox(height: 20),
          _buildDeploymentConfiguration(request),
          if (result.isSuccess) ...[
            pw.SizedBox(height: 20),
            _buildDatabasesSection(result),
          ],
          if (!result.isSuccess) ...[
            pw.SizedBox(height: 20),
            _buildErrorSection(result.errorMessage),
          ],
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/deployment_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Client Deployment Report',
    );
  }

  static pw.Widget _buildHeader(ClientDeploymentRequest request) {
    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Client Deployment Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                DateTime.now().toIso8601String().split('T').first,
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Client: ${request.clientName}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummary(DeploymentResult result) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: result.isSuccess ? PdfColors.green50 : PdfColors.red50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Deployment Summary',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(height: 10, color: PdfColors.grey400),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Status:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                result.isSuccess ? 'SUCCESS' : 'FAILURE',
                style: pw.TextStyle(
                  color: result.isSuccess ? PdfColors.green : PdfColors.red,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Deployment Date:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildClientInformation(ClientDeploymentRequest request) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Client Information',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(height: 10, color: PdfColors.grey400),
        pw.SizedBox(height: 10),
        _buildInfoRow('Client Name:', request.clientName),
        _buildInfoRow('Database Prefix:', request.databaseTypePrefix),
        pw.SizedBox(height: 10),
        pw.Text(
          'Companies:',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        ...request.companies.map((company) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20, bottom: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ${company.companyName}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  if (company.address1.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10),
                      child: pw.Text('Address: ${company.address1}'),
                    ),
                  if (company.city.isNotEmpty && company.country.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10),
                      child: pw.Text(
                          'Location: ${company.city}, ${company.country}'),
                    ),
                  if (company.phoneNumber.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10),
                      child: pw.Text('Phone: ${company.phoneNumber}'),
                    ),
                ],
              ),
            )),
      ],
    );
  }

  static pw.Widget _buildAdministratorCredentials(AdminUserInfo adminUser) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.orange300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: PdfColors.orange50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Icon(const pw.IconData(0xe88f),
                  size: 20, color: PdfColors.orange800),
              pw.SizedBox(width: 8),
              pw.Text(
                'Administrator Access Credentials',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange800,
                ),
              ),
            ],
          ),
          pw.Divider(height: 10, color: PdfColors.orange300),
          pw.SizedBox(height: 5),
          pw.Text(
            'CONFIDENTIAL - Handle with care',
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.orange700,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Email:', adminUser.email),
          _buildInfoRow('Contact Number:', adminUser.contactNumber),
          _buildInfoRow('Branch:', adminUser.branch),
          _buildInfoRow('Password:', adminUser.password, isPassword: true),
        ],
      ),
    );
  }

  // UPDATED: Enhanced deployment configuration with comprehensive URL details
  static pw.Widget _buildDeploymentConfiguration(
      ClientDeploymentRequest request) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Deployment Configuration',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(height: 10, color: PdfColors.grey400),
        pw.SizedBox(height: 10),

        // License Information
        pw.Text(
          'License Information:',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        _buildInfoRow(
            '  Number of Users:', request.license.numberOfUsers.toString()),
        _buildInfoRow('  License End Date:',
            DateFormat.yMMMd().format(request.license.endDate)),
        _buildInfoRow('  New Encryption:',
            request.license.usesNewEncryption ? 'Enabled' : 'Disabled'),

        pw.SizedBox(height: 15),

        // UPDATED: Comprehensive System URLs Configuration
        pw.Text(
          'System URLs Configuration:',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),

        // Create a table for better URL presentation
        pw.TableHelper.fromTextArray(
          headers: ['Service', 'Status', 'URL'],
          data: [
            [
              'Web Portal',
              request.urls.webURLEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.webURLEnabled
                  ? request.urls.webURL
                  : 'Not configured'
            ],
            [
              'API Service',
              request.urls.apiURLEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.apiURLEnabled
                  ? request.urls.apiURL
                  : 'Not configured'
            ],
            [
              'CRM System',
              request.urls.crmurlEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.crmurlEnabled
                  ? request.urls.crmurl
                  : 'Not configured'
            ],
            [
              'Procurement',
              request.urls.procurementURLEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.procurementURLEnabled
                  ? request.urls.procurementURL
                  : 'Not configured'
            ],
            [
              'Reports',
              request.urls.reportsURLEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.reportsURLEnabled
                  ? request.urls.reportsURL
                  : 'Not configured'
            ],
            [
              'Leasing',
              request.urls.leasingURLEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.leasingURLEnabled
                  ? request.urls.leasingURL
                  : 'Not configured'
            ],
            [
              'Trading',
              request.urls.tradingURLEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.tradingURLEnabled
                  ? request.urls.tradingURL
                  : 'Not configured'
            ],
            [
              'Integration',
              request.urls.integrationURLEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.integrationURLEnabled
                  ? request.urls.integrationURL
                  : 'Not configured'
            ],
            [
              'F&B POS',
              request.urls.fnbPosURLEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.fnbPosURLEnabled
                  ? request.urls.fnbPosURL
                  : 'Not configured'
            ],
            [
              'Retail POS',
              request.urls.retailPOSUrlEnabled ? '✓ Enabled' : '✗ Disabled',
              request.urls.retailPOSUrlEnabled
                  ? request.urls.retailPOSUrl
                  : 'Not configured'
            ],
          ],
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle:
              pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(4),
          columnWidths: {
            0: const pw.FixedColumnWidth(80), // Service name
            1: const pw.FixedColumnWidth(60), // Status
            2: const pw.FlexColumnWidth(), // URL (flexible)
          },
        ),

        pw.SizedBox(height: 15),

        // Summary of enabled URLs
        pw.Text(
          'URL Configuration Summary:',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total URLs configured:'),
            pw.Text('${_getEnabledUrlCount(request.urls)}'),
          ],
        ),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('URLs enabled:'),
            pw.Text('${_getEnabledUrlCount(request.urls)}'),
          ],
        ),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('URLs disabled:'),
            pw.Text('${10 - _getEnabledUrlCount(request.urls)}'),
          ],
        ),

        pw.SizedBox(height: 15),

        // Selected Modules
        pw.Text(
          'Enabled Modules:',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Wrap(
          spacing: 8,
          runSpacing: 4,
          children: request.selectedModuleIds.map((moduleId) {
            final moduleName =
                AppConstants.systemModules[moduleId] ?? 'Unknown Module';
            return pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: PdfColors.blue300),
              ),
              child: pw.Text(
                moduleName,
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.blue800),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Helper method to count enabled URLs
  static int _getEnabledUrlCount(CompanyUrls urls) {
    int count = 0;
    if (urls.webURLEnabled) count++;
    if (urls.apiURLEnabled) count++;
    if (urls.crmurlEnabled) count++;
    if (urls.procurementURLEnabled) count++;
    if (urls.reportsURLEnabled) count++;
    if (urls.leasingURLEnabled) count++;
    if (urls.tradingURLEnabled) count++;
    if (urls.integrationURLEnabled) count++;
    if (urls.fnbPosURLEnabled) count++;
    if (urls.retailPOSUrlEnabled) count++;
    return count;
  }

  static pw.Widget _buildDatabasesSection(DeploymentResult result) {
    if (result.clientHubDatabase.isEmpty &&
        result.createdCompanyDatabases.isEmpty) {
      return pw.Container();
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Created Databases',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.TableHelper.fromTextArray(
          headers: ['Type', 'Database Name'],
          data: [
            if (result.clientHubDatabase.isNotEmpty)
              ['Client Hub', result.clientHubDatabase],
            ...result.createdCompanyDatabases.map((db) => ['Company', db]),
          ],
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(5),
        ),
      ],
    );
  }

  static pw.Widget _buildErrorSection(String errorMessage) {
    if (errorMessage.isEmpty) return pw.Container();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Error Message',
          style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.red),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            color: PdfColors.red50,
          ),
          child: pw.Text(
            errorMessage,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.red800),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value,
      {bool isPassword = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: isPassword
                ? pw.Container(
                    color: PdfColors.yellow100,
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    child: pw.Text(
                      value,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  )
                : pw.Text(value),
          ),
        ],
      ),
    );
  }
}
