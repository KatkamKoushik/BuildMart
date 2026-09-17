# BuildMart 🏗️

A premium, production-ready marketplace application for Construction Materials (Cement, Steel, Sand, Bricks, Tiles, Hardware, and Electricals), built with **Flutter**.

## 🚀 Features

*   **Premium UI/UX:** Built with a stunning `Dark/White/Yellow (#FFC107)` theme, utilizing `flutter_animate` for buttery smooth staggered scrolling animations and `carousel_slider` for dynamic top banners.
*   **Complete Dark Mode:** Native, automatic OS-level Dark Mode utilizing Material 3 ColorSchemes.
*   **Advanced Search Engine:** 
    *   **Voice Search:** Speak your query via `speech_to_text`.
    *   **Barcode Scanning:** Instantly find products by scanning their code via `mobile_scanner`.
    *   **Image Recognition:** Snap a photo of a material for AI recommendations via `image_picker`.
*   **Performance First:** 
    *   Skeleton loaders (`ShimmerLoader`) for instant perceived load times.
    *   Infinite Pagination via `ScrollController` on the Products screen.
    *   Offline-first caching via `Hive`.
*   **Core Systems:**
    *   **State Management:** Scalable, reactive state using `flutter_riverpod`.
    *   **Routing:** Type-safe, declarative deep-linkable routing via `go_router` (including full `StatefulShellRoute` bottom navigation).
    *   **API Layer:** `Dio` client configured for the robust clean architecture Repository Pattern.
    *   **Models:** Immutable, JSON-serializable models generated via `freezed`.
    *   **Localization:** Fully configured `flutter_localizations` supporting `.arb` files for multi-language scaling.

## 🛠️ Architecture

BuildMart strictly follows **Clean Architecture** principles to separate concerns, making it highly testable and maintainable for a large enterprise team:

```text
lib/
├── core/         # Core config (Constants, AppColors, AppTheme)
├── features/     # Feature modules (Home, Products, Orders, Profile, Search)
├── models/       # Freezed Data Models
├── navigation/   # go_router configuration
├── services/     # API Client (Dio), Database (Hive)
├── shared/       # Reusable UI Widgets
└── l10n/         # Localization files (.arb)
```

## 📦 Setup & Installation

1. **Clone the repository.**
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Generate Models & Routes (CRITICAL):**
   This project relies on `freezed`, `json_serializable`, and `riverpod_generator`. You must run the build runner to generate the `.freezed.dart`, `.g.dart`, and `.riverpod.dart` files:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Environment Variables:**
   Add your API keys (Razorpay, Google Maps, etc.) to the `.env` file located in the root directory.
5. **Run the App:**
   ```bash
   flutter run
   ```

## 🔐 Permissions
If compiling for physical devices, ensure you have requested the proper OS permissions for Voice, Camera, and Location in your `AndroidManifest.xml` and `Info.plist`.

## 🤝 Contributing
For internal engineers: Please ensure you run `dart format` and execute `flutter analyze` before merging into the main branch. Any changes to data models *must* be followed by a `build_runner` execution.
