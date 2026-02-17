@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo          Git 一键同步脚本
echo ========================================
echo.

REM 1. 显示当前状态
echo [步骤1/4] 检查Git状态...
git status
if %errorlevel% neq 0 (
    echo 错误: 当前目录不是Git仓库或Git未正确配置。
    pause
    exit /b 1
)
echo.

REM 2. 添加所有更改
echo [步骤2/4] 添加所有更改到暂存区...
git add .
if %errorlevel% neq 0 (
    echo 错误: 添加文件时出错。
    pause
    exit /b 1
)
echo 所有更改已暂存。
echo.

REM 3. 提交更改
echo [步骤3/4] 提交更改...
set "commit_msg=自动提交于 %date% %time%"
set /p user_msg="请输入提交信息（直接回车将使用'%commit_msg%'）: "
if not "!user_msg!"=="" set "commit_msg=!user_msg!"
git commit -m "!commit_msg!"
if %errorlevel% neq 0 (
    echo 注意: 提交可能失败（可能无更改可提交）。继续尝试推送...
)
echo.

REM 4. 推送到远程仓库
echo [步骤4/4] 推送到远程仓库...
git push
if %errorlevel% neq 0 (
    echo 错误: 推送失败。请检查网络或远程仓库设置。
    pause
    exit /b 1
)
echo.
echo ========================================
echo         同步完成！
echo ========================================
echo.
pause
