#!/usr/bin/env pwsh

# Ensure UTF-8 output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ANSI color codes
$ESC = [char]27
$RED = "$ESC[31m"
$GREEN = "$ESC[32m"
$YELLOW = "$ESC[33m"
$BLUE = "$ESC[38;2;122;162;247m"
$MAGENTA = "$ESC[35m"
$CYAN = "$ESC[36m"
$ORANGE = "$ESC[38;5;208m"
$RESET = "$ESC[0m"

# Read JSON input from stdin
$jsonInput = $input | Out-String
$data = $jsonInput | ConvertFrom-Json

# Extract values
$cwd = $data.workspace.current_dir
$model = $data.model.display_name
$usedPct = $data.context_window.used_percentage
$contextSize = $data.context_window.context_window_size

# Replace home directory with ~ (handle both forward and back slashes)
$homePath = $env:USERPROFILE
$homePathForward = $homePath -replace '\\', '/'
$displayPath = $cwd -replace [regex]::Escape($homePath), '~' -replace [regex]::Escape($homePathForward), '~'

# Initialize output with current directory
$output = "$BLUE $displayPath$RESET"

# Git information (if in a git repository)
Push-Location $cwd 2>$null
try {
    $gitDir = git rev-parse --git-dir 2>$null
    if ($LASTEXITCODE -eq 0) {
        # Get current branch name
        $branch = git symbolic-ref --short HEAD 2>$null
        if (-not $branch) {
            $branch = git describe --tags --exact-match 2>$null
        }
        if (-not $branch) {
            $branch = git rev-parse --short HEAD 2>$null
        }

        # Get git status
        $gitStatus = git --no-optional-locks status --porcelain 2>$null

        # Count modified, staged, and untracked files
        $staged = 0
        $modified = 0
        $untracked = 0
        if ($gitStatus) {
            $lines = $gitStatus -split "`n"
            foreach ($line in $lines) {
                if ($line -match "^[AMDRC]") { $staged++ }
                if ($line -match "^.[MD]") { $modified++ }
                if ($line -match "^\?\?") { $untracked++ }
            }
        }

        # Check for ahead/behind commits
        $ahead = 0
        $behind = 0
        $aheadBehind = git --no-optional-locks rev-list --left-right --count "HEAD...@{u}" 2>$null
        if ($LASTEXITCODE -eq 0 -and $aheadBehind) {
            $parts = $aheadBehind -split '\s+'
            if ($parts.Count -ge 2) {
                $ahead = [int]$parts[0]
                $behind = [int]$parts[1]
            }
        }

        # Build git section
        $output += " │ $CYAN $branch$RESET"

        # Add status indicators with colors
        if ($staged -gt 0) {
            $output += " $GREEN✚$staged$RESET"
        }
        if ($modified -gt 0) {
            $output += " $YELLOW●$modified$RESET"
        }
        if ($untracked -gt 0) {
            $output += " $RED…$untracked$RESET"
        }
        if ($ahead -gt 0) {
            $output += " $CYAN⬆$ahead$RESET"
        }
        if ($behind -gt 0) {
            $output += " $MAGENTA⬇$behind$RESET"
        }
    }
} finally {
    Pop-Location
}

# Add model info
$output += " │ $MAGENTA󰚩 $model$RESET"

# Add context with tokens and percentage
if ($null -ne $usedPct) {
    $usedInt = [int]$usedPct
    if ($usedInt -le 60) {
        $ctxColor = $GREEN
    } elseif ($usedInt -le 80) {
        $ctxColor = $ORANGE
    } else {
        $ctxColor = $RED
    }

    # Calculate tokens from percentage
    if ($null -ne $contextSize) {
        $tokensUsed = [math]::Floor(($usedPct / 100) * $contextSize)
        if ($tokensUsed -ge 1000) {
            $tokensDisplay = "$([math]::Floor($tokensUsed / 1000))k"
        } else {
            $tokensDisplay = "$tokensUsed"
        }
        if ($contextSize -ge 1000) {
            $contextDisplay = "$([math]::Floor($contextSize / 1000))k"
        } else {
            $contextDisplay = "$contextSize"
        }
        $output += " │ $ctxColor󰧑 $tokensDisplay/$contextDisplay ($usedPct%)$RESET"
    } else {
        $output += " │ $ctxColor󰧑 $usedPct%$RESET"
    }
}

Write-Host -NoNewline $output
