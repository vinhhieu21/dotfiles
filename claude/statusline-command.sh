#!/usr/bin/env bash
# Claude Code status line — styled after Starship default prompt

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Starship-style path shortening: replace $HOME with ~, keep last 3 components
shorten_path() {
  local p="$1"
  # Replace home directory prefix with ~
  p="${p/#$HOME/~}"
  # Split by / and keep the last 3 parts (Starship default truncation_length = 3)
  local IFS='/'
  read -ra parts <<< "$p"
  local n=${#parts[@]}
  if [ "$n" -le 3 ]; then
    echo "$p"
  else
    # Preserve leading ~ or root, then ellipsis, then last 3 components
    local prefix="${parts[0]}"
    echo "${prefix}/…/${parts[$((n-3))]}/${parts[$((n-2))]}/${parts[$((n-1))]}"
  fi
}

dir=$(shorten_path "$cwd")

# Session token totals from transcript
ctx_tokens=""
session_tokens=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  read -r ctx_tokens session_tokens < <(jq -rs '
    def msgs: [.[] | select(.type == "assistant") | .message];
    def tot(u): (u.input_tokens // 0) + (u.output_tokens // 0) + (u.cache_creation_input_tokens // 0) + (u.cache_read_input_tokens // 0);
    def ctx(u): (u.input_tokens // 0) + (u.cache_creation_input_tokens // 0) + (u.cache_read_input_tokens // 0);
    (msgs | last | (if . then ctx(.usage // {}) else 0 end)) as $c
    | (msgs | map(tot(.usage // {})) | add // 0) as $s
    | "\($c) \($s)"
  ' "$transcript" 2>/dev/null)
fi

fmt_tokens() {
  local n=$1
  [ -z "$n" ] || [ "$n" = "null" ] && { echo ""; return; }
  awk -v n="$n" 'BEGIN {
    if (n >= 1000000) printf "%.1fM", n/1000000;
    else if (n >= 1000) printf "%.1fk", n/1000;
    else printf "%d", n;
  }'
}

# Git branch or commit (skip optional locks) + dirty indicator
branch=""
git_dirty=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  # Dirty check: any tracked changes or untracked files
  if [ -n "$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
    git_dirty="*"
  fi
fi

# Colors (ANSI — dimmed in status line)
CYAN='\033[0;36m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

fmt_cost() {
  awk -v n="$1" 'BEGIN { printf "$%.2f", n+0 }'
}

# Render a fixed-width fill bar. $1=percent(0-100) $2=width(cells)
# Uses 1/8-block partial cells for finer granularity.
ctx_bar() {
  local pct=$1 width=${2:-10}
  awk -v p="$pct" -v w="$width" 'BEGIN {
    if (p < 0) p = 0; if (p > 100) p = 100;
    units = p / 100 * w * 8;        # total eighths to fill
    full = int(units / 8);
    rem  = units - full * 8;
    parts[0]=" "; parts[1]="▏"; parts[2]="▎"; parts[3]="▍";
    parts[4]="▌"; parts[5]="▋"; parts[6]="▊"; parts[7]="▉";
    s = "";
    for (i = 0; i < full && i < w; i++) s = s "█";
    if (full < w) { s = s parts[rem]; i++; }
    for (; i < w; i++) s = s " ";
    printf "%s", s;
  }'
}

# OpenRouter remaining balance, cached to limit network calls.
# Token from env (claude-work) or keychain fallback (so claude shows it too).
# Echoes "remaining limit" (two floats) or nothing.
or_balance() {
  local tok="${ANTHROPIC_AUTH_TOKEN:-$ANTHROPIC_API_KEY}"
  case "$ANTHROPIC_BASE_URL" in *openrouter*) ;; *) tok="" ;; esac
  if [ -z "$tok" ]; then
    tok=$(security find-generic-password -a "$USER" -s openrouter_api_key -w 2>/dev/null)
  fi
  [ -n "$tok" ] || return 0

  # Shared cache across both profiles so one fetch serves all sessions.
  local cache_dir="$HOME/.claude/cache"
  local cache="$cache_dir/or-balance.json"
  local ttl=60
  mkdir -p "$cache_dir" 2>/dev/null

  local now mtime age=999999
  now=$(date +%s)
  if [ -f "$cache" ]; then
    mtime=$(stat -f %m "$cache" 2>/dev/null || stat -c %Y "$cache" 2>/dev/null || echo 0)
    age=$((now - mtime))
  fi

  if [ "$age" -ge "$ttl" ]; then
    local resp
    resp=$(curl -s -m 4 https://openrouter.ai/api/v1/key \
            -H "Authorization: Bearer $tok" 2>/dev/null)
    # Only overwrite cache on a valid response (keep stale on failure)
    if echo "$resp" | jq -e '.data' >/dev/null 2>&1; then
      echo "$resp" > "$cache"
    fi
  fi

  [ -f "$cache" ] || return 0
  jq -r '.data | "\(.limit_remaining // empty) \(.limit // empty)"' "$cache" 2>/dev/null
}

# Build output
out=""

# Directory (Starship style: shortened path)
out+=$(printf "${CYAN}%s${RESET}" "$dir")

# Git branch (with dirty indicator matching Starship's * suffix)
if [ -n "$branch" ]; then
  out+=$(printf " ${BLUE}on ${RED}%s%s${RESET}" "$branch" "$git_dirty")
fi

# Model
if [ -n "$model" ]; then
  out+=$(printf " ${YELLOW}%s${RESET}" "$model")
fi

# Context usage — visual fill bar, colored by fill level
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  ctx_color="$GREEN"
  [ "$used_int" -ge 60 ] && ctx_color="$YELLOW"
  [ "$used_int" -ge 80 ] && ctx_color="$RED"
  bar=$(ctx_bar "$used_int" 10)
  out+=$(printf " ${ctx_color}[%s] %s%%${RESET}" "$bar" "$used_int")
fi

# Session total tokens
sess_str=$(fmt_tokens "$session_tokens")
if [ -n "$sess_str" ]; then
  out+=$(printf " session:%s" "$sess_str")
fi

# Money left in the OpenRouter key — shown in every session (env or keychain).
read -r or_left or_limit < <(or_balance)
if [ -n "$or_left" ]; then
  left_color="$GREEN"
  if [ -n "$or_limit" ]; then
    frac=$(awk -v l="$or_left" -v t="$or_limit" 'BEGIN{ printf "%d", (t>0? l/t*100 : 100) }')
    [ "$frac" -le 25 ] && left_color="$YELLOW"
    [ "$frac" -le 10 ] && left_color="$RED"
  fi
  out+=$(printf " ${left_color}%s${RESET}" "$(fmt_cost "$or_left")")
fi

printf "%s" "$out"
