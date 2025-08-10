<!-- 
This file provides instructions for AI coding agents working in the Bunyan Flutter project.
-->

### Project Overview & Architecture

This is a Flutter application for the construction sector called "Bunyan". The project is structured to support multiple user roles with distinct functionalities.

- **Multi-Portal Architecture**: The app has different entry points for various user types. Each entry point has its own `main_*.dart` file (e.g., `lib/main_admin.dart`, `lib/main_client.dart`, `lib/main_selector_page.dart`). The `main_selector_page.dart` acts as the initial portal to choose between the "Client Site" and the "Business Portal" (for admin, suppliers, etc.).

- **State Management**: The project uses the `provider` package for state management. Key managers like `LanguageManager`, `AuthManager`, and `PermissionManager` are provided at the root of the application using `MultiProvider`. When adding new global state, follow this pattern.

- **Database & Services**:
    - Local persistence is handled by SQLite via `lib/database_helper.dart`. This is the central point for all CRUD operations.
    - Services like `DatabaseSyncService` (`lib/database_sync_service.dart`) and `ReportingService` (`lib/reporting_service.dart`) provide higher-level business logic on top of the database.
    - Authentication is managed through `lib/authentication_service.dart` and `lib/auth_manager.dart`.

### Developer Workflows

- **Running the App**: To run the application, you must specify the target entry point file. For example, to run the main application with the portal selector:
  ```sh
  flutter run -t lib/main_selector_page.dart
  ```
  To run the client-facing site directly:
  ```sh
  flutter run -t lib/main_client.dart
  ```

- **Building**: When creating a build, ensure you specify the correct entry point with the `-t` flag, similar to running the app.

### Conventions & Patterns

- **Localization**: The application is multilingual. Text is managed through `LanguageManager` (`lib/language_manager.dart`). UI text should not be hard-coded; use the localization system.

- **Permissions**: Role-based permissions are managed by `PermissionManager` (`lib/permissions.dart`). UI elements that require specific permissions should be conditionally rendered based on the current user's role and permissions.

- **Routing**: The application uses named routes defined within the `MaterialApp` widget in each `main_*.dart` file. When adding new pages, define the routes there.

- **Modular Services**: The app is divided into service pages for different roles (e.g., `lib/admin_service_page.dart`, `lib/client_service_page.dart`). When adding new features for a specific role, they should be added to the corresponding service page.

### Key Files & Directories

- `lib/`: Contains all the application's Dart code.
- `lib/l10n/`: Contains localization files.
- `lib/main_*.dart`: Entry points for different application portals.
- `lib/database_helper.dart`: Core of the local database.
- `lib/auth_manager.dart`: Handles authentication state.
- `lib/permissions.dart`: Manages user roles and permissions.
- `pubspec.yaml`: Project dependencies and assets.

