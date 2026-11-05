#!/usr/bin/env node
// PreToolUse guard: only the `builder` subagent may write project files.
// Everyone else (main/lead session, explorer, architect, validator) may only
// write inside .team-work/. Exit code 2 blocks the tool call and the stderr
// message is shown to the agent so it knows to delegate instead.
// Disable temporarily with env CLAUDE_TEAM_GUARD=off.

import path from "node:path";

const ALLOWED_WRITERS = new Set(["builder"]);
const WORK_DIR = ".team-work/";

if (process.env.CLAUDE_TEAM_GUARD === "off") process.exit(0);

let raw = "";
for await (const chunk of process.stdin) raw += chunk;

let input;
try {
  input = JSON.parse(raw);
} catch {
  process.exit(0); // never break the session on a malformed payload
}

const isSubagent = Boolean(input.agent_id);
const agentType = input.agent_type || "";
if (isSubagent && ALLOWED_WRITERS.has(agentType)) process.exit(0);

const ti = input.tool_input || {};
const target = ti.file_path || ti.notebook_path || ti.path;
if (!target) process.exit(0);

const projectDir = process.env.CLAUDE_PROJECT_DIR || input.cwd || process.cwd();
const norm = (p) => p.replace(/\\/g, "/");
const abs = norm(path.resolve(projectDir, target));
const workAbs = norm(path.resolve(projectDir, WORK_DIR)) + "/";

// Case-insensitive compare so it behaves on Windows drive paths too.
if (abs.toLowerCase().startsWith(workAbs.toLowerCase())) process.exit(0);

const who = isSubagent ? `subagent "${agentType || "unknown"}"` : "the lead (main session)";
process.stderr.write(
  `Blocked: ${who} may only write inside ${WORK_DIR}. ` +
    `Delegate code changes to the \`builder\` subagent with a precise brief ` +
    `(work folder path, plan step, done-when command).\n`
);
process.exit(2);
