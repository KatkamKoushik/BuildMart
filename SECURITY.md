# Security Policy

## Supported Versions

The BuildMart engineering team actively provides security updates and vulnerability patches for the following releases:

| Version | Supported | Minimum Runtime Requirement |
| :--- | :---: | :--- |
| `2.0.x` | Yes | Python 3.12, Node.js 20+, Flutter 3.x |
| `< 2.0.0` | No | Legacy Flutter Web / Deprecated Prototype |

---

## Reporting a Vulnerability

If you discover a potential security vulnerability within the BuildMart codebase or associated infrastructure, please report it responsibly:

1. **Email Notification**: Send a detailed vulnerability report to `security@buildmart.com` or contact `koushikkatkam@gmail.com`.
2. **Details to Include**:
   - Description of the vulnerability and attack vector.
   - Exact steps or minimal proof-of-concept to reproduce the issue.
   - Affected service, package, endpoint, or configuration file.
   - Proposed remediation or defensive mitigation, if available.
3. **Response Timeline**:
   - Initial acknowledgement within 24 hours.
   - Severity classification and remediation timeline within 72 hours.
   - Public patch release and advisory disclosure upon validation.

Please do not open public GitHub issues or disclose vulnerabilities publicly until a patch has been authored, tested, and deployed.

---

## Security Invariants and Baseline Standards

The platform enforces the following core security invariants:

1. **Zero Untracked Secrets**: Production credentials, cryptographic signing keys, and payment gateway secrets must never be committed to Git. All secrets are injected exclusively via environment variables or secure vault stores.
2. **Server-Authoritative Transactions**: Client applications are never trusted for item prices, inventory validation, statutory GST tax amounts, or payment status mutations.
3. **Cryptographic Validation**: Payment confirmations require constant-time HMAC-SHA256 signature verification matching backend secrets.
4. **Least Privilege Enforcement**: Public user registrations are unconditionally assigned the `buyer` role. Elevated roles require verified administrative authorization.

