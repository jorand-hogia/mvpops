#!/usr/bin/env pwsh
# load-env.ps1
# Script to load environment variables from .env file

if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^#=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim('"').Trim("'").Trim()
            if ($name -and $value) {
                [Environment]::SetEnvironmentVariable($name, $value, 'Process')
                Write-Host "Set $name"
            }
        }
    }
    Write-Host "Environment variables loaded successfully."
} else {
    Write-Error ".env file not found"
    exit 1
} 