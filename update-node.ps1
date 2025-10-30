# Node.js 更新脚本
# 用于更新 D:\node\ 目录下的 Node.js 到最新版本

Write-Host "正在检查最新版本的 Node.js..." -ForegroundColor Cyan

# 获取最新版本号
$latestVersion = npm view node version
Write-Host "最新版本: v$latestVersion" -ForegroundColor Green

# 确认当前版本
$currentVersion = node -v
Write-Host "当前版本: $currentVersion" -ForegroundColor Yellow

if ($currentVersion -eq "v$latestVersion") {
    Write-Host "`n您已经安装了最新版本，无需更新！" -ForegroundColor Green
    exit 0
}

# 确认是否继续
$confirm = Read-Host "`n是否更新到 v$latestVersion? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "已取消更新" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n正在下载 Node.js v$latestVersion..." -ForegroundColor Cyan

# 构建下载 URL (Windows x64)
$nodeVersion = $latestVersion
$downloadUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-win-x64.zip"
$zipPath = "$env:TEMP\node-v$nodeVersion-win-x64.zip"
$extractPath = "$env:TEMP\node-v$nodeVersion-win-x64"

try {
    # 下载
    Write-Host "下载地址: $downloadUrl" -ForegroundColor Gray
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    
    Write-Host "下载完成，正在解压..." -ForegroundColor Cyan
    
    # 解压
    if (Test-Path $extractPath) {
        Remove-Item $extractPath -Recurse -Force
    }
    Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force
    
    Write-Host "解压完成，正在备份当前安装..." -ForegroundColor Cyan
    
    # 备份当前安装
    $backupPath = "D:\node_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    if (Test-Path "D:\node") {
        Copy-Item -Path "D:\node" -Destination $backupPath -Recurse -Force
        Write-Host "已备份到: $backupPath" -ForegroundColor Gray
    }
    
    Write-Host "正在更新 D:\node\ 目录..." -ForegroundColor Cyan
    
    # 删除旧的 node.exe 和相关文件（保留 npm 全局包）
    $filesToReplace = @("node.exe", "npm", "npm.cmd", "npx", "npx.cmd", "node_etw_provider.man", "nodevars.bat", "corepack", "corepack.cmd")
    
    foreach ($file in $filesToReplace) {
        if (Test-Path "D:\node\$file") {
            Remove-Item "D:\node\$file" -Force -ErrorAction SilentlyContinue
        }
    }
    
    # 复制新文件
    $sourceDir = "$extractPath\node-v$nodeVersion-win-x64"
    Copy-Item -Path "$sourceDir\*" -Destination "D:\node\" -Recurse -Force
    
    Write-Host "`n更新完成！" -ForegroundColor Green
    Write-Host "清理临时文件..." -ForegroundColor Cyan
    
    # 清理临时文件
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "`n验证新版本..." -ForegroundColor Cyan
    $newVersion = & "D:\node\node.exe" -v
    Write-Host "新版本: $newVersion" -ForegroundColor Green
    
    Write-Host "`n更新成功！请重新打开终端以使更改生效。" -ForegroundColor Green
    Write-Host "`n提示: 备份目录在 $backupPath，如果遇到问题可以恢复。" -ForegroundColor Yellow
    
} catch {
    Write-Host "`n更新失败: $_" -ForegroundColor Red
    Write-Host "错误详情: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

