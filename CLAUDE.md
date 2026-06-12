# Project Memory

## Tech Stack

- Development environment: devcontainer
- Node.js v24.11.0
- TypeScript 5.x
- Package manager: npm

## Core Principles of Spec-Driven Development

### Basic Flow

1. **Document creation**: Define "what to build" in persistent documents (`docs/`)
2. **Work planning**: Plan "what to do this time" in steering files (`.steering/`)
3. **Implementation**: Implement according to tasklist.md, updating progress as you go
4. **Verification**: Tests and behavior checks
5. **Updates**: Update documents as needed

### Important Rules

#### When Creating Documents

**Create one file at a time, and always get the user's approval before moving on to the next**

When waiting for approval, state it clearly:
```
"The creation of [document name] is complete. Please review the contents.
Once approved, I will proceed to the next document."
```

#### Checks Before Implementation

Before starting any new implementation, always confirm the following:

1. Read CLAUDE.md
2. Read the related persistent documents (`docs/`)
3. Use Grep to search for existing similar implementations
4. Understand existing patterns before starting implementation

#### Steering File Management

Create `.steering/[YYYYMMDD]-[task-name]/` for each piece of work:

- `requirements.md`: The requirements for this work
- `design.md`: Implementation approach
- `tasklist.md`: Concrete task list

Naming convention: `20250115-add-user-profile` format

#### Managing Steering Files

**Use the `steering` skill for work planning, implementation, and verification.**

- **Work planning**: `Skill('steering')` in Mode 1 (steering file creation)
- **Implementation**: `Skill('steering')` in Mode 2 (implementation and tasklist.md update management)
- **Verification**: `Skill('steering')` in Mode 3 (retrospective)

Detailed procedures and update management rules are defined within the steering skill.

## Directory Structure

### Persistent Documents (`docs/`)

Define "what to build" and "how to build it" for the entire application:

#### Drafts & Ideas (`docs/ideas/`)
- Outputs of brainstorming sessions
- Technical research notes
- Free-form (minimal structuring)
- Automatically loaded when `/setup-project` is run

#### Official Documents
- **product-requirements.md** - Product requirements document (PRD)
- **functional-design.md** - Functional design document
- **architecture.md** - Technical specification
- **repository-structure.md** - Repository structure document
- **development-guidelines.md** - Development guidelines
- **glossary.md** - Ubiquitous language definitions

### Work-Unit Documents (`.steering/`)

Define "what to do this time" for a specific piece of development work:

- `requirements.md`: The requirements for this work
- `design.md`: Design of the changes
- `tasklist.md`: Task list

## Development Process

### Initial Setup

1. Use this template
2. Create the persistent documents with `/setup-project` (creates 6 documents interactively)
3. Implement features with `/add-feature [feature]`

### Day-to-Day Usage

**By default, just make requests in normal conversation:**

```bash
# Editing documents
> Add a new feature to the PRD
> Review the performance requirements in architecture.md
> Add a new domain term to glossary.md

# Adding features (standardized flows use commands)
> /add-feature user profile editing

# Detailed review (when a detailed report is needed)
> /review-docs docs/product-requirements.md
```

**Key point**: You don't need to be aware of the details of spec-driven development. Claude Code will determine and load the appropriate skills.

## Document Management Principles

### Persistent Documents (`docs/`)

- Describe the fundamental design
- Not updated frequently
- The "north star" for the entire project

### Work-Unit Documents (`.steering/`)

- Specific to a particular piece of work
- Created anew for each piece of work
- Retained as history
