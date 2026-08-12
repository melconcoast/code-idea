# Product spec

Current-state business and feature rules. Edit this in place as rules change — this is not a history log (see decisions.md for that).

## Task status
- Valid states: `todo`, `in_progress`, `done`.
- Transitions must be sequential: `todo -> in_progress -> done`. A task cannot move directly from `todo` to `done`.
- Only the assignee or a workspace admin can change a task's status.

## Assignment
- A task has exactly one assignee at a time (no multi-assignee tasks in v1).
- Assigning a task triggers an email notification to the new assignee.
