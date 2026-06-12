# Repository Structure Document Creation Guide

## Basic Principles

### 1. Clear roles

Each directory should have a single, clear role.

**Bad example**:
```
src/
├── stuff/           # Vague
├── misc/            # Miscellaneous
└── utils/           # Too generic
```

**Good example**:
```
src/
├── commands/        # CLI command implementations
├── services/        # Business logic
├── repositories/    # Data persistence
└── validators/      # Input validation
```

### 2. Strict layer separation

Reflect the architecture's layer structure in the directory structure:

```
src/
├── ui/              # UI layer
│   └── cli/         # CLI implementation
├── services/        # Service layer
│   └── task/        # Task management service
└── repositories/    # Data layer
    └── task/        # Task repository
```

### 3. Splitting by technical concern (default)

Split directories by related technical concern:

**Basic structure**:
```
src/
├── commands/        # CLI commands
├── services/        # Business logic
├── repositories/    # Data persistence
└── types/           # Type definitions
```

**Mapping to the layer structure**:
```
CLI/UI layer       → commands/, cli/
Service layer      → services/
Data layer         → repositories/, storage/
```

## Designing the Directory Structure

### Expressing the layer structure

```typescript
// Bad example: flat structure
src/
├── TaskCLI.ts
├── TaskService.ts
├── TaskRepository.ts
├── UserCLI.ts
├── UserService.ts
└── UserRepository.ts

// Good example: layers made explicit
src/
├── cli/
│   ├── TaskCLI.ts
│   └── UserCLI.ts
├── services/
│   ├── TaskService.ts
│   └── UserService.ts
└── repositories/
    ├── TaskRepository.ts
    └── UserRepository.ts
```

### Test directory placement

**Recommended structure**:
```
project/
├── src/
│   └── services/
│       └── TaskService.ts
└── tests/
    ├── unit/
    │   └── services/
    │       └── TaskService.test.ts
    ├── integration/
    └── e2e/
```

**Reasons**:
- Test code is separated from production code
- Easy to exclude tests from the build
- Can be organized by test type

## Naming Convention Best Practices

### Directory name principles

**1. Use plural forms (layer directories)**
```
✅ services/
✅ repositories/
✅ controllers/

❌ service/
❌ repository/
❌ controller/
```

Reason: They contain multiple files

**2. Use kebab-case**
```
✅ task-management/
✅ user-authentication/

❌ TaskManagement/
❌ userAuthentication/
```

Reason: Compatibility with URLs and file systems

**3. Use specific names**
```
✅ validators/       # Input validation
✅ formatters/       # Data formatting
✅ parsers/          # Data parsing

❌ utils/            # Too generic
❌ helpers/          # Vague
❌ common/           # Meaningless
```

### File name principles

**1. Class files: PascalCase + role suffix**
```typescript
// Service classes
TaskService.ts
UserAuthenticationService.ts

// Repository classes
TaskRepository.ts
UserRepository.ts

// Controller classes
TaskController.ts
```

**2. Function files: camelCase, starting with a verb**
```typescript
// Utility functions
formatDate.ts
validateEmail.ts
parseCommandArguments.ts
```

**3. Type definition files: PascalCase or kebab-case**
```typescript
// Interface definitions
Task.ts
UserProfile.ts

// Type definition collections
task-types.d.ts
api-types.d.ts
```

**4. Constant files: UPPER_SNAKE_CASE or kebab-case**
```typescript
// Constant definitions
API_ENDPOINTS.ts
ERROR_MESSAGES.ts

// or
api-endpoints.ts
error-messages.ts
```

## Dependency Management

### Dependency rules between layers

```typescript
// ✅ Good example: upper layer depends on lower layer
// cli/TaskCLI.ts
import { TaskService } from '../services/TaskService';

class TaskCLI {
  constructor(private taskService: TaskService) {}
}

// ❌ Bad example: lower layer depends on upper layer
// services/TaskService.ts
import { TaskCLI } from '../cli/TaskCLI';  // Forbidden!
```

### Avoiding circular dependencies

