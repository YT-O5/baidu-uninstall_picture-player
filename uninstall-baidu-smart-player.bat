@echo off
chcp 936 >nul 2>&1
setlocal EnableExtensions EnableDelayedExpansion
title 百度网盘“智能播放器”卸载脚本
color 07

:: 说明：清理百度网盘捆绑的“智能播放器”组件。
:: 根据公开资料与实测整理；注册表项和文件路径可能随百度网盘版本变化。

set "FAIL=0"
set "BACKUP_DIR=%~dp0registry-backup"
set "PF86=%ProgramFiles(x86)%"
set "PLAYER_EXE=BaiduNetdiskPlayerLaunch.exe"

:: 智能播放器接管的媒体文件类型（根据公开资料与实测整理）
set "EXTS=.264 .265 .3g2 .3gp .avc .avi .avs .avs2 .avs3 .bik .bk2 .dav .dif .dv .evc .f4v .flv .h261 .h263 .h264 .h265 .h26l .hevc .ifv .ism .ismv .j2k .kux .m2t .m2ts .m2v .mj2 .mjpg .mk3d .mkv .moflex .mov .mp4 .mpeg .mpg .mts .mxf .mxg .nsv .obu .pdv .pmp .psp .r3d .rcv .rm .rmvb .roq .smk .str .swf .tmv .ts .ty .ty+ .usm .v .v210 .vc1 .viv .vob .vpk .vvc .webm .wmv .wtv .xmv .y4m .yop .yuv .yuv10 .aac .ac3 .aif .amr .ape .flac .m4a .mid .midi .mp2 .mp3 .ogg .wav .wma .jpg .jpeg .png .gif .bmp .webp .tif .tiff .ico .jfif .avif .heic .heif .svg"

echo ==========================================
echo 百度网盘“智能播放器”功能卸载脚本
echo ==========================================
echo.
echo 此脚本将删除百度网盘捆绑的“智能播放器”组件：
echo   - 播放器注册的文件关联和右键菜单
echo   - 播放器程序文件 BaiduNetdiskPlayerLaunch.exe
echo.
echo 不会删除百度网盘主程序，也不会删除主程序共享的
echo BrowserEngine 目录。
echo.
echo 注意：脚本会结束“智能播放器”进程，但不会关闭
echo 百度网盘主程序。如果删除文件失败，请先退出网盘。
echo.
echo 请确保以管理员身份运行此脚本。
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo [错误] 当前不是管理员权限。
    echo.
    echo 请右键点击此脚本，选择“以管理员身份运行”。
    echo.
    pause
    exit /b 1
)

pause

echo.
:: 先读取注册表，保存播放器的实际路径（后面删除注册表项后仍可使用）
set "TMPPATH=%TEMP%\baidu_player_path.txt"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$k='Registry::HKEY_CLASSES_ROOT\BaiduNetdiskPlayerAssociations\shell\open\command'; $c=(Get-ItemProperty -Path $k -ErrorAction SilentlyContinue).'(default)'; if($c){ $c=$c.Trim(); $q=[char]34; if($c.StartsWith($q)){ $c=$c.Substring(1); $i=$c.IndexOf($q); if($i -gt 0){ $c=$c.Substring(0,$i) } } else { $c=($c -split ' ')[0] }; $c }" > "%TMPPATH%" 2>nul
set "PLAYER_PATH="
set /p PLAYER_PATH=<"%TMPPATH%"
del /f /q "%TMPPATH%" >nul 2>&1

echo [1/5] 正在结束“智能播放器”进程...
taskkill /f /im "%PLAYER_EXE%" >nul 2>&1
if errorlevel 1 (
    echo     未发现正在运行的播放器进程
) else (
    echo     已结束播放器进程
)
taskkill /f /im "BaiduNetdiskPlayer.exe" >nul 2>&1
echo.

echo [2/5] 正在备份相关注册表...
if not exist "%BACKUP_DIR%" md "%BACKUP_DIR%" >nul 2>&1
call :backup "HKCR\BaiduNetdiskPlayerAssociations" "BaiduNetdiskPlayerAssociations.reg"
call :backup "HKCR\Applications\BaiduNetdiskPlayer.open" "BaiduNetdiskPlayer.open.reg"
call :backup "HKCU\Software\Baidu\BaiduNetdiskPlayer" "BaiduNetdiskPlayer.reg"
call :backup "HKCU\Software\RegisteredApplications" "RegisteredApplications_HKCU.reg"
echo.

