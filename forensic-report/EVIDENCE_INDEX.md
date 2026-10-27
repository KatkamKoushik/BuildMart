# BuildMart Remediation Evidence & File Index

This document provides direct links to source code, tests, configuration files, and audit logs validating the remediation of findings F-01 through F-16 and checklist controls.

---

## 1. Security & Authorization Evidence (F-01, F-02, F-07, F-08, F-10, F-14)

- JWT Authentication & RBAC Dependencies:
  - File: [services/api/app/core/security.py](file:///d:/buildmart/services/api/app/core/security.py)
  - Key functions:
    - `create_access_token`: [security.py:L25-L35](file:///d:/buildmart/services/api/app/core/security.py#L25-L35)
    - `decode_access_token`: [security.py:L37-L55](file:///d:/buildmart/services/api/app/core/security.py#L37-L55)
    - `require_authenticated_user`: [security.py:L125-L138](file:///d:/buildmart/services/api/app/core/security.py#L125-L138)
    - `require_role` & `require_admin`: [security.py:L140-L165](file:///d:/buildmart/services/api/app/core/security.py#L140-L165)
- Administrative Router with Strict RBAC Guards:
  - File: [services/api/app/api/v1/admin.py](file:///d:/buildmart/services/api/app/api/v1/admin.py)
  - Key routes:
    - `get_admin_metrics`: [admin.py:L18-L35](file:///d:/buildmart/services/api/app/api/v1/admin.py#L18-L35)
    - `create_product_admin`: [admin.py:L55-L95](file:///d:/buildmart/services/api/app/api/v1/admin.py#L55-L95)
    - `delete_product_admin`: [admin.py:L115-L130](file:///d:/buildmart/services/api/app/api/v1/admin.py#L115-L130)
- Fail-Fast Environment Configuration Validator:
  - File: [services/api/app/core/config.py](file:///d:/buildmart/services/api/app/core/config.py)
  - Pydantic V2 validator: [config.py:L38-L58](file:///d:/buildmart/services/api/app/core/config.py#L38-L58)
- Resource Ownership Enforcement:
  - File: [services/api/app/api/v1/orders.py](file:///d:/buildmart/services/api/app/api/v1/orders.py)
  - Key check: [orders.py:L160-L180](file:///d:/buildmart/services/api/app/api/v1/orders.py#L160-L180) (rejects cross-customer order retrieval with HTTP 403)
- Firebase Security Policies:
  - Firestore Default-Deny Rules: [mobile/firestore.rules](file:///d:/buildmart/mobile/firestore.rules)
  - Storage Default-Deny Rules: [mobile/storage.rules](file:///d:/buildmart/mobile/storage.rules)

---

## 2. Payment & Financial Integrity Evidence (F-01, F-11, F-13)

- Server-Side Razorpay Order Creation & HMAC Verification:
  - File: [services/api/app/api/v1/checkout.py](file:///d:/buildmart/services/api/app/api/v1/checkout.py)
  - Key functions:
    - `create_razorpay_order`: [checkout.py:L17-L55](file:///d:/buildmart/services/api/app/api/v1/checkout.py#L17-L55)
    - `verify_razorpay_payment`: [checkout.py:L57-L115](file:///d:/buildmart/services/api/app/api/v1/checkout.py#L57-L115)
    - `razorpay_webhook` (raw-body verification & deduplication): [checkout.py:L117-L180](file:///d:/buildmart/services/api/app/api/v1/checkout.py#L117-L180)
- Server-Authoritative Math & Positive Quantity Validation:
  - File: [services/api/app/api/v1/orders.py](file:///d:/buildmart/services/api/app/api/v1/orders.py)
  - Positive integer validation: [orders.py:L50-L75](file:///d:/buildmart/services/api/app/api/v1/orders.py#L50-L75)
  - 18% GST and delivery calculation: [orders.py:L90-L115](file:///d:/buildmart/services/api/app/api/v1/orders.py#L90-L115)
- Order Lifecycle State Machine:
  - File: [services/api/app/api/v1/orders.py](file:///d:/buildmart/services/api/app/api/v1/orders.py)
  - Transition map: [orders.py:L20-L28](file:///d:/buildmart/services/api/app/api/v1/orders.py#L20-L28)
  - Order status endpoint: [orders.py:L225-L255](file:///d:/buildmart/services/api/app/api/v1/orders.py#L225-L255)

---

## 3. Credential Hygiene Evidence (F-06)

- Hardcoded Credentials Eradicated:
  - [scripts/audits/audit.py](file:///d:/buildmart/scripts/audits/audit.py#L6-L10)
  - [scripts/audits/find_extra_images.py](file:///d:/buildmart/scripts/audits/find_extra_images.py#L5-L10)
  - [scripts/migrations/fix_berger_upload_asian.py](file:///d:/buildmart/scripts/migrations/fix_berger_upload_asian.py#L7-L12)
  - [scripts/migrations/fix_data.py](file:///d:/buildmart/scripts/migrations/fix_data.py#L7-L12)
  - [scripts/migrations/restore_missing_products.py](file:///d:/buildmart/scripts/migrations/restore_missing_products.py#L7-L12)
  - [scripts/upload/fetch_cloudinary.py](file:///d:/buildmart/scripts/upload/fetch_cloudinary.py#L4-L9)
  - [scripts/upload/upload_new_folders.py](file:///d:/buildmart/scripts/upload/upload_new_folders.py#L7-L12)
  - [scripts/upload/upload_products.py](file:///d:/buildmart/scripts/upload/upload_products.py#L7-L12)

---

## 4. Mobile & Android Release Signing Evidence (F-03, F-05)

- Gradle Dynamic Keystore Loading & Notice:
  - File: [mobile/android/app/build.gradle.kts](file:///d:/buildmart/mobile/android/app/build.gradle.kts#L10-L60)
- Keystore Configuration Template:
  - File: [mobile/android/key.properties.example](file:///d:/buildmart/mobile/android/key.properties.example)
- Android Signing Guide:
  - File: [mobile/android/README.md](file:///d:/buildmart/mobile/android/README.md)
- Flutter App Router Safe Initialization & Admin Route Guard:
  - File: [mobile/lib/navigation/app_router.dart](file:///d:/buildmart/mobile/lib/navigation/app_router.dart#L50-L75)

---

## 5. Catalog Audit & Seed Integrity Evidence (F-12)

- Automated Audit Execution Script:
  - File: [scripts/audits/catalog_integrity_audit.py](file:///d:/buildmart/scripts/audits/catalog_integrity_audit.py)
- Machine-Readable Audit Report:
  - File: [scripts/audits/catalog_audit_report.json](file:///d:/buildmart/scripts/audits/catalog_audit_report.json)
- Seed Pipeline Implementation:
  - File: [services/api/app/seed.py](file:///d:/buildmart/services/api/app/seed.py#L20-L60)
- Seed Source Dataset:
  - File: [mobile/assets/seeded_data.json](file:///d:/buildmart/mobile/assets/seeded_data.json)

---

## 6. Automated Test Suites & CI Pipelines (F-04, F-15)

- Security, RBAC, Payment & Lifecycle Test Suite:
  - File: [services/api/tests/test_security_and_lifecycle.py](file:///d:/buildmart/services/api/tests/test_security_and_lifecycle.py)
- API Integration Test Suite:
  - File: [services/api/tests/test_api.py](file:///d:/buildmart/services/api/tests/test_api.py)
- Test Database Configuration Fixtures:
  - File: [services/api/tests/conftest.py](file:///d:/buildmart/services/api/tests/conftest.py)
- Web Application CI Workflow:
  - File: [.github/workflows/ci-web.yml](file:///d:/buildmart/.github/workflows/ci-web.yml)
- Backend API CI Workflow:
  - File: [.github/workflows/ci-api.yml](file:///d:/buildmart/.github/workflows/ci-api.yml)
- Mobile App CI Workflow:
  - File: [.github/workflows/flutter_ci.yml](file:///d:/buildmart/.github/workflows/flutter_ci.yml)
- Docker Compose Infrastructure:
  - File: [infra/docker-compose.yml](file:///d:/buildmart/infra/docker-compose.yml)
