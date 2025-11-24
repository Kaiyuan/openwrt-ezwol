@echo off
REM Git 初始化脚本 (Windows)

echo ========================================
echo EzWoL GitHub 初始化脚本
echo ========================================
echo.

REM 检查 Git 是否安装
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未检测到 Git
    echo 请先安装 Git: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM 检查是否已经是 Git 仓库
if exist ".git" (
    echo 检测到已存在的 Git 仓库
    set /p "REINIT=是否要重新初始化? (y/N): "
    if /i "%REINIT%"=="y" (
        rmdir /s /q .git
        echo 已删除旧的 Git 仓库
    ) else (
        echo 保留现有 Git 仓库
    )
)

echo.
echo 请输入您的 GitHub 仓库地址
echo 格式: https://github.com/username/openwrt-ezwol.git
set /p "REPO_URL=仓库地址: "

if "%REPO_URL%"=="" (
    echo 错误: 仓库地址不能为空
    pause
    exit /b 1
)

echo.
echo 1. 初始化 Git 仓库...
git init

echo 2. 添加文件到 Git...
git add .

echo 3. 创建初始提交...
git commit -m "Initial commit: EzWoL OpenWRT Wake-on-LAN plugin"

echo 4. 设置主分支为 main...
git branch -M main

echo 5. 添加远程仓库...
git remote add origin %REPO_URL%

echo 6. 推送到 GitHub...
echo.
set /p "PUSH=是否现在推送到 GitHub? (Y/n): "
if /i not "%PUSH%"=="n" (
    git push -u origin main
    
    echo.
    echo ========================================
    echo 推送成功！
    echo ========================================
    echo.
    echo 下一步：
    echo   1. 访问: %REPO_URL%
    echo   2. 查看 Actions 标签页，等待自动编译完成
    echo   3. 在 Artifacts 中下载编译好的 IPK 包
    echo.
    echo 创建版本发布：
    echo   git tag v1.0.0
    echo   git push origin v1.0.0
    echo.
    echo 详细说明请查看: GITHUB.md
    echo ========================================
) else (
    echo.
    echo ========================================
    echo Git 仓库已配置
    echo ========================================
    echo.
    echo 稍后手动推送：
    echo   git push -u origin main
    echo.
    echo 或创建标签并推送：
    echo   git tag v1.0.0
    echo   git push origin main
    echo   git push origin v1.0.0
    echo ========================================
)

pause
