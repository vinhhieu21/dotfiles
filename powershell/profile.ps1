# PowerShell 7 profile for native Windows: the counterpart of fish/config.fish.
# install.ps1 links this to $PROFILE.CurrentUserAllHosts. Tools that are not installed are skipped.

function Test-Tool([string]$Name) { [bool](Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue) }

$env:EDITOR = if (Test-Tool cursor) { 'cursor --wait' } else { 'nvim' }
$env:VISUAL = $env:EDITOR

# bat themes come from bat/themes (install.ps1 builds the cache).
$env:BAT_THEME = 'tokyonight_night'

$env:FZF_DEFAULT_OPTS = "--height=60% --layout=reverse --border=rounded --info=inline-right --prompt='❯ ' --pointer='▶' --marker='✓' --color=16,fg+:-1:bold,bg+:-1,hl:2,hl+:2:underline,info:8,prompt:2,pointer:2,marker:3,spinner:5,header:4,border:8,gutter:-1,label:8"
if (Test-Tool fd) {
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    $env:FZF_ALT_C_COMMAND = 'fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
}

# Vi key bindings, matching fish. PSReadLine is absent when the host is not interactive.
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Vi -ViModeIndicator Cursor
    # Ctrl-T files, Alt-C directories, as `fzf --fish` provides.
    if ((Test-Tool fzf) -and (Get-Module PSFzf -ListAvailable)) {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordSetLocation 'Alt+c'
    }
}

if (Test-Tool starship) { Invoke-Expression (& starship init powershell --print-full-init | Out-String) }
if (Test-Tool zoxide) { Invoke-Expression (& zoxide init powershell --cmd cd | Out-String) }

# Built-in aliases would shadow the functions below (gc = Get-Content, gl = Get-Location, ...).
foreach ($name in 'ls', 'cat', 'gc', 'gl') {
    if (Test-Path "Alias:$name") { Remove-Item "Alias:$name" -Force }
}

if (Test-Tool eza) {
    function ls { eza --icons --git --group-directories-first @args }
    function ll { eza -lbGF --git --icons @args }
}
if (Test-Tool bat) { Set-Alias cat bat }

function gs { git status --short @args }
function gst { git status @args }
function gl { git log --oneline --graph --decorate -20 @args }
function gd { git diff @args }
function gdc { git diff --cached @args }
function ga { git add @args }
function gc { git commit @args }
function gco { git checkout @args }
function gsw { git switch @args }
function dc { docker compose @args }
function lzd { lazydocker @args }

function codex-fast { codex --profile fast @args }
function codex-deep { codex --profile deep @args }
function codex-code { codex --profile code @args }
