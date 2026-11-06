@echo off
chcp 936 >nul 2>&1
setlocal EnableExtensions
title 百度网盘“智能看图”卸载脚本
color 07

:: 出处：https://xzonn.top/posts/Remove-Intelligent-Image-Viewer.html
:: 本脚本用于删除百度网盘捆绑的“智能看图”组件。

echo ==========================================
echo 百度网盘“智能看图”功能卸载脚本
echo ==========================================
echo.
echo 此脚本将删除百度网盘捆绑的“智能看图”软件：
echo   - 删除相关注册表项
echo   - 删除 ImageViewer 程序目录
echo.
echo 不会删除百度网盘主程序。
echo 请确保以管理员身份运行此脚本。
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo [错误] 当前不是管理员权限。
    echo 请右键点击此脚本，选择“以管理员身份运行”。
    pause
    exit /b 1
)

pause

set "FAIL=0"

echo 正在删除注册表项...
echo.
call :delkey "HKEY_CLASSES_ROOT\BaiduNetdiskImageViewerAssociations"
if errorlevel 1 set "FAIL=1"
call :delkey "HKEY_CURRENT_USER\Software\Baidu\BaiduNetdiskImageViewer"
if errorlevel 1 set "FAIL=1"
call :delval "HKEY_CURRENT_USER\Software\RegisteredApplications" "BaiduNetdiskImageViewer"
if errorlevel 1 set "FAIL=1"
echo.

echo 正在删除程序文件...
set "IMAGEVIEWER_PATH=%APPDATA%\baidu\BaiduNetdisk\module\ImageViewer"
if exist "%IMAGEVIEWER_PATH%" (
    echo 找到程序目录: %IMAGEVIEWER_PATH%
    rmdir /s /q "%IMAGEVIEWER_PATH%" >nul 2>&1
    if exist "%IMAGEVIEWER_PATH%" (
        echo [失败] 程序文件删除失败，可能文件正在使用中
        echo 请手动删除: %IMAGEVIEWER_PATH%
        set "FAIL=1"
    ) else (
        echo [成功] 程序文件已删除
    )
) else (
    echo 程序目录不存在或已被删除
)
echo.

echo ==========================================
if "%FAIL%"=="0" (
    echo 卸载完成！
) else (
    echo 卸载完成，但存在失败项。
)
echo ==========================================
echo.
echo 建议重启计算机以确保所有更改生效。
echo 如果问题仍然存在，请检查：
echo   %APPDATA%\baidu\BaiduNetdisk\module\ImageViewer
echo.
echo 按任意键退出...
pause >nul
exit /b 0

:delkey
reg query "%~1" >nul 2>&1
if errorlevel 1 (
    echo     [跳过] 不存在: %~1
    exit /b 0
)
reg delete "%~1" /f >nul 2>&1
if errorlevel 1 (
    echo     [失败] 无法删除: %~1
    exit /b 1
)
echo     [成功] 已删除: %~1
exit /b 0

:delval
reg query "%~1" /v "%~2" >nul 2>&1
if errorlevel 1 (
    echo     [跳过] 不存在: %~1 -^> %~2
    exit /b 0
)
reg delete "%~1" /v "%~2" /f >nul 2>&1
if errorlevel 1 (
    echo     [失败] 无法删除: %~1 -^> %~2
    exit /b 1
)
echo     [成功] 已删除: %~1 -^> %~2
exit /b 0
