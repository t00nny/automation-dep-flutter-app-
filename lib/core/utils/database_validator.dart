// Database name validation utility
// This utility ensures that client names are valid for use as database names

class DatabaseValidator {
  /// Validates if a client name is suitable for use as a database name
  /// Returns null if valid, error message if invalid
  static String? validateDatabaseName(String clientName) {
    if (clientName.trim().isEmpty) {
      return 'Client name cannot be empty';
    }

    // Check for ending with special characters BEFORE trimming
    if (RegExp(r'[\s\-\.]$').hasMatch(clientName)) {
      return 'Client name cannot end with a space, hyphen, or period';
    }

    final trimmedName = clientName.trim();

    // Check minimum length
    if (trimmedName.length < 2) {
      return 'Client name must be at least 2 characters long';
    }

    // Check maximum length (typical database name limit is 64 characters)
    if (trimmedName.length > 50) {
      return 'Client name must be no more than 50 characters long';
    }

    // Check for invalid starting characters
    if (RegExp(r'^[0-9]').hasMatch(trimmedName)) {
      return 'Client name cannot start with a number';
    }

    // Check for SQL reserved words (common ones)
    final reservedWords = [
      'select',
      'insert',
      'update',
      'delete',
      'create',
      'drop',
      'alter',
      'table',
      'database',
      'index',
      'view',
      'procedure',
      'function',
      'trigger',
      'user',
      'role',
      'grant',
      'revoke',
      'commit',
      'rollback',
      'transaction',
      'begin',
      'end',
      'if',
      'else',
      'while',
      'for',
      'order',
      'group',
      'having',
      'where',
      'from',
      'join',
      'union',
      'null',
      'true',
      'false',
      'admin',
      'root',
      'sys',
      'system',
      'master',
      'model',
      'temp',
      'tempdb',
      'msdb',
      'information_schema'
    ];

    if (reservedWords.contains(trimmedName.toLowerCase())) {
      return 'Client name cannot be a reserved database keyword';
    }

    // Check for problematic characters that might cause issues in database names
    if (RegExp(r'[^\w\s\-\.]').hasMatch(trimmedName)) {
      return 'Client name contains invalid characters. Use only letters, numbers, spaces, hyphens, and periods';
    }

    // Check for consecutive special characters
    if (RegExp(r'[\s\-\.]{2,}').hasMatch(trimmedName)) {
      return 'Client name cannot contain consecutive spaces, hyphens, or periods';
    }

    return null; // Valid
  }

  /// Sanitizes a client name to be safe for use as a database name
  /// This method creates a database-safe version of the client name
  static String sanitizeDatabaseName(String clientName) {
    String sanitized = clientName.trim();

    // Remove invalid characters and replace with underscores
    sanitized = sanitized
        .toLowerCase()
        .replaceAll(RegExp(r"['`]"), '') // Remove quotes entirely
        .replaceAll(RegExp(r'[^\w\s\-\.]'),
            '_') // Replace invalid chars with underscore
        .replaceAll(RegExp(r'[\s\-\.]+'),
            '_') // Replace spaces, hyphens, periods with single underscore
        .replaceAll(
            RegExp(r'_+'), '_') // Replace multiple underscores with single
        .replaceAll(
            RegExp(r'^_|_$'), ''); // Remove leading/trailing underscores

    // Ensure it doesn't start with a number
    if (RegExp(r'^[0-9]').hasMatch(sanitized)) {
      sanitized = 'client_$sanitized';
    }

    // Ensure minimum length
    if (sanitized.length < 2) {
      sanitized = 'client_${sanitized.padRight(2, '0')}';
    }

    // Ensure maximum length
    if (sanitized.length > 50) {
      sanitized = sanitized.substring(0, 50);
    }

    return sanitized;
  }

  /// Generates a preview of what the database name would look like
  /// This helps users understand how their client name will be used
  static String generateDatabasePreview(String clientName, String prefix) {
    if (clientName.trim().isEmpty) {
      return '$prefix[client_name]';
    }

    final sanitized = sanitizeDatabaseName(clientName);
    return '${prefix}_$sanitized';
  }

  /// Checks if a client name would result in a valid database name
  /// Returns true if the name is valid or can be sanitized to be valid
  static bool isValidOrSanitizable(String clientName) {
    if (clientName.trim().isEmpty) {
      return false;
    }

    final sanitized = sanitizeDatabaseName(clientName);
    return sanitized.isNotEmpty && sanitized.length >= 2;
  }
}
