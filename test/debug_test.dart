import 'package:flutter_test/flutter_test.dart';
import 'package:client_deployment_app/core/utils/database_validator.dart';

void main() {
  test('debug test', () {
    final result = DatabaseValidator.validateDatabaseName('Test Company ');
    print('Result: $result');
    print('Expected: Client name cannot end with a space, hyphen, or period');
    expect(result, 'Client name cannot end with a space, hyphen, or period');
  });
}
