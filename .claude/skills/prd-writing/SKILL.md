---
name: prd-writing
description: Detailed guide and template for creating a product requirements document (PRD). Use only when creating a PRD.
allowed-tools: Read, Write
---

# PRD Writing Skill

This skill is a detailed guide for creating a high-quality product requirements document (PRD).

## Prerequisites

Before starting PRD creation, the following must be completed:

### Idea brainstorming is complete

The user must have already refined the product idea through dialogue with Claude Code.

### docs/ideas/initial-requirements.md has been created

**Important**: The user must save the brainstorming results in the following file:

**File path**: `docs/ideas/initial-requirements.md`

This file must contain the following:
- The basic product idea
- The problem to be solved
- An overview of the target users
- The key features to implement
- The MVP scope

When creating the PRD, refer to the contents of this file and elaborate on them.

## Priority of Existing Documents

**Important**: If an existing PRD exists at `docs/product-requirements.md`,
follow this order of priority:

1. **Existing PRD (`docs/product-requirements.md`)** - Highest priority
   - Contains project-specific requirements
   - Takes precedence over this skill's guide

2. **This skill's guide** - Reference material
   - Generic templates and examples
   - Use when no existing PRD exists, or as a supplement

**When creating a new PRD**: Refer to this skill's template and guide
**When updating**: Update while preserving the structure and content of the existing PRD

## Output Location

Save the created PRD to:

```
docs/product-requirements.md
```

## Template Reference

When creating a PRD, use the following template: ./template.md

## PRD Creation Process

### 1. Review initial-requirements.md

First, review the initial requirements spec created by the user:

```bash
Read('docs/ideas/initial-requirements.md')
```

### 2. Generate a PRD draft

Based on the contents of initial-requirements.md, generate the PRD following the template.

### 3. Review and improve the PRD

Review the generated PRD from the following perspectives:

#### Review perspectives

1. Is the product vision clear?
2. Are the target users specific?
3. Are the success metrics measurable?
4. Are the functional requirements detailed enough to be implementable?
5. Are the non-functional requirements comprehensive?

#### Evaluation criteria for review results

Evaluate the generated PRD in the following format:

**✅ Strengths**
- A clear vision is described in measurable, specific terms
- Feature specifications are detailed to an implementation level
- KPIs are defined with quantitative metrics

**⚠️ Areas needing improvement**

Ambiguity in functional requirements:
- Problem: Some areas lack concrete implementation specifications
- Recommendation: Specify concrete command specifications and error handling

Measurement methods for success metrics:
- Problem: Measurement methods are unclear
- Recommendation: Specify measurement methods and privacy considerations

### 4. Improvement after review

Go through each issue raised in the review one by one and improve the areas that need to be made more concrete:

1. Check each identified issue one at a time
2. Improve areas that need to be made more concrete
3. After improvement, run the review again
4. Repeat until no issues remain

**Notes**:
- Do not blindly accept the AI's review; a human must always make the final judgment
- Specify review perspectives explicitly
- A human must verify the validity of improvement suggestions

## Key Points for PRD Creation

### 1. Specificity and measurability

Every requirement must be specific and measurable.

**Bad examples**:
- The system must be fast
- Users find it easy to use

**Good examples**:
- Command execution time: within 100ms (on an average PC environment)
- New users can master basic operations within 5 minutes (measured via usability testing)

### 2. User-centered design

Every feature must solve a clear user problem.

**User story format**:
```
As a [user], I want [feature] in order to [goal]
```

**Example**:
```
As a developer, I want a CLI-based task management tool
so that I can manage tasks without leaving the terminal
```

### 3. Clear prioritization

Set a priority for every feature:

- **P0 (Must-have)**: Features included in the MVP (Minimum Viable Product). Without these, the product is not viable
- **P1 (Important)**: Features that should be added soon after the initial release
- **P2 (Nice-to-have)**: Features to consider adding in the future

## Detailed Major Sections of the PRD

### 1. Product Overview

#### Components

1. **Name**: Product name and subtitle
2. **Product concept**: Three key concepts
3. **Product vision**: The world this product aims for, in 3-5 sentences
4. **Goals**: A list of concrete goals

#### Example

