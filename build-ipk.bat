@echo off
REM EzWoL Windows 构建脚本 (使用 WSL)
REM 需要安装 WSL (Windows Subsystem for Linux)

echo ========================================
echo EzWoL Windows 构建工具 (WSL)
echo ========================================
echo.

REM 检查 WSL 是否可用
wsl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未检测到 WSL
    echo 请先安装 WSL: https://docs.microsoft.com/zh-cn/windows/wsl/install
    pause
    exit /b 1
)

echo 检测到 WSL，准备构建...
echo.

REM 转换 Windows 路径到 WSL 路径
set "CURRENT_DIR=%CD%"
set "WSL_PATH=%CURRENT_DIR:\=/%"
set "WSL_PATH=/mnt/%WSL_PATH:~0,1%%WSL_PATH:~2%"

echo 当前目录: %CURRENT_DIR%
echo WSL 路径: %WSL_PATH%
echo.

REM 在 WSL 中运行构建脚本
echo 开始构建 IPK 包...
wsl bash -c "cd '%WSL_PATH%' && chmod +x build-ipk.sh && ./build-ipk.sh"

if %errorlevel% neq 0 (
    echo.
    echo 构建失败！
    pause
    exit /b 1
)

echo.
echo ========================================
echo 构建成功！
echo ========================================
echo.
echo IPK 文件位于: build\ezwol_1.0.0-1_all.ipk
echo.
echo 下一步:
echo   1. 将 IPK 文件复制到路由器
echo   2. 在路由器上执行: opkg install ezwol_1.0.0-1_all.ipk
echo.
echo 或者使用部署脚本:
echo   wsl bash deploy-ipk.sh root@192.168.1.1
echo ========================================
pause