**Problematic code**:
```typescript
// services/TaskService.ts
import { UserService } from './UserService';

export class TaskService {
  constructor(private userService: UserService) {}
}

// services/UserService.ts
import { TaskService } from './TaskService';  // Circular dependency!

export class UserService {
  constructor(private taskService: TaskService) {}
}
```

**Solution 1: Extract shared type definitions**
```typescript
// types/Service.ts
export interface ITaskService { /* ... */ }
export interface IUserService { /* ... */ }

// services/TaskService.ts
import type { IUserService } from '../types/Service';

export class TaskService {
  constructor(private userService: IUserService) {}
}

// services/UserService.ts
import type { ITaskService } from '../types/Service';

export class UserService {
  constructor(private taskService: ITaskService) {}
}
```

**Solution 2: Rethink the dependencies**
```typescript
// Extract shared functionality into a separate service
// services/NotificationService.ts
export class NotificationService {
  notifyTaskAssignment(taskId: string, userId: string): void {
    // Notification logic
  }
}

// services/TaskService.ts
import { NotificationService } from './NotificationService';

export class TaskService {
  constructor(private notificationService: NotificationService) {}
}

// services/UserService.ts
import { NotificationService } from './NotificationService';

export class UserService {
  constructor(private notificationService: NotificationService) {}
}
```

## Scaling Strategy

### Recommended structure

**Standard pattern**:
```
src/
├── commands/
│   └── TaskCommand.ts
├── services/
│   ├── TaskService.ts
│   └── UserService.ts
├── repositories/
│   ├── TaskRepository.ts
│   └── UserRepository.ts
├── types/
│   ├── Task.ts
│   └── User.ts
├── validators/
│   └── TaskValidator.ts
└── index.ts
```

**Reasons**:
- Responsibilities are clear per layer
- No refactoring needed later
- Easy to standardize across a team

### When to split into modules

**Signs that a split should be considered**:
1. A directory contains 10 or more files
2. Related features form a cohesive group
3. They can be tested independently
4. They have few dependencies on other features

**Splitting procedure**:
```typescript
// Before: everything placed in services/
services/
├── TaskService.ts
├── TaskValidationService.ts
├── TaskNotificationService.ts
├── UserService.ts
└── UserAuthService.ts

// After: modularized by feature
modules/
├── task/
│   ├── TaskService.ts
│   ├── TaskValidationService.ts
│   └── TaskNotificationService.ts
└── user/
    ├── UserService.ts
    └── UserAuthService.ts
```

## Handling Special Cases

### Placement of shared code

**shared/ or common/ directory**
```
src/
├── shared/
│   ├── utils/           # Generic utilities
│   ├── types/           # Shared type definitions
│   └── constants/       # Shared constants
├── commands/
├── services/
└── repositories/
```

**Rules**:
- Only things genuinely used by multiple layers
- Do not include anything used by only a single layer

### Managing configuration files (if applicable)

```
config/
├── default.ts           # Default configuration
└── constants.ts         # Constant definitions
```

### Managing scripts (if applicable)

```
scripts/
├── build.sh             # Build script
└── dev-tools.ts         # Development helper script
```

## Document Placement

### Document types and locations

**Project root**:
- `README.md`: Project overview
- `CONTRIBUTING.md`: Contribution guide
- `LICENSE`: License

**docs/ directory**:
- `product-requirements.md`: PRD
- `functional-design.md`: Functional design document
- `architecture.md`: Architecture design document
- `repository-structure.md`: This document
- `development-guidelines.md`: Development guidelines
- `glossary.md`: Glossary

**Within source code**:
- TSDoc/JSDoc comments: Descriptions of functions and classes

## Checklist

- [ ] The role of each directory is clearly defined
- [ ] The layer structure is reflected in the directories
- [ ] Naming conventions are consistent
- [ ] The placement policy for test code is decided
- [ ] Dependency rules are clear
- [ ] There are no circular dependencies
- [ ] The scaling strategy has been considered
- [ ] Placement rules for shared code are defined
- [ ] The management approach for configuration files is decided
- [ ] Document locations are clear
