import 'package:flutter_test/flutter_test.dart';

// Test function for filename sanitization logic
String sanitizeFilename(String input) {
  // Remove or replace unsafe characters for filenames
  // Keep only alphanumeric characters, hyphens, and underscores
  return input
      .toLowerCase()
      .replaceAll(
          RegExp(r"['`]"), '') // Remove apostrophes and backticks entirely
      .replaceAll(RegExp(r'[^a-z0-9\-_]'),
          '_') // Replace other non-alphanumeric with underscore
      .replaceAll(
          RegExp(r'_+'), '_') // Replace multiple underscores with single
      .replaceAll(RegExp(r'^_|_$'), ''); // Remove leading/trailing underscores
}

void main() {
  group('Filename Sanitization Tests', () {
    test('should handle normal client names', () {
      expect(sanitizeFilename('Acme Corporation'), 'acme_corporation');
      expect(sanitizeFilename('Microsoft'), 'microsoft');
      expect(sanitizeFilename('ABC Company'), 'abc_company');
    });

    test('should handle special characters', () {
      expect(sanitizeFilename('Company @#\$% Test'), 'company_test');
      expect(sanitizeFilename('Test & Associates'), 'test_associates');
      expect(sanitizeFilename('Smith\'s Store'), 'smiths_store');
    });

    test('should handle multiple spaces and special chars', () {
      expect(
          sanitizeFilename('Multiple   Spaces   Test'), 'multiple_spaces_test');
      expect(sanitizeFilename('!!!Special!!! Company!!!'), 'special_company');
    });

    test('should handle edge cases', () {
      expect(sanitizeFilename('123'), '123');
      expect(sanitizeFilename('A'), 'a');
      expect(sanitizeFilename('Company-Name'), 'company-name');
      expect(sanitizeFilename('Company_Name'), 'company_name');
    });

    test('should handle numbers and mixed case', () {
      expect(sanitizeFilename('Company123'), 'company123');
      expect(sanitizeFilename('ABC123xyz'), 'abc123xyz');
    });

    test('should create proper logo filename', () {
      final clientName = 'Acme Corporation';
      final sanitized = sanitizeFilename(clientName);
      final logoFilename = 'logo_$sanitized';
      expect(logoFilename, 'logo_acme_corporation');
    });
  });
}
