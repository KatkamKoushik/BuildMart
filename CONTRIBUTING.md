# Contributing to BuildMart

Thank you for your interest in contributing to the BuildMart digital procurement and supply chain infrastructure platform.

This guide outlines our development workflow, engineering standards, testing criteria, and pull request procedures.

---

## Code of Conduct and Engineering Standards

Contributors must uphold high engineering rigor and adhere to these tenets:
- **Clean Architecture & SOLID Principles**: Decouple domain logic from UI presentation and database persistence.
- **Type Safety**: Maintain strict static typing across Python (Pydantic v2), TypeScript (TypeScript 5.8 + Zod), and Dart (Freezed).
- **Zero Untracked Secrets**: Never commit real API keys, private certificates, or credential configurations.
- **Documentation Precision**: Maintain accurate technical documentation and architectural diagrams matching code reality.

---

## Monorepo Development Environment

BuildMart is orchestrated as a pnpm workspace with Turborepo:

### Prerequisites
- Node.js >= 20.0.0 (CI standardizes on Node 24)
- pnpm 12.4.2 (`npm install -g pnpm@12.4.2`)
- Python >= 3.12 with pip
- Flutter SDK >= 3.x (for mobile application development)
- Docker Desktop or Docker Engine with Docker Compose

### Initial Setup
```bash
# 1. Clone repository
git clone https://github.com/KatkamKoushik/BuildMart.git
cd buildmart

# 2. Configure environment
cp .env.example .env

# 3. Install dependencies
pnpm install

# 4. Initialize backend database and run migrations
cd services/api
pip install -r requirements.txt
alembic upgrade head
python -m app.seed
cd ../..
```

---

## Development Workflow and Testing

Run concurrent services using Turborepo:
```bash
# Launch Next.js web application and FastAPI backend
pnpm dev

# Execute full monorepo test suite
pnpm test

# Typecheck all packages
pnpm typecheck
```

Before submitting a pull request, verify each individual subsystem:
1. **Shared Domain Package**:
   ```bash
   pnpm --filter @buildmart/shared typecheck
   pnpm --filter @buildmart/shared test
   ```
2. **Web Frontend**:
   ```bash
   pnpm --filter @buildmart/web typecheck
   pnpm --filter @buildmart/web test
   pnpm --filter @buildmart/web build
   ```
3. **Backend API**:
   ```bash
   cd services/api
   pytest -v
   cd ../..
   ```
4. **Mobile Client**:
   ```bash
   cd mobile
   dart format --output=none --set-exit-if-changed .
   flutter analyze --no-fatal-infos
   flutter test --coverage
   cd ..
   ```

---

## Commit Guidelines and Pull Requests

1. **Conventional Commits**: Format commit titles using standard prefixes:
   - `feat(...)`: New product capability or significant enhancement.
   - `fix(...)`: Bug fix or security remediation.
   - `docs(...)`: Documentation, Wiki, or README revisions.
   - `ci(...)`: GitHub Actions workflow or pipeline adjustments.
   - `refactor(...)`: Code restructuring without behavioral mutation.
2. **Commit Signing**: Cryptographically sign commits using SSH or GPG where possible.
3. **Branch Hygiene**: Work on dedicated feature branches (`feat/...` or `fix/...`). Rebase against `main` before opening pull requests.

