# BuildMart Remediation Roadmap & Production Release Gates

This roadmap delineates the completed local remediations, external cloud dependencies, security operations, and the sequential pathway toward live production release.

---

## 1. Completed & Verified In-Repository Deliverables

All local code, architecture, security, configuration, and testing remediation tasks have been completed and verified against the actual repository files:

1. Server-Side Payment & Webhook Verification (F-01, F-11):
   - HMAC-SHA256 signature verification.
   - Raw request body webhook verification.
   - WebhookEvent replay deduplication.
   - Order state machine transitions enforced.
2. Server-Side Administrative RBAC (F-02):
   - Dedicated administrative API router ([services/api/app/api/v1/admin.py](file:///d:/buildmart/services/api/app/api/v1/admin.py)).
   - Product CRUD and order management guarded by `require_admin`.
   - Buyers strictly rejected with HTTP 403 Forbidden.
3. Android Release Signing Configuration (F-03):
   - Dynamic loading via `key.properties`.
   - Prevented silent fallback to debug keystore for production builds.
4. CI Pipeline Remediation (F-04):
   - Pinned async database drivers (`greenlet`, `sqlalchemy[asyncio]`).
   - Configured headless runner paths; GitHub Actions runs passing.
5. Firebase Initialization Safety (F-05):
   - Try-catch guarded router initialization in mobile application.
6. Secret Eradication (F-06):
   - Removed hardcoded credentials across 8 legacy scripts.
   - Verified zero exposed secrets remain in tracked files.
7. Razorpay Test vs Live Mode Isolation (F-07):
   - Enforced backend-only storage for payment secrets.
   - Pydantic V2 startup validation blocks mock keys in production.
8. Fail-Fast Configuration Validation (F-08):
   - Production mode startup rejected if `SECRET_KEY` is default or if `DEBUG=True`.
9. Firestore & Storage Default-Deny Policies (F-09):
   - Created [mobile/firestore.rules](file:///d:/buildmart/mobile/firestore.rules) and [mobile/storage.rules](file:///d:/buildmart/mobile/storage.rules).
10. Multi-Tenant Resource Ownership (F-10):
    - Cross-customer order access blocked with HTTP 403 Forbidden.
11. Catalog Data Integrity (F-12):
    - Automated audit script verified 210 products, 16 categories, 18 brands with 0 defects.
12. Server-Authoritative Math (F-13):
    - Item prices fetched strictly from database.
    - 18% GST and tiered delivery rules enforced; negative quantities rejected.
13. Authentication-Aware Routes (F-14):
    - Eliminated anonymous fallback on sensitive endpoints.
14. Comprehensive Test Suite (F-15):
    - 15/15 Pytest tests pass; Next.js 15 production build compiles clean.
15. Accurate Documentation & Feature Parity (F-16):
    - Complete documentation without emojis in README and forensic reports.

---

## 2. External Release Gates (Awaiting Authorization / Cloud Access)

The following actions cannot be performed autonomously because they require privileged external credentials, live financial accounts, or explicit user authorization:

### Gate A: Branch Merging & Push Authorization
- Description: Merging Pull Request #1 into `main` and pushing commits to GitHub.
- Current Status: Blocked per mandatory instruction ("don't merge until i say", "from now until i say, don't push").
- Action Required: Explicit user authorization to merge PR #1: `https://github.com/KatkamKoushik/BuildMart/pull/1`.

### Gate B: Cloudinary API Secret Rotation
- Description: Revocation and rotation of the Cloudinary API secret that was previously present in legacy migration scripts.
- Current Status: Local files cleaned; cloud key rotation pending.
- Action Required: Platform administrator must log into the Cloudinary Console and regenerate the API secret for cloud name `snwiu5gv`.

### Gate C: Firebase Security Rules Deployment
- Description: Deploying declarative security rules to the Firebase project.
- Current Status: Rule files created in [mobile/firestore.rules](file:///d:/buildmart/mobile/firestore.rules) and [mobile/storage.rules](file:///d:/buildmart/mobile/storage.rules).
- Action Required: Run `firebase deploy --only firestore:rules,storage` using authenticated Firebase CLI credentials.

### Gate D: Live Razorpay Merchant Credentials
- Description: Transition from Razorpay test mode (`rzp_test_...`) to live merchant processing.
- Current Status: Test credentials configured with automated HMAC verification; fail-fast production validator active.
- Action Required: Supply live `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, and `RAZORPAY_WEBHOOK_SECRET` in the production host environment.

### Gate E: Production Android Release Keystore
- Description: Generation and secure storage of the production Android `.jks` keystore.
- Current Status: Gradle script configured to load `key.properties`; template created.
- Action Required: Generate the official release keystore and configure GitHub Actions repository secrets for automated release signing.

---

## 3. Recommended Sequential Rollout Steps

```
Step 1: User reviews local forensic report deliverables and test evidence.
Step 2: User provides explicit authorization to merge Pull Request #1 into main.
Step 3: Platform administrator rotates Cloudinary secret in the management console.
Step 4: Firebase administrator deploys firestore.rules and storage.rules via Firebase CLI.
Step 5: Staging environment deployment using infra/docker-compose.yml.
Step 6: Execute end-to-end smoke tests against staging API and web application.
Step 7: Production environment launch with live Razorpay keys and production SECRET_KEY.
```
