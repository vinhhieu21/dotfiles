# ==============================================================================
# Environment — above the interactive guard so non-interactive shells
# (IDE terminals, mvn, scripts) get it too.
# ==============================================================================

# Homebrew shellenv without spawning brew on every shell startup.
# macOS (Apple Silicon) or Linux/WSL prefix; nothing is set if neither exists.
if test -d /opt/homebrew
    set -gx HOMEBREW_PREFIX /opt/homebrew
else if test -d /home/linuxbrew/.linuxbrew
    set -gx HOMEBREW_PREFIX /home/linuxbrew/.linuxbrew
end
if set -q HOMEBREW_PREFIX
    set -gx HOMEBREW_CELLAR $HOMEBREW_PREFIX/Cellar
    set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX
    test -d $HOMEBREW_PREFIX/Homebrew; and set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX/Homebrew
    if not contains $HOMEBREW_PREFIX/share/info $INFOPATH
        set -gx INFOPATH $HOMEBREW_PREFIX/share/info $INFOPATH
    end
end

# PATH: prepend in priority order (--move re-orders entries path_helper already added).
# --path = session-only, no universal-variable
# writes. Directories that don't exist on this machine are skipped.
fish_add_path --move --path $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin ~/.local/bin \
    ~/.opencode/bin \
    ~/.kimi-code/bin \
    /Applications/Cursor.app/Contents/Resources/app/bin \
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" \
    ~/google-cloud-sdk/bin \
    ~/.antigravity/antigravity/bin

# Colima docker socket — Testcontainers/docker-java need it. Only where colima is set up.
# Docker API version for old Testcontainers/docker-java lives in ~/.docker-java.properties
# (MAVEN_OPTS -D doesn't reach surefire-forked JVMs)
if test -d "$HOME/.colima/default"
    set -gx DOCKER_HOST "unix://$HOME/.colima/default/docker.sock"
    set -gx TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE "$HOME/.colima/default/docker.sock"
    set -gx TESTCONTAINERS_RYUK_DISABLED true
end

# MongoDB binary location for EmbeddedMongo test infra (mongo 4.4 — driver 3.12.10 compat)
if test -d "$HOME/.local/share/mongodb/mongodb-macos-x86_64-4.4.29"
    set -gx MONGO_DIR $HOME/.local/share/mongodb/mongodb-macos-x86_64-4.4.29
end

if not status is-interactive
    return
end

# ==============================================================================
# Interactive
# ==============================================================================
set -g fish_greeting ""
set -gx EDITOR "cursor --wait"
set -gx VISUAL "cursor --wait"

# Vi-mode cursor shapes. Ghostty's shell-integration cursor handling is off (no-cursor), so fish
# drives the cursor itself; force is needed because TERM=xterm-ghostty is not in fish's known list.
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_replace underscore
set -g fish_cursor_visual block
set -g fish_vi_force_cursor 1

# Ghostty theme (TokyoNight Night / Day, follows macOS appearance) is the single source of truth.
# Fish syntax colors (conf.d/colors.fish), starship and fzf use the 16 ANSI slots; bat uses the
# official Tokyo Night editor themes (bat/themes in dotfiles) and picks dark/light from macOS.
set -gx BAT_THEME auto:system
set -gx BAT_THEME_DARK tokyonight_night
set -gx BAT_THEME_LIGHT tokyonight_day
set -gx FZF_DEFAULT_OPTS "--height=60% --layout=reverse --border=rounded --info=inline-right \
  --prompt='❯ ' --pointer='▶' --marker='✓' \
  --color=16,fg+:-1:bold,bg+:-1,hl:2,hl+:2:underline,info:8,prompt:2,pointer:2,marker:3,spinner:5,header:4,border:8,gutter:-1,label:8"
if command -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND 'fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
end
# Previews for the fzf key bindings (ctrl-t files, alt-c dirs) installed by `fzf --fish` below.
command -q bat; and set -gx FZF_CTRL_T_OPTS "--preview 'bat --style=numbers --color=always --line-range=:300 {}' --preview-window=right:55%:border-left"
command -q eza; and set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --level=2 --color=always --icons {}' --preview-window=right:45%:border-left"

# Source `<tool> init` output from a cache instead of spawning the tool on every shell.
# Cache regenerates when the binary is newer than the cache (upgrade) or the cache is missing.
function __init_cached -a name cmd
    set -l bin (command -v $name); or return
    set -l cache ~/.cache/fish/$name.fish
    if not test -f $cache; or test $bin -nt $cache
        mkdir -p ~/.cache/fish
        eval $cmd >$cache; or begin; rm -f $cache; return; end
    end
    source $cache
end
__init_cached starship "starship init fish --print-full-init"
__init_cached zoxide "zoxide init fish"
__init_cached fzf "fzf --fish"
functions --erase __init_cached

# Abbreviations
abbr -a ls eza --icons --git --group-directories-first
abbr -a ll eza -lbGF --git --icons
abbr -a cat bat
abbr -a cd z
abbr -a gs git status --short
abbr -a gst git status
abbr -a gl git log --oneline --graph --decorate -20
abbr -a gd git diff
abbr -a gdc git diff --cached
abbr -a ga git add
abbr -a gc git commit
abbr -a gco git checkout
abbr -a gsw git switch
abbr -a dc docker compose
abbr -a lzd lazydocker

