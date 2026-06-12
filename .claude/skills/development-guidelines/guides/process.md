# Process Guide

## Basic Principles

### 1. Include plenty of concrete examples

Present concrete code examples, not just abstract rules.

**Bad example**:
```
Variable names should be easy to understand
```

**Good example**:
```typescript
// ✅ Good example: roles are clear
const userAuthentication = new UserAuthenticationService();
const taskRepository = new TaskRepository();

// ❌ Bad example: vague
const auth = new Service();
const repo = new Repository();
```

### 2. Explain the reasons

Make the "why" explicit.

**Example**:
```
## Do not ignore errors

Reason: Ignoring errors makes it difficult to determine the root cause of problems.
Handle expected errors appropriately, and propagate unexpected errors upward
so they can be logged.
```

### 3. Set measurable criteria

Avoid vague wording; provide concrete numbers.

**Bad example**:
```
Keep code coverage high
```

**Good example**:
```
Code coverage targets:
- Unit tests: 80% or higher
- Integration tests: 60% or higher
- E2E tests: 100% of critical flows
```

## Git Workflow Rules

### Branching Strategy (Git Flow)

**What is Git Flow**:
A branching model proposed by Vincent Driessen for systematically managing feature development, releases, and hotfixes. Clear role separation enables parallel work in team development and stable releases.

**Branch layout**:
```
main (production)
└── develop (development/integration)
    ├── feature/* (new feature development)
    ├── fix/* (bug fixes)
    └── release/* (release preparation) *as needed
```

**Operating rules**:
- **main**: Holds only stable code released to production. Versions are managed with tags
- **develop**: Integrates the latest development code for the next release. Automated tests run in CI
- **feature/\*, fix/\***: Branch from develop; after work is complete, merge into develop via PR
- **No direct commits**: Require PR review on all branches to ensure code quality
- **Merge policy**: feature→develop uses squash merge; develop→main uses a merge commit (recommended)

**Benefits of Git Flow**:
- Branch roles are clear, making parallel development by multiple people easier
- The production environment (main) is always kept clean
- Emergencies can be handled quickly with hotfix branches (introduce as needed)

### Commit Message Conventions

**Conventional Commits is recommended**:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type list**:
```
feat: new feature (minor version up)
fix: bug fix (patch version up)
docs: documentation
style: formatting (no effect on code behavior)
refactor: refactoring
perf: performance improvement
test: adding or fixing tests
build: build system
ci: CI/CD configuration
chore: other (dependency updates, etc.)

BREAKING CHANGE: breaking change (major version up)
```

**Example of a good commit message**:

```
feat(task): Add priority setting feature

Users can now set a priority (high/medium/low) on tasks.

Changes:
- Added a priority field to the Task model
- Added a --priority option to the CLI
- Implemented sorting by priority

Breaking changes:
- The structure of the Task type has changed
- Existing task data requires a migration

Closes #123
BREAKING CHANGE: Added a required priority field to the Task type
```

### Pull Request Template

**Effective PR template**:

```markdown
## Type of Change
- [ ] New feature (feat)
- [ ] Bug fix (fix)
- [ ] Refactoring (refactor)
- [ ] Documentation (docs)
- [ ] Other (chore)

## Changes
### What was changed
[brief description]

### Why it was changed
[background/reason]

### How it was changed
- [change 1]
- [change 2]

## Tests
### Tests performed
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] Manual testing performed

### Test results
[description of test results]

## Related Issues
Closes #[number]
Refs #[number]

## Review Points
[areas you especially want reviewers to look at]
```

## Test Strategy

### Test Pyramid

```
       /\
      /E2E\       few (slow, expensive)
     /------\
    /  Integ \     some
   /----------\
  /   Unit     \   many (fast, cheap)
 /--------------\
```

**Target ratio**:
- Unit tests: 70%
- Integration tests: 20%
- E2E tests: 10%

### How to Write Tests

**Given-When-Then pattern**:

```typescript
describe('TaskService', () => {
  describe('task creation', () => {
    it('creates a task with valid data', async () => {
      // Given: setup
      const service = new TaskService(mockRepository);
      const validData = { title: 'Test' };

      // When: execute
      const result = await service.create(validData);

      // Then: verify
      expect(result.id).toBeDefined();
      expect(result.title).toBe('Test');
    });

    it('throws ValidationError when title is empty', async () => {
      // Given: setup
      const service = new TaskService(mockRepository);
      const invalidData = { title: '' };

      // When/Then: execute and verify
      await expect(
        service.create(invalidData)
      ).rejects.toThrow(ValidationError);
    });
  });
});
```

