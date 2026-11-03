# ADR 0002: Monorepo Orchestration via pnpm Workspaces and Turborepo

## Status
Accepted

## Date
2026-11-03

## Context
BuildMart encompasses multiple distinct applications and shared packages:
- `apps/web`: Next.js 15 SSR/SSG client web application.
- `mobile`: Flutter cross-platform mobile application.
- `packages/shared`: Shared TypeScript domain models, Zod validation schemas, and constants.
- `services/api`: Python FastAPI asynchronous backend microservice.
- `infra`: Docker Compose infrastructure definitions.

Managing isolated repositories creates severe coordination bottlenecks: shared schema drift between web frontend and backend schemas, duplicated type definitions, uncoordinated release cycles, and redundant CI test executions.

## Decision
We organize the codebase as a unified Monorepo managed through `pnpm` (v12) workspaces and orchestrated by `turborepo` (v2):
1. **Workspace Layout**:
   - `packages/*`: Reusable shared packages (`packages/shared`).
   - `apps/*`: Application frontends (`apps/web`).
   - `services/*`: Microservices (`services/api`).
2. **Build and Pipeline Orchestration**:
   - `turbo.json` defines task dependency graphs (`build`, `test`, `lint`, `typecheck`).
   - Pipeline tasks utilize Turborepo's local and distributed hashing cache to skip execution of unchanged targets.
3. **Strict Dependency Pinned Declarations**:
   - Enforce `pnpm-lock.yaml` across JavaScript and TypeScript packages.
   - Pinned `requirements.lock` for Python services.

## Invariants and Guardrails
- **Shared Schema Authority**: `packages/shared` provides the authoritative TypeScript Zod definitions for checkout, cart items, user profiles, and quotes. Frontends must import schemas directly from `@buildmart/shared` rather than maintaining duplicate type declarations.
- **Node Runtime Baseline**: Workflows and local engines standardize on Node.js 24 LTS runtime (`engine: ">=20.0.0"`).
- **Hermetic Task Caching**: Turborepo task inputs and outputs must be explicitly declared in `turbo.json` to prevent poisoned cache hits.

## Alternatives Considered
- **Polyrepo (Multi-Repository Strategy)**: High operational overhead, requirement for private npm registries, and inevitable schema drift during rapid procurement workflow iterations.
- **Lerna / Nx**: Nx adds complex plugins and heavy abstractions unnecessary for our lightweight polyglot setup; Lerna has lagged in native workspace orchestration compared to Turborepo.
- **npm / yarn**: Slower installation benchmarks, lack of hard symlink disk deduplication compared to pnpm's content-addressable storage.

## Consequences
- **Positive**:
  - Zero-drift shared validation schemas between web frontend and backend contracts.
  - Sub-second cached builds and selective CI execution via `turbo run build test`.
  - Single pull request atomicity for cross-cutting schema changes.
- **Negative**:
  - Polyglot monorepo requires CI to support both Node.js, Python, and Dart/Flutter toolchains.
  - Developers need familiarity with workspace filters (`pnpm --filter <pkg>`).

## References
- Monorepo Configuration: [pnpm-workspace.yaml](../../pnpm-workspace.yaml)
- Pipeline Graph: [turbo.json](../../turbo.json)
- Shared Schema Definitions: [packages/shared/src/schemas.ts](../../packages/shared/src/schemas.ts)
- Root Manifest: [package.json](../../package.json)