echo [3/5] 正在删除注册表项...
call :delkey "HKCR\BaiduNetdiskPlayerAssociations"
if errorlevel 1 set "FAIL=1"
call :delkey "HKCR\Applications\BaiduNetdiskPlayer.open"
if errorlevel 1 set "FAIL=1"
call :delkey "HKCR\Applications\BaiduNetdiskPlayer"
if errorlevel 1 set "FAIL=1"
call :delkey "HKLM\Software\Classes\BaiduNetdiskPlayerAssociations"
if errorlevel 1 set "FAIL=1"
call :delkey "HKLM\Software\Classes\Applications\BaiduNetdiskPlayer.open"
if errorlevel 1 set "FAIL=1"
call :delkey "HKLM\Software\Classes\Applications\BaiduNetdiskPlayer"
if errorlevel 1 set "FAIL=1"
call :delkey "HKLM\Software\WOW6432Node\Classes\BaiduNetdiskPlayerAssociations"
if errorlevel 1 set "FAIL=1"
call :delkey "HKLM\Software\WOW6432Node\Classes\Applications\BaiduNetdiskPlayer.open"
if errorlevel 1 set "FAIL=1"
call :delkey "HKCU\Software\Classes\BaiduNetdiskPlayerAssociations"
if errorlevel 1 set "FAIL=1"
call :delkey "HKCU\Software\Classes\Applications\BaiduNetdiskPlayer.open"
if errorlevel 1 set "FAIL=1"
call :delkey "HKCU\Software\Classes\Applications\BaiduNetdiskPlayer"
if errorlevel 1 set "FAIL=1"
call :delkey "HKCU\Software\Baidu\BaiduNetdiskPlayer"
if errorlevel 1 set "FAIL=1"
call :delval "HKCU\Software\RegisteredApplications" "BaiduNetdiskPlayer"
if errorlevel 1 set "FAIL=1"
call :delval "HKLM\Software\RegisteredApplications" "BaiduNetdiskPlayer"
if errorlevel 1 set "FAIL=1"
echo.

echo [4/5] 正在清理文件关联...
set "ASSOC_FOUND=0"
for %%E in (!EXTS!) do (
    reg delete "HKCR\%%E\OpenWithList\BaiduNetdiskPlayer.open" /f >nul 2>&1
    reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%%E\UserChoice" /v ProgId 2>nul | findstr /i "BaiduNetdiskPlayer" >nul
    if not errorlevel 1 (
        reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%%E\UserChoice" /f >nul 2>&1
        echo     已清除默认关联: %%E
        set "ASSOC_FOUND=1"
    )
)
if "!ASSOC_FOUND!"=="0" echo     没有发现指向播放器的默认关联
echo.

echo [5/5] 正在删除播放器程序文件...
set "FOUND_FILE=0"

if defined PLAYER_PATH (
    if exist "!PLAYER_PATH!" (
        set "FOUND_FILE=1"
        echo     找到注册表记录的播放器: !PLAYER_PATH!
        del /f /q "!PLAYER_PATH!" >nul 2>&1
        if exist "!PLAYER_PATH!" (
            echo     [失败] 文件正在使用或权限不足
            set "FAIL=1"
        ) else (
            echo     [成功] 已删除播放器程序文件
        )
    )
)

for %%R in ("!APPDATA!\baidu\BaiduNetdisk" "!LOCALAPPDATA!\Baidu\BaiduNetdisk" "%ProgramFiles%\Baidu\BaiduNetdisk" "!PF86!\Baidu\BaiduNetdisk" "D:\BaiduNetdisk") do (
    if exist "%%~R\module\BrowserEngine\%PLAYER_EXE%" (
        set "FOUND_FILE=1"
        echo     找到: %%~R\module\BrowserEngine\%PLAYER_EXE%
        del /f /q "%%~R\module\BrowserEngine\%PLAYER_EXE%" >nul 2>&1
        if exist "%%~R\module\BrowserEngine\%PLAYER_EXE%" (
            echo     [失败] 文件正在使用或权限不足
            set "FAIL=1"
        ) else (
            echo     [成功] 已删除播放器程序文件
        )
    )
)
if "!FOUND_FILE!"=="0" (
    echo     未找到播放器程序文件
    echo     可能已经删除，或百度网盘安装在其它位置
)
echo.

echo ==========================================
echo 卸载完成
echo ==========================================
echo.
if "!FAIL!"=="0" (
    echo 所有操作均已完成。
) else (
    echo 部分操作失败，请查看上面的提示。
)
echo 注册表备份位于:
echo   !BACKUP_DIR!
echo.
echo 建议重启电脑，使右键菜单和默认应用完全生效。
echo.
echo 注意：百度网盘更新后可能会重新下载该组件。
echo 建议在百度网盘“设置”中取消相关的默认关联选项。
echo.
echo 如果仍有残留，请检查以下目录：
echo   %%APPDATA%%\baidu\BaiduNetdisk\module\BrowserEngine
echo   %%LOCALAPPDATA%%\Baidu\BaiduNetdisk\module\BrowserEngine
echo.
echo 如需同时清理“智能看图”，请使用对应的卸载脚本。
echo.
pause
exit /b 0

:backup
set "BK_KEY=%~1"
set "BK_FILE=%~2"
reg query "%BK_KEY%" >nul 2>&1
if errorlevel 1 exit /b 0
reg export "%BK_KEY%" "%BACKUP_DIR%\%BK_FILE%" /y >nul 2>&1
if errorlevel 1 (
    echo     [提示] 备份失败: %BK_KEY%
) else (
    echo     [成功] 已备份: %BK_FILE%
)
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
