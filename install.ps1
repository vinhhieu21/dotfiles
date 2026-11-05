#requires -Version 7
<#
.SYNOPSIS
    Set up these dotfiles on native Windows: the counterpart of install.sh.
.DESCRIPTION
    Installs tools with winget, then symlinks configs into place.
    Idempotent: existing non-symlink targets are moved to <file>.bak, and files the tools rewrite
    at runtime (Claude Code settings, Codex config) are seeded once and never overwritten.
    Symlinks need Developer Mode (Settings > System > For developers) or an elevated shell.
.PARAMETER SkipPackages
    Only link configs; install nothing.
.PARAMETER WithBuildTools
    Also install the Visual Studio C++ build tools (several GB), which nvim-treesitter needs to
    compile parsers.
#>
[CmdletBinding()]
param(
    [switch]$SkipPackages,
    [switch]$WithBuildTools
)

$ErrorActionPreference = 'Stop'
$Dot = $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

if (-not ($env:APPDATA -and $env:LOCALAPPDATA)) {
    throw 'This script is for Windows. On macOS, Linux and WSL use install.sh.'
}

function Test-CanSymlink {
    $probe = Join-Path ([IO.Path]::GetTempPath()) "dotfiles-symlink-probe-$PID"
    try {
        New-Item -ItemType SymbolicLink -Path $probe -Target $PSCommandPath -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    } finally {
        if (Test-Path -LiteralPath $probe) { (Get-Item -LiteralPath $probe -Force).Delete() }
    }
}

function Get-RepoPath([string]$Relative) {
    [IO.Path]::GetFullPath((Join-Path $Dot $Relative))
}

function Get-BackupPath([string]$Path) {
    $backup = "$Path.bak"
    $n = 1
    while (Test-Path -LiteralPath $backup) { $backup = "$Path.bak.$n"; $n++ }
    $backup
}

function Link([string]$Relative, [string]$Destination) {
    $src = Get-RepoPath $Relative
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing in repo: $Relative" }
    New-Item -ItemType Directory -Force -Path (Split-Path $Destination) | Out-Null

    # Get-Item, not Test-Path: Test-Path reports a broken symlink as absent.
    $existing = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.LinkType) {
            if ("$($existing.Target)" -eq $src) { return }
            $existing.Delete()  # removes only the link, never what it points at
        } else {
            $backup = Get-BackupPath $Destination
            Move-Item -LiteralPath $Destination -Destination $backup
            Write-Host "backed up $Destination -> $backup"
        }
    }
    New-Item -ItemType SymbolicLink -Path $Destination -Target $src | Out-Null
    Write-Host "linked $Destination"
}

function Copy-IfMissing([string]$Relative, [string]$Destination) {
    if (Test-Path -LiteralPath $Destination) { return }
    New-Item -ItemType Directory -Force -Path (Split-Path $Destination) | Out-Null
    Copy-Item -LiteralPath (Get-RepoPath $Relative) -Destination $Destination
    Write-Host "copied $Destination"
}

function Install-WingetPackage([string]$Id, [string[]]$Extra = @()) {
    Write-Host "winget: $Id"
    & winget install --id $Id --exact --silent --disable-interactivity --accept-package-agreements --accept-source-agreements @Extra | Out-Host
    # 0 = installed; these two = already installed / no newer version.
    if ($LASTEXITCODE -notin 0, -1978335189, -1978335135) {
        $failures.Add("winget $Id (exit $LASTEXITCODE)")
    }
}

function Update-SessionPath {
    $env:Path = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine')
        [Environment]::GetEnvironmentVariable('Path', 'User')
    ) -join ';'
}

function Invoke-Optional([string]$Label, [string]$Tool, [scriptblock]$Action) {
    if (-not (Get-Command $Tool -ErrorAction SilentlyContinue)) {
        $failures.Add("$Label ($Tool is not on PATH; open a new terminal and re-run)")
        return
    }
    Write-Host $Label
    $global:LASTEXITCODE = 0  # a non-native action leaves it untouched, and winget may have set it
    try {
        & $Action
        if ($LASTEXITCODE) { $failures.Add("$Label (exit $LASTEXITCODE)") }
    } catch {
        $failures.Add("$Label ($_)")
    }
}

if (-not (Test-CanSymlink)) {
    throw 'Cannot create symlinks. Turn on Developer Mode (Settings > System > For developers) or run from an elevated shell, then re-run.'
}

