@echo off
chcp 65001 >nul
title Git一键上传工具
echo ========================================
echo            Git一键上传工具
echo ========================================
echo.

:: 检查当前目录是否是一个Git仓库
git status >nul 2>&1
if errorlevel 1 (
    echo [错误] 当前目录不是一个Git仓库！
    echo 请确保在包含 .git 文件夹的目录下运行此脚本。
    pause
    exit /b 1
)

:: 显示当前仓库和分支信息
for /f "tokens=*" %%i in ('git config --get remote.origin.url') do set REMOTE_URL=%%i
for /f "tokens=*" %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i
echo 仓库地址: %REMOTE_URL%
echo 当前分支: %CURRENT_BRANCH%
echo.

:: 检查是否有未跟踪或修改的文件
git status --porcelain | findstr /r "^[?MADRCU]" >nul
if errorlevel 1 (
    echo 暂存区和工作目录是干净的，没有需要提交的更改。
    goto :PUSH_ONLY
) else (
    echo 检测到以下待提交的更改：
    git status -s
    echo.
)

:: 步骤1：添加所有更改到暂存区
echo 步骤1：正在添加所有更改到暂存区 (git add .)...
git add .
if errorlevel 1 (
    echo [错误] git add 执行失败！
    pause
    exit /b 1
)
echo 添加成功。
echo.

:: 步骤2：提交更改
:COMMIT
set /p COMMIT_MSG="步骤2：请输入本次提交的描述信息 (直接回车将使用默认信息): "
if "%COMMIT_MSG%"=="" (
    set COMMIT_MSG="自动提交：%date% %time%"
    echo 将使用默认提交信息: %COMMIT_MSG%
)

echo 正在提交更改 (git commit -m %COMMIT_MSG%)...
git commit -m %COMMIT_MSG%
if errorlevel 1 (
    echo [警告] 提交失败，可能因为提交信息为空或没有实质更改。
    echo 是否重新输入提交信息？(Y/N)
    set /p RETRY=
    if /i "%RETRY%"=="Y" goto COMMIT
    echo 跳过提交步骤。
    echo.
    goto :PUSH
)
echo 提交成功。
echo.

:: 步骤3：推送到远程仓库
:PUSH
echo 步骤3：正在推送到远程仓库 (git push origin %CURRENT_BRANCH%)...
git push origin %CURRENT_BRANCH%
if errorlevel 1 (
    echo [错误] 推送失败！请检查网络连接或远程仓库权限。
    pause
    exit /b 1
)
echo 推送成功！
echo.
goto :SUCCESS

:PUSH_ONLY
echo 未发现本地新提交，尝试直接与远程仓库同步...
git pull origin %CURRENT_BRANCH%
git push origin %CURRENT_BRANCH%
if errorlevel 1 (
    echo [错误] 推送失败！
    pause
    exit /b 1
)
echo 同步并推送成功！
echo.

:SUCCESS
echo ========================================
echo           操作已完成！
echo ========================================
echo 所有更改已成功上传至：%REMOTE_URL% (%CURRENT_BRANCH%)
pause
