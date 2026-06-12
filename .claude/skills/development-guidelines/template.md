# Development Guidelines

## Coding Standards

### Naming Conventions

#### Variables and Functions

**TypeScript/JavaScript**:
```typescript
// ✅ Good example
const userProfileData = fetchUserProfile();
function calculateTotalPrice(items: CartItem[]): number { }

// ❌ Bad example
const data = fetch();
function calc(arr: any[]): number { }
```

**Principles**:
- Variables: camelCase, noun or noun phrase
- Functions: camelCase, start with a verb
- Constants: UPPER_SNAKE_CASE
- Boolean: start with `is`, `has`, `should`

#### Classes and Interfaces

```typescript
// Classes: PascalCase, noun
class TaskManager { }
class UserAuthenticationService { }

// Interfaces: PascalCase, with or without an I prefix
interface ITaskRepository { }
interface Task { }

// Type aliases: PascalCase
type TaskStatus = 'todo' | 'in_progress' | 'completed';
```

### Code Formatting

**Indentation**: [2 spaces/4 spaces/tabs]

**Line length**: maximum [80/100/120] characters

**Example**:
```typescript
// [language] code formatting example
[code example]
```

### Comment Conventions

**Function and class documentation**:
```typescript
/**
 * Calculates the total number of tasks
 *
 * @param tasks - Array of tasks to count
 * @param filter - Filter conditions (optional)
 * @returns Total number of tasks
 * @throws {ValidationError} If the task array is invalid
 */
function countTasks(
  tasks: Task[],
  filter?: TaskFilter
): number {
  // implementation
}
```

**Inline comments**:
```typescript
// ✅ Good example: explains WHY
// Invalidate the cache to fetch the latest data
cache.clear();

// ❌ Bad example: explains WHAT (obvious from the code)
// Clear the cache
cache.clear();
```

### Error Handling

**Principles**:
- Expected errors: define appropriate error classes
- Unexpected errors: propagate upward
- Never ignore errors

**Example**:
```typescript
// Error class definition
class ValidationError extends Error {
  constructor(
    message: string,
    public field: string,
    public value: unknown
  ) {
    super(message);
    this.name = 'ValidationError';
  }
}

// Error handling
try {
  const task = await taskService.create(data);
} catch (error) {
  if (error instanceof ValidationError) {
    console.error(`Validation error [${error.field}]: ${error.message}`);
    // Provide feedback to the user
  } else {
    console.error('Unexpected error:', error);
    throw error; // Propagate upward
  }
}
```

## Git Workflow Rules

### Branching Strategy

**Branch types**:
- `main`: state deployable to production
- `develop`: latest state of development
- `feature/[feature-name]`: new feature development
- `fix/[fix-description]`: bug fixes
- `refactor/[target]`: refactoring

**Flow**:
```
main
  └─ develop
      ├─ feature/task-management
      ├─ feature/user-auth
      └─ fix/task-validation
```

### Commit Message Conventions

**Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**:
- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation
- `style`: code formatting
- `refactor`: refactoring
- `test`: adding or fixing tests
- `chore`: build, auxiliary tools, etc.

**Example**:
```
feat(task): Add task priority setting feature

Allow users to set a priority (high/medium/low) on tasks.
- Added a priority field to the Task model
- Added a --priority option to the CLI
- Implemented sorting by priority

Closes #123
```

### Pull Request Process

**Pre-creation checks**:
- [ ] All tests pass
- [ ] No lint errors
- [ ] Type checks pass
- [ ] Conflicts are resolved

**PR template**:
```markdown
## Overview
[Brief description of the changes]

## Reason for Change
[Why this change is necessary]

## Changes
- [change 1]
- [change 2]

## Tests
- [ ] Unit tests added
- [ ] Manual testing performed

## Screenshots (if applicable)
[images]

## Related Issues
Closes #[issue number]
```

**Review process**:
1. Self-review
2. Run automated tests
3. Assign reviewers
4. Address review feedback
5. Merge after approval

## Test Strategy

### Test Types

#### Unit Tests

**Target**: individual functions and classes

**Coverage target**: [80/90/100]%

