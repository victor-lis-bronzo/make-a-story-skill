<#
.SYNOPSIS
  Install the grill-with-stories and make-a-story skills into Claude Code and/or Antigravity skill folders.
.PARAMETER Claude    Install for Claude Code.
.PARAMETER Agy       Install for Antigravity (agy).
.PARAMETER Project   Install into this project directory instead of globally.
.PARAMETER Link      Symlink instead of copy (needs Developer Mode or admin on Windows).
.PARAMETER Uninstall Remove the skills from the selected targets.
With no -Claude/-Agy, both are installed. grill-with-stories needs mattpocock/skills `grilling`.
#>
param([switch]$Claude, [switch]$Agy, [string]$Project, [switch]$Link, [switch]$Uninstall)
$ErrorActionPreference = 'Stop'

$root  = (Resolve-Path (Join-Path $PSScriptRoot '..\skills')).Path
$names = @('grill-with-stories', 'make-a-story')
if (-not $Claude -and -not $Agy) { $Claude = $true; $Agy = $true }

$targets = @()
if ($Project) {
  if ($Claude) { $targets += Join-Path $Project '.claude\skills' }
  if ($Agy)    { $targets += Join-Path $Project '.agents\skills' }
} else {
  if ($Claude) { $targets += Join-Path $HOME '.claude\skills' }
  # Antigravity documents ~/.gemini/config/skills; the skills CLI writes to antigravity-cli/skills.
  if ($Agy)    { $targets += Join-Path $HOME '.gemini\config\skills'; $targets += Join-Path $HOME '.gemini\antigravity-cli\skills' }
}

foreach ($dir in $targets) {
  foreach ($name in $names) {
    $src  = Join-Path $root $name
    $dest = Join-Path $dir $name
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    if ($Uninstall) { Write-Host "removed  $dest"; continue }
    New-Item -ItemType Directory -Force $dir | Out-Null
    if ($Link) { New-Item -ItemType SymbolicLink -Path $dest -Target $src | Out-Null; Write-Host "linked   $dest -> $src" }
    else { Copy-Item $src $dest -Recurse; Write-Host "copied   $dest" }
  }
}
if ($Uninstall) { return }

# grill-with-stories builds on mattpocock/skills `grilling`. Warn (don't fail) if it isn't visible.
$searchDirs = $targets + @(
  (Join-Path $HOME '.claude\skills'), (Join-Path $HOME '.agents\skills'),
  (Join-Path $HOME '.gemini\config\skills'), (Join-Path $HOME '.gemini\antigravity-cli\skills'))
$found = [bool]($searchDirs | Where-Object { Test-Path (Join-Path $_ 'grilling\SKILL.md') } | Select-Object -First 1)
$plugins = Join-Path $HOME '.claude\plugins'
if (-not $found -and (Test-Path $plugins)) {
  $found = [bool](Get-ChildItem $plugins -Recurse -Filter 'SKILL.md' -ErrorAction SilentlyContinue |
    Where-Object { $_.Directory.Name -eq 'grilling' } | Select-Object -First 1)
}
if (-not $found) {
  Write-Warning "no 'grilling' skill found. /grill-with-stories needs it. Install mattpocock/skills:"
  Write-Host  "  npx skills add mattpocock/skills --skill grilling -g -a claude-code -a antigravity-cli -y"
}
