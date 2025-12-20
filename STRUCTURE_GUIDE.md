# Project Structure Guide

This Flutter project follows the recommended Flutter project structure guidelines for better code organization, maintainability, and scalability.

## Directory Structure

```
lib/
├── config/               # App configuration files
├── controllers/          # Business logic controllers
├── exceptions/          # Custom exception classes
├── l10n/               # Localization files
├── models/             # Data models and DTOs
├── providers/          # State management providers
├── screens/            # UI screen components
├── services/           # Business logic services & API calls
├── tabs/              # Tab-specific widgets
├── utils/             # Utility functions and helpers
├── widgets/           # Reusable UI components
│   └── common/        # Common widgets used across the app
├── constants.dart     # App-wide constants
├── main.dart         # App entry point
└── splash_screen.dart # Initial splash screen

test/                  # Unit and widget tests
assets/               # Static assets
├── images/          # Image assets
└── payment_configs/ # Payment configuration files
```

## Key Structural Improvements Made

1. **Moved test files** from root to `test/` directory:
   - `test_name_parsing.dart` → `test/test_name_parsing.dart`
   - `test_payment_request.dart` → `test/test_payment_request.dart`

2. **Consolidated providers** in `lib/providers/`:
   - `providers/ticket_provider.dart` → `lib/providers/ticket_provider.dart`

3. **Organized services** in `lib/services/`:
   - `api_service.dart` → `lib/services/api_service.dart`
   - `user_service.dart` → `lib/services/user_service.dart`

4. **Created widgets structure** for better UI organization:
   - Added `lib/widgets/` for reusable components
   - Added `lib/widgets/common/` for common UI elements

## Folder Guidelines

### `/lib/config/`
Contains app configuration files for different environments (dev, prod).

### `/lib/controllers/`
Houses business logic controllers organized by feature.

### `/lib/models/`
Data models, DTOs, and entity classes representing your app's data structure.

### `/lib/providers/`
State management classes (Provider, Riverpod, etc.).

### `/lib/screens/`
Complete screen widgets, organized by feature or section.

### `/lib/services/`
Business logic services, API calls, and data access layers.

### `/lib/widgets/`
Reusable UI components that can be used across different screens.

### `/lib/utils/`
Utility functions, helpers, and commonly used functions.

### `/test/`
All test files (unit tests, widget tests, integration tests).

## Best Practices Followed

1. **Separation of Concerns**: Clear separation between UI, business logic, and data layers
2. **Feature-based Organization**: Related files grouped together by feature
3. **Consistent Naming**: Following Dart naming conventions
4. **Import Path Optimization**: Using relative imports within modules, package imports across modules
5. **Asset Organization**: Logical grouping of assets by type

This structure provides a solid foundation for scaling your Flutter application while maintaining code quality and developer productivity.