# BuildMart CI & Release Readiness Report

This report evaluates the build automation, CI/CD pipeline integrity, Android signing configuration, and deployment readiness for BuildMart.

---

## 1. Continuous Integration Workflows

The repository implements isolated, targeted GitHub Actions CI pipelines:

### 1. Web Application CI ([.github/workflows/ci-web.yml](file:///d:/buildmart/.github/workflows/ci-web.yml))
- Trigger: Push and Pull Request touching `apps/web/**`, `packages/shared/**`, or workspace configuration.
- Environment: Ubuntu Latest, Node.js 22, pnpm 9/12.
- Steps:
  1. Frozen dependency installation (`pnpm install --frozen-lockfile`).
  2. Shared package typechecking (`pnpm --filter @buildmart/shared typecheck`).
  3. Next.js 15 production build (`pnpm --filter web build`).
- Execution Status: Verified passing on GitHub Actions (Pull Request #1 run: 51 seconds).

### 2. Backend API CI ([.github/workflows/ci-api.yml](file:///d:/buildmart/.github/workflows/ci-api.yml))
- Trigger: Push and Pull Request touching `services/api/**`.
- Environment: Ubuntu Latest, Python 3.12.
- Steps:
  1. Dependency installation (`pip install -r services/api/requirements.txt`).
  2. Database seeding (`python -m app.seed`).
  3. Pytest test suite with asyncio (`PYTHONPATH=. python -m pytest -v --tb=short`).
- Execution Status: Verified passing on GitHub Actions (Pull Request #1 run: 35 seconds).

### 3. Mobile CI ([.github/workflows/flutter_ci.yml](file:///d:/buildmart/.github/workflows/flutter_ci.yml))
- Trigger: Push and Pull Request touching `mobile/**`.
- Environment: Ubuntu Latest, Java 17, Flutter Stable.
- Steps:
  1. Setup safe `.env` asset from template.
  2. Dependency resolution (`flutter pub get`).
  3. Formatting verification (`dart format --output=none --set-exit-if-changed lib/ test/`).
  4. Static analysis (`flutter analyze --no-fatal-infos`).
  5. Unit and widget test execution (`flutter test --coverage`).
  6. Debug APK compilation validation (`flutter build apk --debug`).
- Execution Status: Configured and active for mobile changes.

---

## 2. Android Release Signing Readiness (F-03)

### Keystore Configuration
In [mobile/android/app/build.gradle.kts](file:///d:/buildmart/mobile/android/app/build.gradle.kts#L10-L65):
- Release signing configuration is separated from debug signing.
- Keystore credentials are read from `mobile/android/key.properties` (or CI environment variables):
  ```properties
  storePassword=<keystore-password>
  keyPassword=<key-password>
  keyAlias=<key-alias>
  storeFile=<path-to-release.jks>
  ```
- If `key.properties` is absent during local development, the build issues an explicit notice and remains unsigned:
  `NOTICE: key.properties not found. Release build will remain unsigned for CI/safe local build.`
- This prevents unintentional generation or deployment of debug-signed artifacts as production releases.

---

## 3. Container & Infrastructure Readiness

- Container definition: [services/api/Dockerfile](file:///d:/buildmart/services/api/Dockerfile) uses `python:3.12-slim`, non-root execution, and healthcheck endpoints.
- Orchestration: [infra/docker-compose.yml](file:///d:/buildmart/infra/docker-compose.yml) orchestrates PostgreSQL 16 Alpine, Redis 7 Alpine, and the FastAPI application on an isolated internal network (`infra_default`).
- Configuration validation: `docker compose -f infra/docker-compose.yml config` validated with zero warnings or syntax errors.

---

## 4. Release Gates & Verification Blockers

To declare BuildMart production-ready for live end-user deployment, the following external, privileged cloud gates must be completed:

1. Cloudinary Credential Rotation:
   - Action: Generate fresh API Secret in Cloudinary Dashboard and update production container environment variables.
   - Owner: Security Lead / Platform Administrator.
2. Production Razorpay Account Verification:
   - Action: Obtain live production API keys (`rzp_live_...`) and webhook secrets from the Razorpay Merchant Dashboard; configure in production secrets manager.
   - Owner: Finance / Merchant Operations Lead.
3. Firebase Custom Claims & Rules Deployment:
   - Action: Deploy [mobile/firestore.rules](file:///d:/buildmart/mobile/firestore.rules) and [mobile/storage.rules](file:///d:/buildmart/mobile/storage.rules) to the Firebase project via `firebase deploy`.
   - Owner: DevOps / Firebase Administrator.
4. Android Production Keystore Generation:
   - Action: Generate production signing keystore in a protected hardware security module (HSM) or GitHub Actions Secrets and populate `key.properties` during automated release builds.
   - Owner: Mobile Release Engineer.
