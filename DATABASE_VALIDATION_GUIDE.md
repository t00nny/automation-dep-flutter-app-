# Database Name Validation for Client Names

The client name validation system has been enhanced to ensure that client names are suitable for use as database names. Here's what has been implemented:

## Features Added

### 1. Database Name Validation
- **Purpose**: Validates that client names can be safely used as database names
- **Location**: `lib/core/utils/database_validator.dart`

### 2. Enhanced Client Name Field
- **Visual Feedback**: Shows a preview of what the database name will look like
- **Real-time Validation**: Validates as the user types
- **Helpful Guidelines**: Shows naming rules to guide users

### 3. Comprehensive Test Suite
- **Test Coverage**: Full validation logic testing
- **Edge Cases**: Handles special characters, reserved words, length limits

## Database Naming Rules

### Valid Characters
- Letters (a-z, A-Z)
- Numbers (0-9)
- Spaces
- Hyphens (-)
- Periods (.)

### Restrictions
- **Length**: 2-50 characters
- **Cannot start with**: Numbers
- **Cannot end with**: Spaces, hyphens, or periods
- **Cannot contain**: Consecutive special characters
- **Cannot be**: SQL reserved keywords

### Reserved Keywords
Common SQL reserved words are blocked, including:
- `select`, `insert`, `update`, `delete`
- `create`, `drop`, `alter`, `table`
- `database`, `admin`, `root`, `system`
- And many more...

## Examples

### Valid Client Names
✅ `Acme Corporation` → `Pro_acme_corporation`
✅ `Microsoft` → `Pro_microsoft`
✅ `ABC Company` → `Pro_abc_company`
✅ `Test-Company` → `Pro_test_company`

### Invalid Client Names
❌ `123Company` (starts with number)
❌ `Test Company ` (ends with space)
❌ `Company@Test` (invalid character)
❌ `SELECT` (reserved keyword)
❌ `Test  Company` (consecutive spaces)
❌ `A` (too short)

## Database Preview Feature

The Step 1 page now shows:
1. **Real-time Preview**: `[Prefix]_[sanitized_client_name]`
2. **Validation Messages**: Clear error messages for invalid names
3. **Naming Guidelines**: Helpful tips for users

## Usage

The validation automatically triggers when users:
- Type in the client name field
- Change the database prefix
- Submit the form

The system ensures that only valid client names can proceed to the next step, preventing database creation issues later in the deployment process.
