@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo         Git一键同步工具 v1.1
echo ========================================
echo.

REM 配置您的Git仓库路径
set "GIT_REPO_PATH=C:\Users\Administrator\Documents\glyphite-message"

REM 检查配置的路径是否存在
if not exist "!GIT_REPO_PATH!" (
    echo [错误] 配置的Git仓库路径不存在：!GIT_REPO_PATH!
    pause
    exit /b 1
)

REM 切换到Git仓库目录
echo [信息] 正在切换到Git仓库目录：!GIT_REPO_PATH!
cd /d "!GIT_REPO_PATH!"

REM 检查当前目录是否是Git仓库
if not exist ".git" (
    echo [错误] 当前目录不是Git仓库！
    echo 当前目录：%cd%
    pause
    exit /b 1
)

REM 显示当前仓库信息
for /f "tokens=*" %%i in ('git remote -v') do (
    echo 远程仓库: %%i
)
echo.

REM 步骤1：检查是否有未提交的更改
echo [步骤1] 检查工作区状态...
git status --porcelain >nul 2>&1
if errorlevel 1 (
    echo   工作区干净，没有需要提交的更改。
    set "has_changes=0"
) else (
    echo   发现未提交的更改。
    set "has_changes=1"
)

REM 步骤2：添加所有更改
if "!has_changes!"=="1" (
    echo [步骤2] 添加所有更改到暂存区...
    git add .
    if !errorlevel! equ 0 (
        echo   添加成功！
    ) else (
        echo   添加失败，请检查错误信息。
        pause
        exit /b 1
    )
) else (
    echo [步骤2] 跳过添加步骤（无更改）
)

REM 步骤3：提交更改
if "!has_changes!"=="1" (
    echo [步骤3] 提交更改...
    
    REM 生成自动提交信息（包含日期时间）
    for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "datetime=%%I"
    set "datepart=!datetime:~0,4!-!datetime:~4,2!-!datetime:~6,2!"
    set "timepart=!datetime:~8,2!:!datetime:~10,2!:!datetime:~12,2!"
    
    set "default_msg=自动同步：%datepart% %timepart%"
    set /p user_msg="   请输入提交信息（直接回车使用默认'%default_msg%'）："
    
    if "!user_msg!"=="" (
        git commit -m "%default_msg%"
    ) else (
        git commit -m "!user_msg!"
    )
    
    if !errorlevel! equ 0 (
        if "!user_msg!"=="" (
            echo   提交成功！提交信息：%default_msg%
        ) else (
            echo   提交成功！提交信息：!user_msg!
        )
    ) else (
        echo   提交失败，可能是提交信息冲突或无实际更改。
        echo   尝试使用空提交继续...
        git commit --allow-empty -m "空提交：触发同步"
        if !errorlevel! neq 0 (
            echo   空提交也失败，请手动检查。
            pause
            exit /b 1
        )
    )
) else (
    echo [步骤3] 跳过提交步骤（无更改）
)

REM 步骤4：推送到远程仓库
echo [步骤4] 推送到远程仓库...
echo   正在推送到远程仓库 (main 分支)...

REM 尝试获取远程分支信息
git ls-remote --exit-code origin main >nul 2>&1
if !errorlevel! equ 0 (
    echo   检测到 origin 远程仓库，开始推送...
    
    REM 显示推送前最后提交
    echo   最后提交信息：
    git log -1 --oneline
    
    REM 执行推送
    git push origin main
    
    if !errorlevel! equ 0 (
        echo   推送成功！
        echo.
        echo   ========================================
        echo   同步流程完成！
        echo   ========================================
    ) else (
        echo   推送失败，错误代码: !errorlevel!
        echo   尝试强制推送？(Y/N - 注意：这可能会覆盖远程更改)
        set /p force_push=
        if /i "!force_push!"=="Y" (
            echo   执行强制推送...
            git push -f origin main
            if !errorlevel! equ 0 (
                echo   强制推送成功！
            ) else (
                echo   强制推送失败！
            )
        )
    )
) else (
    echo   未找到 origin 远程仓库或 main 分支
    echo   请检查远程仓库配置：
    git remote -v
    echo.
    echo   是否要添加远程仓库？(Y/N)
    set /p add_remote=
    if /i "!add_remote!"=="Y" (
        echo   请输入远程仓库URL（例如：https://github.com/用户名/仓库名.git）：
        set /p repo_url=
        if not "!repo_url!"=="" (
            git remote add origin "!repo_url!"
            if !errorlevel! equ 0 (
                echo   远程仓库添加成功！
                echo   请重新运行此脚本。
            )
        )
    )
)

REM 步骤5：显示同步状态摘要
echo.
echo [步骤5] 同步状态摘要
echo ========================================
echo 仓库路径：    !GIT_REPO_PATH!
echo 本地分支：    main
echo 远程仓库：    origin
echo 目标分支：    main
echo 推送状态：    %errorlevel%
echo 时间戳：      %date% %time%
echo ========================================

echo.
echo 按任意键退出...
pause >nul