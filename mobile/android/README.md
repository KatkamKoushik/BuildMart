# BuildMart Android Build & Release Signing Guide

This document describes the Android build configuration and release signing security controls implemented for BuildMart.

## Security Controls (F-03 Remediation)

1. **Separation of Debug and Release Configurations**:
   - Debug builds use the default Android debug keystore.
   - Release builds require a dedicated release signing configuration specified in `mobile/android/key.properties`.
   - Release builds will not silently fall back to signing with the debug key. If `key.properties` is absent, the build prints an explicit notice and remains unsigned.

2. **Credential Protection**:
   - `key.properties` and `*.jks` keystore files are ignored in `.gitignore`.
   - Release signing credentials are never tracked or logged in source control.

3. **Building Release APK**:
   ```bash
   cd mobile
   flutter build apk --release
   ```

4. **Building Android App Bundle (AAB for Google Play)**:
   ```bash
   cd mobile
   flutter build appbundle --release
   ```
