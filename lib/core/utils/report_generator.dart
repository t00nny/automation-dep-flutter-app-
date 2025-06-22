import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:client_deployment_app/domain/entities/deployment_entities.dart';

class ReportGenerator {
  static Future<void> generateAndShareReport(DeploymentResult result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(result),
          pw.SizedBox(height: 20),
          _buildSummary(result),
          pw.SizedBox(height: 20),
          if (result.isSuccess) ...[
            _buildDatabasesSection(result),
            pw.SizedBox(height: 20),
          ],
          _buildLogSection(result.logMessages),
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

  static pw.Widget _buildHeader(DeploymentResult result) {
    return pw.Header(
      level: 0,
      child: pw.Row(
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
        ],
      ),
    );
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
        // FIXED: Replaced deprecated method
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

  static pw.Widget _buildLogSection(List<String> logMessages) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Deployment Log',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: logMessages
                .map((log) =>
                    pw.Text('• $log', style: const pw.TextStyle(fontSize: 10)))
                .toList(),
          ),
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
}
