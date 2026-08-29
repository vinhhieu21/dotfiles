#!/usr/bin/env bash
# Share the per-project memory store across Claude profiles.
#
# Memory lives at $CLAUDE_CONFIG_DIR/projects/<slug>/memory/. The <slug> is
# derived from the cwd, so the same repo maps to the same slug in every
# profile. Session transcripts stay per-profile (separate accounts); only the
# `memory/` subdir is shared.
#
# Canonical store = ~/.claude (personal). Any non-personal profile gets its
# memory/ dir replaced with a symlink to the personal one, so reads and writes
# land on the same files regardless of which profile is running.
#
# Runs on SessionStart. No-op when running as the personal profile.

set -u

CANON="$HOME/.claude"
cfg="${CLAUDE_CONFIG_DIR:-$CANON}"

# Personal profile is canonical — nothing to link.
[ "$cfg" = "$CANON" ] && exit 0

# cwd from the SessionStart hook payload (fall back to $PWD).
cwd=""
if [ ! -t 0 ]; then
  input=$(cat 2>/dev/null)
  cwd=$(printf '%s' "$input" | jq -r '.cwd // .workspace.current_dir // empty' 2>/dev/null)
fi
[ -n "$cwd" ] || cwd="$PWD"

# Slug: replace every "/" with "-" (matches Claude's projects/ naming).
slug=$(printf '%s' "$cwd" | sed 's#/#-#g')

canon_mem="$CANON/projects/$slug/memory"
work_mem="$cfg/projects/$slug/memory"

# Ensure the canonical store exists.
mkdir -p "$canon_mem" 2>/dev/null

# Already the right symlink? done.
if [ -L "$work_mem" ] && [ "$(readlink "$work_mem")" = "$canon_mem" ]; then
  exit 0
fi

mkdir -p "$cfg/projects/$slug" 2>/dev/null

# If a real memory dir already exists in this profile, fold its files into the
# canonical store before replacing it (don't clobber unsynced notes).
if [ -d "$work_mem" ] && [ ! -L "$work_mem" ]; then
  for f in "$work_mem"/*; do
    [ -e "$f" ] || continue
    base=$(basename "$f")
    [ -e "$canon_mem/$base" ] || cp -p "$f" "$canon_mem/$base" 2>/dev/null
  done
  rm -rf "$work_mem" 2>/dev/null
fi

ln -sfn "$canon_mem" "$work_mem" 2>/dev/null
exit 0
