#!/usr/bin/env pwsh
Write-Host 'Running pre-commit checks: dart format and flutter analyze'
dart format .
$analyze = flutter analyze
if ($LASTEXITCODE -ne 0) {
  Write-Error 'flutter analyze failed. Commit aborted.'
  exit 1
}
Write-Host 'Pre-commit checks passed.'
