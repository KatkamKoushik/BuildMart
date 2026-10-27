# BuildMart 🏗️

A production-ready marketplace application for Construction Materials (Cement, Steel, Sand, Bricks, Tiles, Hardware, and Electricals), built with **Flutter**.

---

## 🚀 Features

*   **Premium UI/UX:** Built with a stunning `Dark/White/Yellow (#FFC107)` theme, utilizing `flutter_animate` for smooth staggered animations and `carousel_slider` for dynamic top banners.
*   **Complete Dark Mode:** Native, automatic OS-level Dark Mode utilizing Material 3 `ColorScheme` tokens.
*   **Advanced Search Engine:** 
    *   **Voice Search:** Speak search queries via `speech_to_text`.
    *   **Barcode Scanning:** Instantly find products by scanning barcodes/QR codes via `mobile_scanner`.
    *   **Image Recognition:** Snap or select material photos for visual recommendations via `image_picker`.
*   **Performance First:** 
    *   Skeleton loaders (`ShimmerLoader`) for instant perceived load times.
    *   Infinite pagination via `ScrollController` on product listings.
    *   Offline-first caching via `Hive`.
*   **Security & Token Storage:**
    *   Hardware-backed keystore/keychain credential isolation via `flutter_secure_storage` (`SecureStorage`).
*   **Core Systems:**
    *   **State Management:** Reactive architecture using `flutter_riverpod`.
    *   **Routing:** Type-safe declarative routing via `go_router` (including `StatefulShellRoute` bottom navigation).
    *   **API Layer:** `Dio` client configured for Clean Architecture Repository patterns.
    *   **Models:** Immutable, JSON-serializable models generated via `freezed`.
    *   **Localization:** Fully configured `flutter_localizations` supporting `.arb` files for multi-language scaling.

---

## 🛠️ Architecture & Repository Structure

```text
buildmart/
├── .github/
│   └── workflows/
│       └── flutter_ci.yml     # Continuous Integration pipeline (Lint, Test, Build)
├── android/                   # Native Android host & google-services.json
├── assets/                    # Bundled application assets & seed data
├── ios/                       # Native iOS host configuration
├── lib/                       # Production Application Source Code
│   ├── core/                  # Core constants, themes, security, and providers
│   ├── features/              # Feature modules (auth, home, products, cart, checkout, etc.)
│   ├── l10n/                  # Localization templates and ARB files
│   ├── navigation/            # go_router declarative route definitions
│   ├── services/              # API clients and caching services
│   └── shared/                # Reusable UI components (buttons, cards, empty states)
├── scripts/                   # Documented offline maintenance, migration & audit tooling
│   ├── audits/                # Data verification scripts and audit reports
│   ├── migrations/            # Data sanitization and price/brand normalization scripts
│   ├── upload/                # Cloud asset uploaders and Cloudinary synchronizers
│   └── scratch/               # Exploratory data inspection utilities
├── test/                      # App-level Automated Test Suite
│   ├── models/                # Unit tests for domain models and JSON serialization
│   ├── core/                  # Theme and secure storage service tests
│   └── widgets/               # Widget tests for UI components and interaction callbacks
├── .env.example               # Safe environment variable template with documentation
├── analysis_options.yaml      # Dart analyzer and linting rules
└── pubspec.yaml               # Flutter package dependencies and asset declarations
```

---

## 📦 Supported Product Workflow

Follow these steps for a reproducible, clean checkout and execution:

### 1. Prerequisites
- **Flutter SDK**: `>=3.2.0 <4.0.0` (Tested on Flutter 3.24+ / 3.47+)
- **Dart SDK**: `^3.2.0`
- **Git**

### 2. Clean Checkout & Environment Setup
Clone the repository and copy the environment template to create a local `.env`:

```bash
# Clone repository
git clone https://github.com/KatkamKoushik/BuildMart.git
cd BuildMart

# Create local environment file from safe template
# Linux / macOS:
cp .env.example .env

# Windows (PowerShell):
Copy-Item .env.example .env
```

> **Clean-Checkout Safety**: The application is configured with graceful runtime fallbacks. If `.env` is omitted, the app will log a notice and continue running using safe defaults rather than crashing on launch.

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Code Generation (Freezed & Riverpod)
When cloning or modifying data models, regenerate Freezed and JSON serialization files:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Static Analysis & Code Quality
Verify code formatting and run the analyzer:
```bash
dart format --output=none --set-exit-if-changed lib/ test/
flutter analyze --no-fatal-infos
```

### 6. Run Automated Test Suite
Execute unit and widget tests:
```bash
flutter test --coverage
```

### 7. Run the Application
```bash
# Run on Chrome (Web)
flutter run -d chrome

# Run on Desktop (Windows / macOS / Linux)
flutter run -d windows

# Run on Mobile (connected device or emulator)
flutter run
```

---

## 🔐 Security & Secrets Management Policy

### Environment Variables (`.env` vs `.env.example`)
*   `.env` is strictly excluded from version control via `.gitignore`.
*   `.env.example` is committed as a reference template containing only public client-side keys and safe placeholders.
*   **Never Bundle Privileged Server Secrets**: Private server keys (such as `RAZORPAY_KEY_SECRET`, database admin passwords, or Cloudinary API secrets) belong exclusively in backend microservices. They must **never** be placed in the mobile `.env` or bundled into client app binaries.

### Firebase Client Configuration (`google-services.json`)
*   `android/app/google-services.json` contains Firebase client configuration values (project number, client IDs, and mobile API keys).
*   **Security Boundary**: Firebase client identifiers are not privileged server credentials. Access security is strictly enforced by:
    1.  **Cloud Firestore Security Rules**: Enforcing user authentication and document ownership checks.
    2.  **Firebase Storage Security Rules**: Restricting file uploads and write permissions to authenticated users.
    3.  **Firebase App Check**: Attesting request authenticity via Play Integrity on Android and DeviceCheck on iOS.
    4.  **Google Cloud API Key Restrictions**: Restricting client API keys to the application's Android package name (`com.buildmart.app`) and SHA-1 signing certificate fingerprint.

---

## 🧪 Continuous Integration (CI)

Every commit and pull request to `main` is automatically validated via GitHub Actions ([`.github/workflows/flutter_ci.yml`](.github/workflows/flutter_ci.yml)):
1.  **Environment Preparation**: Instantiates `.env` from `.env.example` to ensure clean checkout asset bundling.
2.  **Dependency Resolution**: Runs `flutter pub get`.
3.  **Format Verification**: Validates adherence to Dart standard formatting (`dart format`).
4.  **Static Analysis**: Enforces clean analysis without warnings (`flutter analyze`).
5.  **Automated Testing**: Executes the unit and widget test suites with coverage tracking (`flutter test`).
6.  **Release Build Verification**: Validates that a release web artifact compiles without errors (`flutter build web --release`).

---

## 🛠️ Maintenance & Offline Data Scripts

All one-off data cleanup, catalog fixes, image uploaders, and audit log files are organized under [`scripts/`](scripts/README.md). See [`scripts/README.md`](scripts/README.md) for documentation on how to use these utilities for offline catalog curation.
