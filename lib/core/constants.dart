// A centralized place for application-wide constants.

class AppConstants {
  // NEW: A list of available database prefixes for the user to select.
  static const List<String> databasePrefixes = ['Pro', 'MBH', 'PDB'];

  // UPDATED: The complete list of system modules with their correct RecordIds.
  static const Map<int, String> systemModules = {
    2: 'Accounts Payable',
    3: 'Accounts Receivable',
    17: 'Budgeting',
    9: 'Contracts',
    6: 'CRM',
    18: 'Customers & Property Listing',
    11: 'Facility Management',
    1: 'Finance',
    4: 'Fixed Assets',
    14: 'FNB POS',
    22: 'Help Desk',
    20: 'Integration',
    10: 'Legal',
    13: 'Procurement',
    19: 'Property Booking',
    7: 'Property Management',
    16: 'Reports',
    21: 'Retail POS',
    15: 'Trading',
    5: 'User Management', // Mandatory module
    12: 'Utility',
  };

  // The ID for the mandatory User Management module remains the same.
  static const int userManagementModuleId = 5;
}
