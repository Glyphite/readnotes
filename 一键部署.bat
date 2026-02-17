@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo        网站一键部署工具 v1.0
echo ========================================
echo.

REM 检查当前目录是否是Git仓库
if not exist ".git" (
    echo [错误] 当前目录不是Git仓库！
    echo 请将此脚本放在您的项目根目录下运行。
    pause
    exit /b 1
)

REM 设置颜色
set "color_green=[92m"
set "color_yellow=[93m"
set "color_red=[91m"
set "color_reset=[0m"

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
    
    git commit -m "自动部署：%datepart% %timepart% 更新"
    
    if !errorlevel! equ 0 (
        echo   提交成功！提交信息：自动部署：%datepart% %timepart% 更新
    ) else (
        echo   提交失败，可能是提交信息冲突或无实际更改。
        echo   尝试使用空提交继续...
        git commit --allow-empty -m "空提交：触发部署"
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
echo   正在推送到 GitHub (main 分支)...

REM 尝试获取远程分支信息
git ls-remote --exit-code github main >nul 2>&1
if !errorlevel! equ 0 (
    echo   检测到 github 远程仓库，开始推送...
    
    REM 显示推送前最后提交
    echo   最后提交信息：
    git log -1 --oneline
    
    REM 执行推送
    git push github main
    
    if !errorlevel! equ 0 (
        echo   ✓ 推送成功！
        echo.
        echo   ========================================
        echo   部署流程完成！
        echo   ========================================
        echo.
        echo   Vercel 将自动检测到代码更新并重新部署。
        echo   请访问您的 Vercel 仪表板查看部署状态。
        echo.
        
        REM 尝试打开浏览器查看 Vercel 项目
        echo   是否要打开 Vercel 项目页面？(Y/N)
        set /p open_vercel=
        if /i "!open_vercel!"=="Y" (
            start https://vercel.com/dashboard
        )
    ) else (
        echo   ✗ 推送失败，错误代码: !errorlevel!
        echo   尝试强制推送？(Y/N - 注意：这可能会覆盖远程更改)
        set /p force_push=
        if /i "!force_push!"=="Y" (
            echo   执行强制推送...
            git push -f github main
            if !errorlevel! equ 0 (
                echo   ✓ 强制推送成功！
            ) else (
                echo   ✗ 强制推送失败！
            )
        )
    )
) else (
    echo   ✗ 未找到 github 远程仓库或 main 分支
    echo   请检查远程仓库配置：
    git remote -v
    echo.
    echo   是否要添加 github 远程仓库？(Y/N)
    set /p add_remote=
    if /i "!add_remote!"=="Y" (
        echo   请输入 GitHub 仓库URL（例如：https://github.com/用户名/仓库名.git）：
        set /p repo_url=
        if not "!repo_url!"=="" (
            git remote add github "!repo_url!"
            if !errorlevel! equ 0 (
                echo   远程仓库添加成功！
                echo   请重新运行此脚本。
            )
        )
    )
)

REM 步骤5：显示部署状态摘要
echo.
echo [步骤5] 部署状态摘要
echo ========================================
echo 本地分支：    master/main
echo 远程仓库：    github
echo 目标分支：    main
echo 推送状态：    %errorlevel%
echo 时间戳：      %date% %time%
echo ========================================

REM 如果使用 Gitee，也同步推送
echo.
echo   是否要同时推送到 Gitee？(Y/N)
set /p push_gitee=
if /i "!push_gitee!"=="Y" (
    echo   检查 Gitee 远程仓库...
    git ls-remote --exit-code origin main >nul 2>&1
    if !errorlevel! equ 0 (
        echo   推送到 Gitee (origin/main)...
        git push origin main
        if !errorlevel! equ 0 (
            echo   ✓ Gitee 推送成功！
        ) else (
            echo   ✗ Gitee 推送失败！
        )
    ) else (
        echo   ✗ 未找到 origin 远程仓库
    )
)

echo.
echo 按任意键退出...
pause >nul