```markdown
### Name
**Devtask** - A task management CLI tool for developers

### Product Concept
- Task management completed entirely in the CLI: complete all operations without leaving the terminal
- Automatic priority estimation: automatically estimate priority from task deadlines, creation timestamps, status change history, and more
- Simple, fast feel: complete operations with minimal keystrokes, instant responses

### Product Vision
Provide a CLI tool that lets developers manage tasks efficiently without leaving the terminal.
Specialized for command-line operation, it delivers lightweight, fast task management that does not interrupt the development flow.
Automatic priority estimation lets developers focus on what matters.
```

**Include a concrete value proposition**

Bad example:
```
Build a convenient task management tool
```

Good example:
```
A CLI tool that lets developers manage tasks without leaving the terminal.

Value provided:
- Reduced context switching (zero GUI↔terminal switching)
- Improved work efficiency (no mouse required, average 30% time savings)
- Automation integration (can be embedded in shell scripts)
```

### 2. Target Users (Personas)

#### Required elements

1. **Basic attributes**: Age, occupation, years of experience
2. **Tech stack**: Tools and languages used
3. **Current problems**: Specific pain points
4. **Desired solution**: What they want to achieve
5. **Typical daily workflow**

#### Example

```markdown
### Primary persona: Taro Tanaka (29, full-stack engineer)
- Freelancer juggling 3-5 projects in parallel
- Vim/Emacs + terminal environment
- Doesn't want to spend time on task management
- Prefers Markdown, Git, and CLI tools
```

### 3. Success Metrics (KPIs)

#### SMART principles

- **S**pecific: Clear about what is being measured
- **M**easurable: Can be measured numerically
- **A**chievable: A realistic goal
- **R**elevant: Tied to business goals
- **T**ime-bound: Has a deadline for achievement

#### Example

```markdown
### Primary KPIs
- Daily active users (DAU): 100 (after 3 months)
- Task completion rate: 70% or higher
- Average commands executed per day: 10 or more
```

### 4. Functional Requirements

#### Core features (MVP)

Include the following for each feature:
- User story
- Acceptance criteria (checklist format)
- Priority (P0/P1/P2)

**Format**:
```markdown
### [Feature name]

User story:
As a [user], I want [feature] in order to [goal]

Acceptance criteria:
- [ ] Criterion 1 (measurable)
- [ ] Criterion 2 (measurable)

Priority: P0 (Must-have) / P1 (Important) / P2 (Nice-to-have)
```

#### CLI interface

For CLI tools, include concrete command examples:

```bash
# Basic operations
devtask add "task name" --due 2025-01-15 --priority high
devtask list
devtask next  # Show the task to do now
devtask done <task-id>
devtask show <task-id>
```

### 5. Non-Functional Requirements

Describe them in measurable terms:

**Example**:
```markdown
### Performance
- Command execution time: within 100ms (on an average PC environment)
- Task list display: within 1 second for up to 1000 items

### Usability
- New users can master basic operations within 5 minutes
- All features can be discovered via the help command

### Reliability
- Zero data loss (automatic backups)
- Rollback on error
```

## Quality Standards and Checkpoints

To ensure PRD quality, verify the following checkpoints:

### Vision and goals
- [ ] Is the product vision clear and measurable?
- [ ] Is the concrete value provided defined?
- [ ] Is the target market clear?

### Target users
- [ ] Are personas defined concretely?
- [ ] Are current problems and desired solutions clear?
- [ ] Are the tech stack and daily workflow described?

### Success metrics
- [ ] Are KPIs defined following the SMART principles?
- [ ] Are measurement methods clear?
- [ ] Are deadlines for achievement set?

### Functional requirements
- [ ] Are all features written in user story format?
- [ ] Are acceptance criteria defined in measurable terms?
- [ ] Are priorities (P0/P1/P2) clearly set?

### Non-functional requirements
- [ ] Are performance criteria defined with concrete numbers?
- [ ] Are usability criteria measurable?
- [ ] Are reliability and security requirements clear?

## Summary

Keys to successful PRD creation:

1. **Base it on initial-requirements.md**: Refer to the brainstorming content the user created
2. **Specificity and measurability**: Make every requirement explicit
3. **User-centered**: Only features that solve user problems
4. **Clear prioritization**: Classify as P0/P1/P2
5. **Review and improve**: Self-review plus final human judgment
6. **Apply SMART principles**: Especially important when defining KPIs
