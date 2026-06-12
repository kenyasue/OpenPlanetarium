---
name: glossary-creation
description: Detailed guide and template for creating a glossary. Use only when creating a glossary.
allowed-tools: Read, Write
---

# Glossary Creation Skill

This skill is a detailed guide for systematically defining project-specific terms and technical terms.

## Prerequisites

Before starting to create the glossary, confirm the following:

### Recommended documents

1. **docs/product-requirements.md** (PRD)
2. **docs/functional-design.md** (functional design document)
3. **docs/architecture.md** (architecture design document)
4. **docs/repository-structure.md** (repository structure)
5. **docs/development-guidelines.md** (development guidelines)

The glossary defines, in a unified way, the terms used across all documents.
Extract terms from each document and organize them systematically.

## Priority of Existing Documents

**Important**: If an existing glossary exists at `docs/glossary.md`,
follow this order of priority:

1. **Existing glossary (`docs/glossary.md`)** - Highest priority
   - Contains the project-specific term definitions
   - Takes precedence over this skill's guide

2. **This skill's guide** - Reference material
   - Generic templates and examples
   - Use when no existing glossary exists, or as a supplement

**When creating a new document**: Refer to this skill's template and guide
**When updating**: Preserve the structure and content of the existing glossary while updating

## Output Location

Save the completed glossary to:

```
docs/glossary.md
```

## Template Reference

When creating the glossary, use the following template: ./template.md

## Detailed Guide

For a more detailed creation guide, refer to the following file: ./guide.md
