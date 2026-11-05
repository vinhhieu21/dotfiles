---
name: team
description: Run a task through the full agent team pipeline (explorer -> architect -> builder -> validator). Use when the user types /team or asks to "use the team".
argument-hint: <task description>
disable-model-invocation: true
---

Run this task through the agent team. Task:

$ARGUMENTS

Steps:
1. Classify size (question / trivial / small / medium-large) and say it in one line.
2. Create `.team-work/<yyyymmdd>-<slug>/brief.md` with: goal, the user's exact words,
   constraints, acceptance criteria (testable), out of scope.
3. Spawn `explorer` agents in parallel for each independent "where/what" question.
   Use `model: sonnet` for any question that needs understanding, not just locating.
4. Medium/large: spawn `architect` to write plan.md. Read the summary; if it returned
   open questions, ask the user before continuing.
5. Spawn `builder` per plan step (parallel only for steps marked disjoint). Each prompt
   names the work folder, the step, and its done-when command.
6. Spawn `validator` (use `model: opus` if the change is risky). On FAIL, resume the
   builder with the listed issues; max 2 rounds. On PLAN-PROBLEM go back to architect.
7. Report: files changed, verdict, how to verify, open issues.
