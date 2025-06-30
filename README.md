# Deploy 360 - Client Deployment Automation

<div align="center">
  <img src="assets/icon/app_icon.png" alt="Deploy 360 Logo" width="120"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.2.0+-blue.svg)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  
  **Streamline your client onboarding process with automated deployment**
</div>

## 🚀 Overview

Deploy 360 is a comprehensive Flutter application designed to automate the client deployment process for enterprise systems. It provides a user-friendly, step-by-step wizard that guides administrators through setting up new client environments, configuring multiple companies, managing system modules, and deploying complete ERP solutions.

### ✨ Key Features

- **🎯 Guided Onboarding Process**: 7-step wizard for complete client setup
- **🏢 Multi-Company Support**: Configure multiple companies with individual settings
- **📊 Module Management**: Select from 20+ system modules (Finance, CRM, Procurement, etc.)
- **🔗 URL Configuration**: Flexible URL management for various services
- **👤 Admin Credentials**: Secure administrator account setup
- **📄 License Management**: Configure user limits and encryption settings
- **📱 Cross-Platform**: Supports Windows, macOS, Linux, iOS, and Android
- **📋 PDF Reports**: Generate detailed deployment summaries
- **🔍 Real-time Validation**: Database availability checking
- **🎨 Modern UI**: Clean, intuitive interface with Material Design

## 📱 Screenshots

### Main Features Flow
| Welcome Screen | Client Details | Company Setup | Module Selection |
|:--------------:|:--------------:|:-------------:|:----------------:|
| ![Welcome](docs/screenshots/welcome.png) | ![Client Details](docs/screenshots/step1.png) | ![Company Setup](docs/screenshots/step2.png) | ![Modules](docs/screenshots/step6.png) |

## 🛠️ Tech Stack

- **Framework**: Flutter 3.2.0+
- **Language**: Dart 3.0+
- **State Management**: BLoC/Cubit Pattern
- **Navigation**: GoRouter
- **Dependency Injection**: GetIt
- **Networking**: Dio
- **UI Components**: Material Design 3
- **PDF Generation**: pdf package
- **File Handling**: image_picker, path_provider

## 📋 Prerequisites

Before running this application, ensure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.2.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (version 3.0 or higher)
- An IDE with Flutter support ([VS Code](https://code.visualstudio.com/) with Flutter extension or [Android Studio](https://developer.android.com/studio))
- For specific platforms:
  - **Windows**: Visual Studio 2019 or later with C++ components
  - **macOS**: Xcode 14.0 or later
  - **Linux**: Standard development tools
  - **Android**: Android SDK and emulator
  - **iOS**: Xcode and iOS Simulator (macOS only)

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/automation-dep-flutter-app.git
cd automation-dep-flutter-app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Icons
```bash
flutter pub run flutter_launcher_icons:main
```

### 4. Run the Application
```bash
# For Windows
flutter run -d windows

# For Web
flutter run -d chrome

# For Android/iOS (with connected device or emulator)
flutter run
```

## 🏗️ Project Structure

```
lib/
├── core/                   # Core application logic
│   ├── app_router.dart    # Navigation routing
│   ├── app_theme.dart     # Theme configuration
│   ├── constants.dart     # App-wide constants
│   ├── di.dart           # Dependency injection
│   └── utils/            # Utility classes
├── data/                  # Data layer
│   ├── datasources/      # External data sources
│   └── repositories/     # Repository implementations
├── domain/               # Business logic layer
│   ├── entities/         # Domain entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/        # Business use cases
└── presentation/         # UI layer
    ├── cubits/          # State management (BLoC/Cubit)
    ├── pages/           # Application screens
    └── widgets/         # Reusable UI components
```

## 📖 Usage Guide

### Step-by-Step Deployment Process

1. **Welcome Screen**: Choose to start new onboarding or manage existing companies
2. **Client Details**: Enter client name and select database prefix
3. **Company Information**: Add and configure multiple companies
4. **Admin Credentials**: Set up administrator account details
5. **License Configuration**: Define user limits and encryption settings
6. **URL Setup**: Configure service URLs for various modules
7. **Module Selection**: Choose from available system modules
8. **Review & Deploy**: Final review and deployment execution

### Available System Modules

| Module | Description |
|--------|-------------|
| Finance | Core financial management |
| Accounts Payable | Vendor payment processing |
| Accounts Receivable | Customer billing and collections |
| CRM | Customer relationship management |
| Property Management | Real estate operations |
| Procurement | Purchase order management |
| Fixed Assets | Asset tracking and depreciation |
| User Management* | User access control (mandatory) |
| Budgeting | Financial planning tools |
| Reports | Business intelligence |
| Trading | Trading operations |
| And more... | 20+ modules available |

*Required module that cannot be deselected

### Database Prefixes

- **Pro**: Production environments
- **MBH**: Multi-branch environments  
- **PDB**: Development/testing environments

## 🔧 Configuration

### Environment Setup

Create environment-specific configurations in `lib/core/constants.dart`:

```dart
class AppConstants {
  static const List<String> databasePrefixes = ['Pro', 'MBH', 'PDB'];
  
  // API endpoints
  static const String baseApiUrl = 'https://your-api-domain.com';
  
  // Default URLs
  static const String defaultWebUrl = 'https://web.pro360erp.com';
  static const String defaultApiUrl = 'https://api.pro360erp.com';
  // ... more configurations
}
```

### Custom Themes

Modify `lib/core/app_theme.dart` to customize the application appearance:

```dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.blue,
    // Customize colors, fonts, and components
  );
}
```

## 🔨 Build & Deployment

### Building for Different Platforms

```bash
# Windows executable
flutter build windows

# Web application
flutter build web

# Android APK
flutter build apk

# iOS app (macOS only)
flutter build ios

# Linux executable
flutter build linux
```

### Release Configuration

1. Update version in `pubspec.yaml`
2. Configure signing certificates for mobile platforms
3. Build release versions:
```bash
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Test Structure
```
test/
├── unit/           # Unit tests
├── widget/         # Widget tests
└── integration/    # Integration tests
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use BLoC pattern for state management
- Write tests for new features
- Update documentation as needed
- Ensure cross-platform compatibility

## 📚 API Documentation

### Deployment Entities

```dart
class ClientDeploymentRequest {
  final String clientName;
  final String databaseTypePrefix;
  final List<CompanyInfo> companies;
  final AdminUserInfo adminUser;
  final LicenseInfo license;
  final List<int> selectedModuleIds;
  final CompanyUrls urls;
}
```

### Key Use Cases

- `DeployClient`: Execute client deployment
- `CheckDatabaseExists`: Validate database availability
- `UploadLogo`: Handle logo file uploads
- `GetAllCompanies`: Retrieve existing companies
- `UpdateCompany`: Modify company details

## 🐛 Troubleshooting

### Common Issues

**Build Errors**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build 
```

**Dependency Conflicts**
```bash
# Update dependencies
flutter pub deps
flutter pub upgrade
```





---

<div align="center">
  <strong>Made with ❤️ using Flutter</strong>
</div>
