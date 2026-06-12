---
description: Implement a new feature following existing patterns, completely non-stop
---

# Add New Feature (Fully Automatic Execution Mode)

**Important:** This workflow is designed to run fully automatically from start to finish without any user intervention. After completing each step, immediately move on to the next step. Do not ask the user for confirmation mid-thought or interrupt the work.

**Argument:** feature name (e.g. `/add-feature user profile editing`)

---

## Step 1: Preparation and Context Setup

1. Establish the current task context:
  - Feature name: `[feature name given as the argument]`
  - Date: `[get the current date in YYYYMMDD format]`
  - Steering directory path: `.steering/[date]-[feature name]/`
2. Create the steering directory above.
3. Create the following 3 empty files:
  - `[steering directory path]/requirements.md`
  - `[steering directory path]/design.md`
  - `[steering directory path]/tasklist.md`

## Step 2: Understand the Project

1. Read `CLAUDE.md` to grasp the overall picture of the project.
2. Review the persistent documents in the `docs/` directory and understand the relevant design philosophy and architecture.

## Step 3: Investigate Existing Patterns

1. Use the Grep tool to search the source code (`src/`) with keywords related to the feature name.
  ```bash
  Grep('[keyword related to the feature]', 'src/')
  ```
2. Analyze the search results and identify existing implementation patterns, naming conventions, and component usage.

## Step 4: Planning Phase (Automatic Generation of Steering Files)

1. Run `Skill('steering')` in **planning mode** and generate the content of the 3 files created in Step 1 (`requirements.md`, `design.md`, `tasklist.md`).
2. **Once this step completes successfully, never stop — immediately proceed to Step 5.**

## Step 5: Implementation Loop (Fully Working Through tasklist.md)

**This step is a loop that repeats automatically until all tasks in `tasklist.md` are `[x]`.**
**Once this step completes successfully, never stop — immediately proceed to Step 6.**

**Loop start:**

1. Read the task list:
  - Read the `[steering directory path]/tasklist.md` file.

2. Check progress:
  - Check whether any incomplete tasks (`[ ]`) exist in the file.
  - **If no incomplete tasks exist:** Consider this implementation loop complete and immediately proceed to **Step 6**.
  - **If incomplete tasks exist:** Proceed to the next operation (3. Execute the task).

3. Execute the task:
  - Identify the **first incomplete task** in `tasklist.md`.
  - Perform the implementation work needed to complete that task.
  - Use `Skill('steering')` in **implementation mode**.
  - Always comply with the coding conventions from `Skill('development-guidelines')`.

4. Update the task list:
  - When the executed task is complete, use the `Edit` tool to update `tasklist.md`, changing the task from `[ ]` to `[x]`.

5. Continue the loop:
  - **Return to the top of Step 5 (1. Read the task list) and repeat the process.**

---
### Exception Handling Rules Within the Implementation Loop

If any of the following situations occur while running the implementation loop, handle them autonomously according to these rules and continue the loop.

- **Rule A: The task is too large**
  - **Handling:** Split the current task into multiple smaller subtasks. Use the `Edit` tool to delete the original task and insert the new subtasks (with `[ ]`) in its place. Then continue the loop.

- **Rule B: The task is no longer needed for technical reasons**
  - **Condition:** Apply only when there is a clear technical reason, such as a change in implementation approach, architecture change, or dependency change.
  - **Handling:** Use the `Edit` tool to update the task in the format `[x] ~~task name~~ (reason: [briefly describe the specific technical reason])`. Then continue the loop.

- **❌ Strictly prohibited actions:**
  - Intentionally skipping incomplete tasks for reasons such as "do it later" or "make it a separate task".
  - Ending the loop while leaving incomplete tasks unaddressed without a reason.
  - Asking the user for a decision.

---

## Step 6: Implementation Validation (Launch Subagent)

1. Confirm that all tasks in `tasklist.md` are complete.
2. Use the `Task` tool to launch the `implementation-validator` subagent and validate quality.
  - `subagent_type`: "implementation-validator"
  - `description`: "Implementation quality validation"
  - `prompt`: "Validate the quality of all changes related to the `[feature name]` implemented this time. The target files are `[list of implemented file paths]`. Focus on coding conventions, error handling, testability, and consistency with existing patterns."

**Once this step completes successfully, never stop — immediately proceed to Step 7.**

## Step 7: Run Automated Tests

1. Run the following commands in order and confirm that all tests pass.
  ```bash
  Bash('npm test')
  Bash('npm run lint')
  Bash('npm run typecheck')
  ```
2. If any command produces an error, analyze the problem, generate and apply fix code, then run this step again.

**Once this step completes successfully, never stop — immediately proceed to Step 8.**

## Step 8: Retrospective and Documentation Update

1. Run `Skill('steering')` in **retrospective mode** and record handover notes in `tasklist.md`.
  - Implementation completion date
  - Differences between plan and actual results
  - Lessons learned
  - Improvement suggestions for next time

2. Determine whether this change affects the project's base design or architecture.

3. If it does, update the relevant persistent documents in `docs/` with the `Edit` tool.

## Completion Criteria

This workflow is automatically considered complete when all of the following conditions are met.
- Step 5: All tasks in `tasklist.md` are in a completed state (`[x]` or skipped with a valid reason).
- Step 6: The `implementation-validator` subagent's validation passes.
- Step 7: All of the `test`, `lint`, and `typecheck` commands succeed without errors.
- Step 8: Handover notes are recorded in `tasklist.md`.

Until these completion criteria are met, think autonomously, solve problems, and continue working.