# ---------------------------------------------------------------------------- packages
if (-not $SkipPackages) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget not found. Install "App Installer" from the Microsoft Store, or re-run with -SkipPackages.'
    }
    @(
        'Git.Git', 'GitHub.cli', 'Starship.Starship', 'Neovim.Neovim',
        'BurntSushi.ripgrep.MSVC', 'sharkdp.fd', 'sharkdp.bat', 'junegunn.fzf', 'ajeetdsouza.zoxide',
        'eza-community.eza', 'jqlang.jq', 'JesseDuffield.lazygit',
        'OpenJS.NodeJS.LTS', 'astral-sh.uv',
        'Anthropic.ClaudeCode', 'OpenAI.Codex', 'JetBrains.Toolbox',
        'DEVCOM.JetBrainsMonoNerdFont'
    ) | ForEach-Object { Install-WingetPackage $_ }

    if ($WithBuildTools) {
        Install-WingetPackage 'Microsoft.VisualStudio.2022.BuildTools' @(
            '--override', '--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended'
        )
    }
    Update-SessionPath

    Invoke-Optional 'npm: tree-sitter-cli (nvim-treesitter)' 'npm' { npm install --global tree-sitter-cli }
    Invoke-Optional 'uv: code-review-graph (Codex MCP server)' 'uv' { uv tool install code-review-graph }
    Invoke-Optional 'PowerShell module: PSFzf' 'Install-Module' {
        if (-not (Get-Module PSFzf -ListAvailable)) { Install-Module PSFzf -Scope CurrentUser -Force }
    }
}

# ---------------------------------------------------------------------------- shell
Link 'powershell/profile.ps1'     $PROFILE.CurrentUserAllHosts
Link 'starship/starship.toml'     "$HOME/.config/starship.toml"
Link 'bat/themes'                 "$env:APPDATA/bat/themes"
if (Get-Command bat -ErrorAction SilentlyContinue) { bat cache --build | Out-Null }

# ---------------------------------------------------------------------------- git
Link 'git/gitconfig'              "$HOME/.gitconfig"
Link 'git/ignore'                 "$HOME/.config/git/ignore"
Link 'gh/config.yml'              "$env:APPDATA/GitHub CLI/config.yml"

# ---------------------------------------------------------------------------- editors
Link 'nvim'                       "$env:LOCALAPPDATA/nvim"
Link 'ideavim/ideavimrc'          "$HOME/.ideavimrc"
Link 'cursor/cursorrules'         "$HOME/.cursorrules"

# ---------------------------------------------------------------------------- AI CLIs
$claude = "$HOME/.claude"
Link 'claude/CLAUDE.md'           "$claude/CLAUDE.md"
Link 'claude/mcp.json'            "$HOME/.mcp.json"
Link 'claude/mods/usage-band'     "$claude/mods/usage-band"
Copy-IfMissing 'claude/settings.json' "$claude/settings.json"
Get-ChildItem "$Dot/claude/hooks" -File | ForEach-Object { Link "claude/hooks/$($_.Name)" "$claude/hooks/$($_.Name)" }
Get-ChildItem "$Dot/claude/agents" -Filter *.md | ForEach-Object { Link "claude/agents/$($_.Name)" "$claude/agents/$($_.Name)" }
Get-ChildItem "$Dot/claude/workflows" -Filter *.md | ForEach-Object { Link "claude/workflows/$($_.Name)" "$claude/workflows/$($_.Name)" }
Get-ChildItem "$Dot/claude/skills" -Directory | ForEach-Object { Link "claude/skills/$($_.Name)/SKILL.md" "$claude/skills/$($_.Name)/SKILL.md" }
Link 'opencode/opencode.json'     "$HOME/.opencode.json"
Get-ChildItem "$Dot/codex" -Filter *.toml | ForEach-Object { Copy-IfMissing "codex/$($_.Name)" "$HOME/.codex/$($_.Name)" }

# ---------------------------------------------------------------------------- summary
Write-Host ''
if ($failures.Count) {
    Write-Warning "Finished with $($failures.Count) problem(s):"
    $failures | ForEach-Object { Write-Warning "  $_" }
    exit 1
}
Write-Host 'Done. Next: open a new terminal, then run: gh auth login'
exit 0