### Coverage Targets

**Measurable goals**:

```json
// jest.config.js
{
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    },
    "./src/services/": {
      "branches": 90,
      "functions": 90,
      "lines": 90,
      "statements": 90
    }
  }
}
```

**Reasons**:
- Critical business logic (services/) requires higher coverage
- Lower coverage is acceptable for the UI layer
- Do not aim for 100% (balance cost against benefit)

## Code Review Process

### Purpose of Review

1. **Quality assurance**: catch bugs early
2. **Knowledge sharing**: the whole team understands the codebase
3. **Learning opportunity**: share best practices

### Keys to Effective Review

**For reviewers**:

1. **Constructive feedback**
```markdown
## ❌ Bad example
This code is bad.

## ✅ Good example
This implementation has O(n²) time complexity.
Using a Map improves it to O(n):

```typescript
const taskMap = new Map(tasks.map(t => [t.id, t]));
const result = ids.map(id => taskMap.get(id));
```
```

2. **Explicit priorities**
```markdown
[required] Security: a password is being written to the logs
[recommended] Performance: avoid DB calls inside a loop
[suggestion] Readability: could this function name be clearer?
[question] Could you explain the intent of this logic?
```

3. **Positive feedback too**
```markdown
✨ This implementation is easy to follow!
👍 Edge cases are well covered
💡 This pattern could be useful elsewhere
```

**For reviewees**:

1. **Perform a self-review**
   - Review your own code before creating the PR
   - Add comments where explanation is needed

2. **Keep PRs small**
   - 1 PR = 1 feature
   - Files changed: 10 or fewer recommended
   - Lines changed: 300 or fewer recommended

3. **Explain thoroughly**
   - Why you chose this implementation
   - Alternatives you considered
   - Points you especially want reviewed

### Review Time Guidelines

- Small PR (100 lines or less): 15 minutes
- Medium PR (100-300 lines): 30 minutes
- Large PR (300+ lines): 1 hour or more

**Principle**: Avoid large PRs; split them up

## Promoting Automation (if applicable)

### Automated Quality Checks

**Automation items and adopted tools**:

1. **Lint checks**
   - **ESLint 9.x** + **@typescript-eslint**
     - Enforces unified coding standards with TypeScript-specific rule sets
     - Automatically detects potential bugs and deprecated patterns
     - Configuration file: `eslint.config.js` (Flat Config format)

2. **Code formatting**
   - **Prettier 3.x**
     - Automatically formats code style, reducing review-time debates
     - Used alongside ESLint; `eslint-config-prettier` avoids conflicts
     - Configuration file: `.prettierrc`

3. **Type checking**
   - **TypeScript Compiler (tsc) 5.x**
     - `tsc --noEmit` checks for type errors only
     - Verifies type safety independently of the build
     - Configuration file: `tsconfig.json`

4. **Test execution**
   - **Vitest 2.x**
     - Vite-based for fast startup and execution
     - Native TypeScript/ESM support; works with zero configuration
     - Coverage measurement (@vitest/coverage-v8) included by default
     - Modern development experience with HMR support

5. **Build verification**
   - **TypeScript Compiler (tsc)**
     - Guarantees type-checked builds with the standard compiler
     - Simple setup with no additional tools required
     - Output settings centrally managed in `tsconfig.json`

**Implementation**:

**1. CI/CD (GitHub Actions)**
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm run test
      - run: npm run build
```

**2. Pre-commit hooks (Husky 9.x + lint-staged)**
```json
// package.json
{
  "scripts": {
    "prepare": "husky",
    "lint": "eslint .",
    "format": "prettier --write .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "build": "tsc"
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}
```
```bash
# .husky/pre-commit
npm run lint-staged
npm run typecheck
```

**Benefits of adoption**:
- Automatic checks run before commit, preventing defective code from being introduced
- CI runs automatically when a PR is created, ensuring quality before merge
- Early detection reduces fix costs by up to 80% (compared to bugs found in production)

**Why this configuration was chosen**:
- A standard, modern configuration for the TypeScript ecosystem as of 2025
- High compatibility between tools with few configuration conflicts
- An excellent balance between developer experience and execution speed

## Checklist

- [ ] A branching strategy has been decided
- [ ] Commit message conventions are clear
- [ ] A PR template is provided
- [ ] Test types and coverage targets are set
- [ ] A code review process is defined
- [ ] A CI/CD pipeline is in place
