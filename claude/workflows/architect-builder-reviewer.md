<purpose>
Run small-to-medium coding work through a simple 3-role loop:

1. Architect — define scope, constraints, touched area, success checks
2. Builder — make minimum change that solves task
3. Reviewer — check diff for bugs, regressions, and missing verification

Use this when task is too big for direct one-shot editing but too small for heavy planning.
</purpose>

<scope_gate>
Use this workflow only if task fits all:
- bounded scope
- no new architecture
- no schema or infrastructure redesign
- no deep external research needed
- likely under 10 file edits

If task is trivial:
```
Do it directly inline.
```

If task is broad or uncertain:
```
Switch to a fuller planning flow.
```
</scope_gate>

<process>

<step name="architect">
Before editing, write short architecture note in working memory only:
- task in one sentence
- assumptions
- files or modules likely touched
- main risk
- verification check

Keep this to 5 bullets max. No plan files. No extra files.
</step>

<step name="builder">
Execute change with these rules:
- smallest change that solves request
- match existing style
- no opportunistic refactors
- no new abstraction unless duplication or complexity demands it
- prefer existing tools and plugins already installed

If codebase memory helps, consult mempalace. Do not write new memory yet.
</step>

<step name="verify">
Run narrow verification appropriate to scope:
- existing targeted tests first
- if no tests, use fastest sanity check that proves behavior
- if verification cannot run, state exactly what was not verified and why
</step>

<step name="reviewer">
Review own diff with code-review mindset:
- correctness bugs
- behavior regressions
- missing edge-case handling
- missing tests or weak verification
- unnecessary edits

If issue found, fix it before finishing.
</step>

<step name="capture_memory">
Only after change is correct, decide if memory belongs in mempalace.

Store only durable items:
- stable user preference
- recurring workflow decision
- long-lived project convention

Do not store:
- one-off task details
- temporary debugging notes
- obvious facts already in repo
</step>

<step name="done">
Report in compact format:
- what changed
- how it was verified
- any residual risk
- whether mempalace was updated

Commit only if user asked or repo workflow clearly expects it.
</step>

</process>

<guardrails>
- no heavy planning artifacts
- no roadmap or milestone mutation
- no subagents unless user explicitly wants delegation
- no memory writes before reviewer pass
- stop and ask if scope expands into architecture or schema changes
</guardrails>

<success_criteria>
- [ ] scope stayed bounded
- [ ] architect note created before edits
- [ ] minimal change implemented
- [ ] verification run or explicit gap stated
- [ ] reviewer pass completed
- [ ] mempalace updated only if durable learning exists
</success_criteria>