# ==============================================================================
# AI CLI wrappers - API keys come from the macOS keychain, never from files:
#   security add-generic-password -a "$USER" -s openrouter_api_key -w '<key>'
# Without a keychain (Linux/WSL), export OPENROUTER_API_KEY instead.
# ==============================================================================
function __openrouter_key --description "Print the OpenRouter key from the keychain or environment"
    if command -q security
        security find-generic-password -a "$USER" -s openrouter_api_key -w 2>/dev/null; and return
    end
    set -q OPENROUTER_API_KEY; and echo $OPENROUTER_API_KEY
end

# Claude Code - Personal Account (Browser Login)
function claude --wraps=claude --description "Run Claude Code with personal profile (OAuth Login)"
    # Unset OpenRouter variables so Claude defaults to your browser login
    env -u ANTHROPIC_BASE_URL \
        -u ANTHROPIC_AUTH_TOKEN \
        -u ANTHROPIC_API_KEY \
        -u ANTHROPIC_MODEL \
        CLAUDE_CONFIG_DIR="$HOME/.claude" \
        claude $argv
end

# Claude Code - Work Account (OpenRouter)
function claude-work --wraps=claude --description "Run Claude Code with Work profile (OpenRouter)"
    set -l k (__openrouter_key)
    if test -z "$k"
        echo "Error (claude-work): no 'openrouter_api_key' keychain entry and OPENROUTER_API_KEY is unset" >&2
        return 1
    end

    # Kimi K3 uses the single custom-model slot; K2.7 Code reuses the Fable slot
    # (claude-fable-5 has no OpenRouter endpoint, so nothing is lost).
    # Effort is session-wide, not per-model: CLAUDE_CODE_EFFORT_LEVEL pins this
    # profile to medium so both Kimis run at medium (it also outranks the Fable
    # launch-effort pin and the shared settings.json effortLevel).
    env -u ANTHROPIC_API_KEY \
        CLAUDE_CODE_EFFORT_LEVEL='medium' \
        ANTHROPIC_MODEL='claude-sonnet-5[1m]' \
        ANTHROPIC_BASE_URL='https://openrouter.ai/api' \
        ANTHROPIC_AUTH_TOKEN="$k" \
        ANTHROPIC_CUSTOM_MODEL_OPTION='moonshotai/kimi-k3' \
        ANTHROPIC_CUSTOM_MODEL_OPTION_NAME='Kimi K3' \
        ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION='MoonshotAI Kimi K3 via OpenRouter · 1M context' \
        ANTHROPIC_CUSTOM_MODEL_OPTION_SUPPORTED_CAPABILITIES='thinking,effort' \
        ANTHROPIC_DEFAULT_FABLE_MODEL='moonshotai/kimi-k2.7-code' \
        ANTHROPIC_DEFAULT_FABLE_MODEL_NAME='Kimi K2.7 Code' \
        ANTHROPIC_DEFAULT_FABLE_MODEL_DESCRIPTION='MoonshotAI Kimi K2.7 Code via OpenRouter · 262k context' \
        ANTHROPIC_DEFAULT_FABLE_MODEL_SUPPORTED_CAPABILITIES='thinking,effort' \
        CLAUDE_CONFIG_DIR="$HOME/.claude-work" \
        claude $argv
end

# Codex - Personal Account (ChatGPT Subscription)
function codex --wraps=codex --description "Run Codex with ChatGPT subscription (OAuth Login)"
    # Unset API keys so Codex defaults to ChatGPT auth subscription
    env -u OPENROUTER_API_KEY \
        -u OPENAI_API_KEY \
        codex $argv
end

# Codex - Work Account (OpenRouter)
function codex-work --wraps=codex --description "Run Codex with Work profile (OpenRouter)"
    set -l k (__openrouter_key)
    if test -z "$k"
        echo "Error (codex-work): no 'openrouter_api_key' keychain entry and OPENROUTER_API_KEY is unset" >&2
        return 1
    end

    # OpenRouter balance on entry/exit (same cache as claude statusline)
    set -l bal (OPENROUTER_API_KEY=$k ~/.claude/bin/or-balance.sh 2>/dev/null)
    test -n "$bal"; and echo (set_color green)"OpenRouter: $bal"(set_color normal)

    env -u OPENAI_API_KEY \
        OPENROUTER_API_KEY="$k" \
        codex $argv
    set -l st $status

    set -l bal (OPENROUTER_API_KEY=$k ~/.claude/bin/or-balance.sh 2>/dev/null)
    test -n "$bal"; and echo (set_color green)"OpenRouter: $bal"(set_color normal)
    return $st
end


# OpenCode - OpenRouter (same pattern as codex)
function opencode2 --wraps=opencode2 --description "Run OpenCode with OpenRouter key from keychain"
    set -l k (__openrouter_key)
    if test -z "$k"
        echo "Error (opencode2): no 'openrouter_api_key' keychain entry and OPENROUTER_API_KEY is unset" >&2
        return 1
    end

    env -u OPENAI_API_KEY \
        OPENROUTER_API_KEY="$k" \
        command opencode2 $argv
end

# Codex profile shortcuts
alias codex-fast='codex --profile fast'
alias codex-deep='codex --profile deep'
alias codex-code='codex --profile code'

test -x "$HOMEBREW_PREFIX/bin/brew"; and eval ($HOMEBREW_PREFIX/bin/brew shellenv fish)
