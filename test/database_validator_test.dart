import 'package:flutter_test/flutter_test.dart';
import 'package:client_deployment_app/core/utils/database_validator.dart';

void main() {
  group('Database Validator Tests', () {
    group('validateDatabaseName', () {
      test('should accept valid client names', () {
        expect(
            DatabaseValidator.validateDatabaseName('Acme Corporation'), null);
        expect(DatabaseValidator.validateDatabaseName('Microsoft'), null);
        expect(DatabaseValidator.validateDatabaseName('ABC Company'), null);
        expect(DatabaseValidator.validateDatabaseName('Test-Company'), null);
        expect(DatabaseValidator.validateDatabaseName('Company.Inc'), null);
      });

      test('should reject empty or short names', () {
        expect(DatabaseValidator.validateDatabaseName(''),
            'Client name cannot be empty');
        expect(DatabaseValidator.validateDatabaseName('   '),
            'Client name cannot be empty');
        expect(DatabaseValidator.validateDatabaseName('A'),
            'Client name must be at least 2 characters long');
      });

      test('should reject names that start with numbers', () {
        expect(DatabaseValidator.validateDatabaseName('123Company'),
            'Client name cannot start with a number');
        expect(DatabaseValidator.validateDatabaseName('9Test'),
            'Client name cannot start with a number');
      });

      test('should reject reserved words', () {
        expect(DatabaseValidator.validateDatabaseName('SELECT'),
            'Client name cannot be a reserved database keyword');
        expect(DatabaseValidator.validateDatabaseName('table'),
            'Client name cannot be a reserved database keyword');
        expect(DatabaseValidator.validateDatabaseName('DATABASE'),
            'Client name cannot be a reserved database keyword');
        expect(DatabaseValidator.validateDatabaseName('admin'),
            'Client name cannot be a reserved database keyword');
      });

      test('should reject names with invalid characters', () {
        expect(DatabaseValidator.validateDatabaseName('Test@Company'),
            'Client name contains invalid characters. Use only letters, numbers, spaces, hyphens, and periods');
        expect(DatabaseValidator.validateDatabaseName('Company#Test'),
            'Client name contains invalid characters. Use only letters, numbers, spaces, hyphens, and periods');
        expect(DatabaseValidator.validateDatabaseName('Test&Associates'),
            'Client name contains invalid characters. Use only letters, numbers, spaces, hyphens, and periods');
      });

      test('should reject names with consecutive special characters', () {
        expect(DatabaseValidator.validateDatabaseName('Test  Company'),
            'Client name cannot contain consecutive spaces, hyphens, or periods');
        expect(DatabaseValidator.validateDatabaseName('Test--Company'),
            'Client name cannot contain consecutive spaces, hyphens, or periods');
        expect(DatabaseValidator.validateDatabaseName('Test..Company'),
            'Client name cannot contain consecutive spaces, hyphens, or periods');
      });

      test('should reject names ending with special characters', () {
        expect(DatabaseValidator.validateDatabaseName('Test Company '),
            'Client name cannot end with a space, hyphen, or period');
        expect(DatabaseValidator.validateDatabaseName('Test Company-'),
            'Client name cannot end with a space, hyphen, or period');
        expect(DatabaseValidator.validateDatabaseName('Test Company.'),
            'Client name cannot end with a space, hyphen, or period');
      });

      test('should reject names that are too long', () {
        final longName = 'A' * 51; // 51 characters
        expect(DatabaseValidator.validateDatabaseName(longName),
            'Client name must be no more than 50 characters long');
      });
    });

    group('sanitizeDatabaseName', () {
      test('should sanitize normal names correctly', () {
        expect(DatabaseValidator.sanitizeDatabaseName('Acme Corporation'),
            'acme_corporation');
        expect(
            DatabaseValidator.sanitizeDatabaseName('Microsoft'), 'microsoft');
        expect(DatabaseValidator.sanitizeDatabaseName('ABC Company'),
            'abc_company');
      });

      test('should handle special characters', () {
        expect(DatabaseValidator.sanitizeDatabaseName('Test@Company'),
            'test_company');
        expect(DatabaseValidator.sanitizeDatabaseName('Company#Test'),
            'company_test');
        expect(DatabaseValidator.sanitizeDatabaseName('Test&Associates'),
            'test_associates');
      });

      test('should handle names starting with numbers', () {
        expect(DatabaseValidator.sanitizeDatabaseName('123Company'),
            'client_123company');
        expect(DatabaseValidator.sanitizeDatabaseName('9Test'), 'client_9test');
      });

      test('should handle consecutive special characters', () {
        expect(DatabaseValidator.sanitizeDatabaseName('Test  Company'),
            'test_company');
        expect(DatabaseValidator.sanitizeDatabaseName('Test--Company'),
            'test_company');
        expect(DatabaseValidator.sanitizeDatabaseName('Test..Company'),
            'test_company');
      });

      test('should handle very short names', () {
        expect(DatabaseValidator.sanitizeDatabaseName('A'), 'client_a0');
        expect(DatabaseValidator.sanitizeDatabaseName(''), 'client_00');
      });

      test('should handle very long names', () {
        final longName = 'A' * 60; // 60 characters
        final sanitized = DatabaseValidator.sanitizeDatabaseName(longName);
        expect(sanitized.length, 50);
        expect(sanitized, 'a' * 50);
      });
    });

    group('generateDatabasePreview', () {
      test('should generate correct database preview', () {
        expect(
            DatabaseValidator.generateDatabasePreview(
                'Acme Corporation', 'Pro'),
            'Pro_acme_corporation');
        expect(DatabaseValidator.generateDatabasePreview('Microsoft', 'MBH'),
            'MBH_microsoft');
        expect(DatabaseValidator.generateDatabasePreview('ABC Company', 'PDB'),
            'PDB_abc_company');
      });

      test('should handle empty client name', () {
        expect(DatabaseValidator.generateDatabasePreview('', 'Pro'),
            'Pro[client_name]');
        expect(DatabaseValidator.generateDatabasePreview('   ', 'MBH'),
            'MBH[client_name]');
      });

      test('should handle special characters in preview', () {
        expect(DatabaseValidator.generateDatabasePreview('Test@Company', 'Pro'),
            'Pro_test_company');
        expect(DatabaseValidator.generateDatabasePreview('123Company', 'MBH'),
            'MBH_client_123company');
      });
    });

    group('isValidOrSanitizable', () {
      test('should return true for valid names', () {
        expect(
            DatabaseValidator.isValidOrSanitizable('Acme Corporation'), true);
        expect(DatabaseValidator.isValidOrSanitizable('Microsoft'), true);
        expect(DatabaseValidator.isValidOrSanitizable('ABC Company'), true);
      });

      test('should return true for sanitizable names', () {
        expect(DatabaseValidator.isValidOrSanitizable('Test@Company'), true);
        expect(DatabaseValidator.isValidOrSanitizable('123Company'), true);
        expect(DatabaseValidator.isValidOrSanitizable('Test  Company'), true);
      });

      test('should return false for empty names', () {
        expect(DatabaseValidator.isValidOrSanitizable(''), false);
        expect(DatabaseValidator.isValidOrSanitizable('   '), false);
      });
    });
  });
}
