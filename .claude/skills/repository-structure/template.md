# Repository Structure Document

## Project Structure

```
project-root/
├── src/                   # Source code
│   ├── [layer1]/          # [Description]
│   ├── [layer2]/          # [Description]
│   └── [layer3]/          # [Description]
├── tests/                 # Test code
│   ├── unit/              # Unit tests
│   ├── integration/       # Integration tests
│   └── e2e/               # E2E tests
├── docs/                  # Project documentation
├── config/                # Configuration files
└── scripts/               # Build and deploy scripts
```

## Directory Details

### src/ (source code directory)

#### [Directory 1]

**Role**: [Description]

**Files placed here**:
- [File pattern 1]: [Description]
- [File pattern 2]: [Description]

**Naming conventions**:
- [Rule 1]
- [Rule 2]

**Dependencies**:
- May depend on: [Directory name]
- Must not depend on: [Directory name]

**Example**:
```
[directory-name]/
├── [example-file1].ts
└── [example-file2].ts
```

#### [Directory 2]

**Role**: [Description]

**Files placed here**:
- [File pattern 1]: [Description]

**Naming conventions**:
- [Rule 1]

**Dependencies**:
- May depend on: [Directory name]
- Must not depend on: [Directory name]

### tests/ (test directory)

#### unit/

**Role**: Location for unit tests

**Structure**:
```
tests/unit/
└── src/                    # Same structure as the src directory
    └── [layer]/
        └── [filename].test.ts
```

**Naming conventions**:
- Pattern: `[name of file under test].test.ts`
- Example: `TaskService.ts` → `TaskService.test.ts`

#### integration/

**Role**: Location for integration tests

**Structure**:
```
tests/integration/
└── [feature]/              # Directories split per feature
    └── [scenario].test.ts
```

#### e2e/

**Role**: Location for E2E tests

**Structure**:
```
tests/e2e/
└── [user-scenario]/        # Per user scenario
    └── [flow].test.ts
```

### docs/ (documentation directory)

**Documents placed here**:
- `product-requirements.md`: Product requirements document
- `functional-design.md`: Functional design document
- `architecture.md`: Architecture design document
- `repository-structure.md`: Repository structure document (this document)
- `development-guidelines.md`: Development guidelines
- `glossary.md`: Glossary

### config/ (configuration directory - if applicable)

**Files placed here**:
- Configuration files
- Constant definition files

**Example**:
```
config/
├── default.ts
└── constants.ts
```

### scripts/ (scripts directory - if applicable)

**Files placed here**:
- Build scripts
- Development helper scripts

## File Placement Rules

### Source files

| File type | Location | Naming convention | Example |
|------------|--------|---------|-----|
| [Type 1] | [Directory] | [Rule] | [Example] |
| [Type 2] | [Directory] | [Rule] | [Example] |

### Test files

| Test type | Location | Naming convention | Example |
|-----------|--------|---------|-----|
| Unit test | tests/unit/ | [target].test.ts | TaskService.test.ts |
| Integration test | tests/integration/ | [feature].test.ts | task-crud.test.ts |
| E2E test | tests/e2e/ | [scenario].test.ts | user-workflow.test.ts |

### Configuration files

| File type | Location | Naming convention |
|------------|--------|---------|
| Environment config | config/environments/ | [environment-name].ts |
| Tool config | Project root | [tool-name].config.js |
| Type definitions | src/types/ | [target].d.ts |

## Naming Conventions

### Directory names

- **Layer directories**: plural, kebab-case
  - Examples: `services/`, `repositories/`, `controllers/`
- **Feature directories**: singular, kebab-case
  - Examples: `task-management/`, `user-authentication/`

### File names

- **Class files**: PascalCase
  - Examples: `TaskService.ts`, `UserRepository.ts`
- **Function files**: camelCase
  - Examples: `formatDate.ts`, `validateEmail.ts`
- **Constant files**: UPPER_SNAKE_CASE
  - Examples: `API_ENDPOINTS.ts`, `ERROR_MESSAGES.ts`

### Test file names

- Pattern: `[target under test].test.ts` or `[target under test].spec.ts`
- Examples: `TaskService.test.ts`, `formatDate.spec.ts`

## Dependency Rules

### Dependencies between layers

```
UI layer
    ↓ (OK)
Service layer
    ↓ (OK)
Data layer
```

**Forbidden dependencies**:
- Data layer → Service layer (❌)
- Data layer → UI layer (❌)
- Service layer → UI layer (❌)

### Dependencies between modules

**Circular dependencies are forbidden**:
```typescript
// ❌ Bad example: circular dependency
// fileA.ts
import { funcB } from './fileB';

// fileB.ts
import { funcA } from './fileA';  // Circular dependency
```

**Solution**:
```typescript
// ✅ Good example: extract a shared module
// shared.ts
export interface SharedType { /* ... */ }

// fileA.ts
import { SharedType } from './shared';

// fileB.ts
import { SharedType } from './shared';
```

## Scaling Strategy

### Adding features

Placement policy when adding a new feature:

1. **Small feature**: Place in an existing directory
2. **Medium feature**: Create a subdirectory within the layer
3. **Large feature**: Split out as an independent module

**Example**:
```
src/
├── services/
│   ├── TaskService.ts           # Existing feature
│   └── task-management/         # Medium feature split out
│       ├── TaskService.ts
│       ├── SubtaskService.ts
│       └── TaskCategoryService.ts
```

### Managing file size

**File splitting guidelines**:
- Per file: 300 lines or fewer recommended
- 300-500 lines: consider refactoring
- 500+ lines: splitting strongly recommended

**How to split**:
```typescript
// Bad example: all functionality in one file
// TaskService.ts (800 lines)

// Good example: split by responsibility
// TaskService.ts (200 lines) - CRUD operations
// TaskValidationService.ts (150 lines) - Validation
// TaskNotificationService.ts (100 lines) - Notification handling
```

## Special Directories

### .steering/ (steering files)

**Role**: Defines "what to do this time" for a specific piece of development work

**Structure**:
```
.steering/
└── [YYYYMMDD]-[task-name]/
    ├── requirements.md      # Requirements for this piece of work
    ├── design.md            # Design of the changes
    └── tasklist.md          # Task list
```

**Naming convention**: `20250115-add-user-profile` format

### .claude/ (Claude Code configuration)

**Role**: Claude Code configuration and customization

**Structure**:
```
.claude/
├── commands/                # Slash commands
├── skills/                  # Skills per task mode
└── agents/                  # Subagent definitions
```

## Exclusion Settings

### .gitignore

Files the project should exclude:
- `node_modules/`
- `dist/`
- `.env`
- `.steering/` (temporary files for task management)
- `*.log`
- `.DS_Store`

### .prettierignore, .eslintignore

Files tools should exclude:
- `dist/`
- `node_modules/`
- `.steering/`
- `coverage/`
