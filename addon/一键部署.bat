@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo          Git 一键同步脚本
echo ========================================
echo.

REM 检查是否为Git仓库
git status >nul 2>&1
if errorlevel 1 (
    echo 错误: 当前目录不是Git仓库。
    pause
    exit /b 1
)

REM 添加所有更改
echo 添加更改...
git add .
if errorlevel 1 (
    echo 错误: 添加文件失败。
    pause
    exit /b 1
)

REM 提交更改
set "default_msg=更新于 %date% %time%"
set /p commit_msg="提交信息(回车默认='%default_msg%'): "
if "!commit_msg!"=="" set "commit_msg=!default_msg!"
git commit -m "!commit_msg!"
if errorlevel 1 (
    echo 提示: 无新更改可提交，或提交失败。
)

REM 推送到远程
echo 推送...
git push
if errorlevel 1 (
    echo 错误: 推送失败。
    pause
    exit /b 1
)

echo.
echo [Git同步] 完成。
pause