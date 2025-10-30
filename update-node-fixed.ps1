# Node.js Update Script for D:\node\
# Auto-update Node.js to latest version

Write-Host "Checking latest Node.js version..." -ForegroundColor Cyan

# Get latest version from Node.js API
try {
    $response = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json" -UseBasicParsing
    $latestVersion = ($response | Where-Object { $_.lts -eq $false } | Select-Object -First 1).version
    $latestVersion = $latestVersion -replace '^v', ''  # Remove 'v' prefix if present
    Write-Host "Latest version: v$latestVersion" -ForegroundColor Green
} catch {
    # Fallback: use a known latest version
    Write-Host "Could not fetch latest version, using v25.1.0" -ForegroundColor Yellow
    $latestVersion = "25.1.0"
}

# Check current version
$currentVersion = node -v
Write-Host "Current version: $currentVersion" -ForegroundColor Yellow

if ($currentVersion -eq "v$latestVersion") {
    Write-Host "`nAlready on latest version!" -ForegroundColor Green
    exit 0
}

# Confirm update
Write-Host "`nWill update to v$latestVersion" -ForegroundColor Cyan
Write-Host "Downloading Node.js v$latestVersion..." -ForegroundColor Cyan

# Build download URL (Windows x64)
$nodeVersion = $latestVersion
$downloadUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-win-x64.zip"
$zipPath = "$env:TEMP\node-v$nodeVersion-win-x64.zip"
$extractPath = "$env:TEMP\node-v$nodeVersion-win-x64"

try {
    # Download
    Write-Host "Download URL: $downloadUrl" -ForegroundColor Gray
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    
    Write-Host "Download complete, extracting..." -ForegroundColor Cyan
    
    # Extract
    if (Test-Path $extractPath) {
        Remove-Item $extractPath -Recurse -Force
    }
    Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force
    
    # Find the extracted directory
    $sourceDir = Get-ChildItem -Path $env:TEMP -Filter "node-v$nodeVersion-win-x64" -Directory | Select-Object -First 1
    if (-not $sourceDir) {
        throw "Extracted directory not found"
    }
    $sourceDir = $sourceDir.FullName
    Write-Host "Extracted to: $sourceDir" -ForegroundColor Gray
    
    Write-Host "Backing up current installation..." -ForegroundColor Cyan
    
    # Backup current installation (skip locked files)
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupPath = "D:\node_backup_$timestamp"
    if (Test-Path "D:\node") {
        Copy-Item -Path "D:\node" -Destination $backupPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Backup saved to: $backupPath" -ForegroundColor Gray
    }
    
    Write-Host "Checking for running Node.js processes..." -ForegroundColor Cyan
    $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
    if ($nodeProcesses) {
        Write-Host "Warning: Found running Node.js processes. Attempting to close them..." -ForegroundColor Yellow
        $nodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
    
    Write-Host "Updating D:\node\ directory..." -ForegroundColor Cyan
    
    # Files to replace (keep npm global packages)
    $filesToReplace = @("node.exe", "npm", "npm.cmd", "npx", "npx.cmd", "node_etw_provider.man", "nodevars.bat", "corepack", "corepack.cmd")
    
    foreach ($file in $filesToReplace) {
        $filePath = "D:\node\$file"
        if (Test-Path $filePath) {
            # Try to remove with retry
            $maxRetries = 3
            $retryCount = 0
            $removed = $false
            while (-not $removed -and $retryCount -lt $maxRetries) {
                try {
                    Remove-Item $filePath -Force -ErrorAction Stop
                    $removed = $true
                } catch {
                    $retryCount++
                    if ($retryCount -lt $maxRetries) {
                        Write-Host "Waiting for file to be released (attempt $retryCount/$maxRetries)..." -ForegroundColor Yellow
                        Start-Sleep -Seconds 1
                        # Try closing processes again
                        Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            if (-not $removed) {
                Write-Host "Warning: Could not remove $file, will try to overwrite..." -ForegroundColor Yellow
            }
        }
    }
    
    # Copy new files (this will overwrite existing files)
    Write-Host "Copying new files..." -ForegroundColor Cyan
    Copy-Item -Path "$sourceDir\*" -Destination "D:\node\" -Recurse -Force -ErrorAction Stop
    
    Write-Host "`nUpdate complete!" -ForegroundColor Green
    Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
    
    # Cleanup
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    if ($sourceDir -and (Test-Path $sourceDir)) {
        Remove-Item $sourceDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "`nVerifying new version..." -ForegroundColor Cyan
    $newVersion = & "D:\node\node.exe" -v
    Write-Host "New version: $newVersion" -ForegroundColor Green
    
    Write-Host "`nUpdate successful! Please restart your terminal." -ForegroundColor Green
    Write-Host "Backup location: $backupPath" -ForegroundColor Yellow
    
} catch {
    Write-Host "`nUpdate failed: $_" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