**Example**:
```typescript
describe('TaskService', () => {
  describe('create', () => {
    it('creates a task with valid data', async () => {
      const service = new TaskService(mockRepository);
      const task = await service.create({
        title: 'Test task',
        description: 'Description',
      });

      expect(task.id).toBeDefined();
      expect(task.title).toBe('Test task');
    });

    it('throws ValidationError when title is empty', async () => {
      const service = new TaskService(mockRepository);

      await expect(
        service.create({ title: '' })
      ).rejects.toThrow(ValidationError);
    });
  });
});
```

#### Integration Tests

**Target**: interaction between multiple components

**Example**:
```typescript
describe('Task CRUD', () => {
  it('can create, read, update, and delete a task', async () => {
    // Create
    const created = await taskService.create({ title: 'Test' });

    // Read
    const found = await taskService.findById(created.id);
    expect(found?.title).toBe('Test');

    // Update
    await taskService.update(created.id, { title: 'Updated' });
    const updated = await taskService.findById(created.id);
    expect(updated?.title).toBe('Updated');

    // Delete
    await taskService.delete(created.id);
    const deleted = await taskService.findById(created.id);
    expect(deleted).toBeNull();
  });
});
```

#### E2E Tests

**Target**: entire user scenarios

**Example**:
```typescript
describe('Task management flow', () => {
  it('allows a user to add and complete a task', async () => {
    // Add a task
    await cli.run(['add', 'New task']);
    expect(output).toContain('Task added');

    // List tasks
    await cli.run(['list']);
    expect(output).toContain('New task');

    // Complete the task
    await cli.run(['complete', '1']);
    expect(output).toContain('Task completed');
  });
});
```

### Test Naming Conventions

**Pattern**: `[target]_[condition]_[expected result]`

**Example**:
```typescript
// ✅ Good examples
it('create_emptyTitle_throwsValidationError', () => { });
it('findById_existingId_returnsTask', () => { });
it('delete_nonExistentId_throwsNotFoundError', () => { });

// ❌ Bad examples
it('test1', () => { });
it('works', () => { });
it('should work correctly', () => { });
```

### Use of Mocks and Stubs

**Principles**:
- Mock external dependencies (APIs, DB, file system)
- Use real implementations for business logic

**Example**:
```typescript
// Mock the repository
const mockRepository: ITaskRepository = {
  save: jest.fn(),
  findById: jest.fn(),
  findAll: jest.fn(),
  delete: jest.fn(),
};

// Use the actual service implementation
const service = new TaskService(mockRepository);
```

## Code Review Criteria

### Review Points

**Functionality**:
- [ ] Does it satisfy the requirements?
- [ ] Are edge cases considered?
- [ ] Is error handling appropriate?

**Readability**:
- [ ] Is the naming clear?
- [ ] Are comments appropriate?
- [ ] Is complex logic explained?

**Maintainability**:
- [ ] Is there no duplicated code?
- [ ] Are responsibilities clearly separated?
- [ ] Is the impact of changes limited in scope?

**Performance**:
- [ ] Are there no unnecessary computations?
- [ ] Is there no potential for memory leaks?
- [ ] Are database queries optimized?

**Security**:
- [ ] Is input validation appropriate?
- [ ] Is no sensitive information hardcoded?
- [ ] Are permission checks implemented?

### Writing Review Comments

**Constructive feedback**:
```markdown
## ✅ Good example
This implementation may degrade in performance as the number of tasks grows.
How about considering an index-based lookup instead?

## ❌ Bad example
This is bad code.
```

**Explicit priorities**:
- `[required]`: must fix
- `[recommended]`: fix recommended
- `[suggestion]`: please consider
- `[question]`: question for understanding

## Development Environment Setup

### Required Tools

| Tool | Version | Installation |
|--------|-----------|-----------------|
| [tool 1] | [version] | [command] |
| [tool 2] | [version] | [command] |

### Setup Steps

```bash
# 1. Clone the repository
git clone [URL]
cd [project-name]

# 2. Install dependencies
[install command]

# 3. Configure environment variables
cp .env.example .env
# Edit the .env file

# 4. Start the development server
[start command]
```

### Recommended Development Tools (if applicable)

- [tool 1]: [description]
- [tool 2]: [description]
