# 简化版 Node.js 更新脚本
# 直接使用官方安装包更新

Write-Host "=== Node.js 更新工具 ===" -ForegroundColor Cyan
Write-Host ""

# 获取最新版本
$latestVersion = npm view node dist-tags.latest
Write-Host "最新版本: v$latestVersion" -ForegroundColor Green

$currentVersion = node -v
Write-Host "当前版本: $currentVersion" -ForegroundColor Yellow

if ($currentVersion -eq "v$latestVersion") {
    Write-Host "`n已是最新版本，无需更新！" -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "请按照以下步骤手动更新:" -ForegroundColor Cyan
Write-Host "1. 访问: https://nodejs.org/zh-cn/download/" -ForegroundColor White
Write-Host "2. 下载 Windows Installer (.msi) 最新版本" -ForegroundColor White
Write-Host "3. 运行安装程序，选择安装到: D:\node\" -ForegroundColor White
Write-Host "4. 或者在安装时更改安装路径" -ForegroundColor White
Write-Host ""

# 自动打开下载页面
$confirm = Read-Host "是否现在打开下载页面? (Y/N)"
if ($confirm -eq "Y" -or $confirm -eq "y") {
    Start-Process "https://nodejs.org/zh-cn/download/"
}

