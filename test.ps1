#!/usr/bin/env pwsh

Set-Location $PSScriptRoot

# Get path with forward slashes for JSON compatibility
$pwd = (Get-Location).Path -replace '\\', '/'

# Test with 20% context usage (green)
Write-Host "Test 1 - Low context (20%):"
'{"workspace":{"current_dir":"' + $pwd + '"},"model":{"display_name":"Opus 4.5"},"context_window":{"used_percentage":20,"total_input_tokens":15000,"total_output_tokens":5000,"context_window_size":200000}}' | pwsh -NoProfile -File statusline-command.ps1
Write-Host "`n"

# Test with 65% context usage (orange)
Write-Host "Test 2 - Medium context (65%):"
'{"workspace":{"current_dir":"' + $pwd + '"},"model":{"display_name":"Opus 4.5"},"context_window":{"used_percentage":65,"total_input_tokens":100000,"total_output_tokens":30000,"context_window_size":200000}}' | pwsh -NoProfile -File statusline-command.ps1
Write-Host "`n"

# Test with 95% context usage (red)
Write-Host "Test 3 - High context (95%):"
'{"workspace":{"current_dir":"' + $pwd + '"},"model":{"display_name":"Opus 4.5"},"context_window":{"used_percentage":95,"total_input_tokens":180000,"total_output_tokens":10000,"context_window_size":200000}}' | pwsh -NoProfile -File statusline-command.ps1
Write-Host "`n"
