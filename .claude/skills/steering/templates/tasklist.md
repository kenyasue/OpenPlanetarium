# Task List

## 🚨 Principle of Full Task Completion

**Continue working until ALL tasks in this file are complete**

### Required Rules
- **Mark every task as `[x]`**
- "Planned as a separate task due to time constraints" is forbidden
- "Deferred because the implementation is too complex" is forbidden
- Do not finish work while leaving incomplete tasks (`[ ]`) behind

### Plan only implementable tasks
- During planning, list only "tasks that can be implemented"
- Do not include "tasks we might do in the future"
- Do not include "tasks under consideration"

### The only cases where skipping a task is allowed
Skipping is allowed only when one of the following technical reasons applies:
- A change in implementation approach made the feature itself unnecessary
- An architecture change replaced it with a different implementation
- A dependency change made the task impossible to execute

When skipping, always state the reason explicitly:
```markdown
- [x] ~~Task name~~ (No longer needed due to implementation approach change: specific technical reason)
```

### If a task is too large
- Split the task into smaller subtasks
- Add the split subtasks to this file
- Complete the subtasks one by one

---

## Phase 1: {phase name}

- [ ] {task 1}
  - [ ] {subtask 1-1}
  - [ ] {subtask 1-2}

- [ ] {task 2}
  - [ ] {subtask 2-1}
  - [ ] {subtask 2-2}

## Phase 2: {phase name}

- [ ] {task 1}
  - [ ] {subtask 1-1}
  - [ ] {subtask 1-2}

- [ ] {task 2}

## Phase 3: Quality Checks and Fixes

- [ ] Confirm all tests pass
  - [ ] `npm test`
- [ ] Confirm there are no lint errors
  - [ ] `npm run lint`
- [ ] Confirm there are no type errors
  - [ ] `npm run typecheck`
- [ ] Confirm the build succeeds
  - [ ] `npm run build`

## Phase 4: Documentation Updates

- [ ] Update README.md (as needed)
- [ ] Post-implementation retrospective (recorded at the bottom of this file)

---

## Post-implementation retrospective

### Implementation completion date
{YYYY-MM-DD}

### Differences between plan and actual

**Points that differed from the plan**:
- {technical changes not anticipated during planning}
- {changes to the implementation approach and their reasons}

**Newly required tasks**:
- {tasks added during implementation}
- {why the addition was necessary}

**Tasks skipped for technical reasons** (only if applicable):
- {task name}
  - Skip reason: {specific technical reason}
  - Alternative implementation: {what it was replaced with}

**⚠️ Note**: Do not list tasks skipped for reasons such as "time constraints" or "difficulty" here. Full task completion is the principle.

### Lessons learned

**Technical learnings**:
- {technical insights gained through the implementation}
- {newly used technologies or patterns}

**Process improvements**:
- {what went well in task management}
- {how the steering files were utilized}

### Improvement suggestions for next time
- {things to watch out for in the next feature addition}
- {more efficient implementation methods}
- {improvements to task planning}
