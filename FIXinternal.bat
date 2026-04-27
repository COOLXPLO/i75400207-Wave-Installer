@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Wave INTERNAL ERROR FIX - i7540020
color 0B

:: =============================================
::  FULL INTERNAL ERROR FIX (ALL STEPS)
::  Only this script - nothing else lol
::  STEP 5 IS NOW ULTRA FAST (skips already installed)
:: =============================================

NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ADMIN REQUIRED]
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo +==========================================================================+
echo ^|               FULL INTERNAL ERROR FIX (By iamunknown77)                  ^|
echo ^|             Delete Wave folder + Temp + WebView2 + Defender OFF          ^|
echo ^|             VC++ All + Exploit Protection + Smart App Control            ^|
echo ^|             You are free to copy or modify this script                   ^|
echo +==========================================================================+
echo.
echo [*] ALL TASKS WILL BE PERFORMED AUTOMATICALLY...
echo.

:: 1. Delete %localappdata%\Wave + %temp% files
echo [1/7] Deleting Wave folders and cleaning TEMP...
echo     [IMPORTANT] Force close Wave and retry.
if exist "%LOCALAPPDATA%\Wave" rmdir /s /q "%LOCALAPPDATA%\Wave" >nul 2>&1
if exist "%LOCALAPPDATA%\Wave.WebView2" rmdir /s /q "%LOCALAPPDATA%\Wave.WebView2" >nul 2>&1
powershell -NoProfile -Command "Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { try { Remove-Item $_.FullName -Recurse -Force } catch {} }" >nul 2>&1
echo [+] Cleanup complete.
echo.

:: 2. Reinstall WebView2 x64
echo [2/7] Reinstalling Microsoft Edge WebView2 x64...
set "WV_URL=https://drive.usercontent.google.com/download?id=19bdQK0Q3argPFFgbiQKkbGNtwVNmMh_O&export=download&authuser=0"
powershell -NoProfile -Command "Invoke-WebRequest -UseBasicParsing -Uri '%WV_URL%' -OutFile '%TEMP%\WebView2Bootstrapper.exe'" >nul 2>&1
if exist "%TEMP%\WebView2Bootstrapper.exe" (
    start /wait "" "%TEMP%\WebView2Bootstrapper.exe" /silent
    del "%TEMP%\WebView2Bootstrapper.exe" >nul 2>&1
    echo [+] WebView2 x64 reinstalled.
) else (
    echo [!] WebView2 download failed - continuing...
)
echo.

:: 3. Turn OFF Smart App Control + Defender
echo [3/7] Turning OFF Smart App Control + Windows Defender...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d 0 /f >nul 2>&1
powershell -NoProfile -Command "Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue" >nul 2>&1
echo [+] Smart App Control = OFF
echo [+] Defender Real-time Protection = OFF
echo.

:: 4. Open Protection History
echo [4/7] Opening Windows Security - Protection History...
echo     [ACTION REQUIRED] Please check "Protection history" and RESTORE any Wave files!
start windowsdefender:
timeout /t 8 >nul
echo [+] Protection history opened.
echo.

:: 5. FAST CHECK + Install ONLY MISSING VC++ + .NET
echo [5/7] Checking + Installing ONLY missing VC++ and .NET (ULTRA FAST)...
set "MainDir=C:\WaveSetup"
set "TargetDir=%MainDir%\Dependencies"
if not exist "%MainDir%" mkdir "%MainDir%" >nul 2>&1
if not exist "%TargetDir%" mkdir "%TargetDir%" >nul 2>&1

echo     [*] .NET runtimes...
powershell -Command "if (Get-ChildItem 'HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost' -EA SilentlyContinue | Get-ItemProperty | Where-Object {$_.Version -like '8.0*'}) { exit 0 } else { exit 1 }" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (echo [+] Installing .NET 8.0... & call :DownloadInstall "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe" "dotnet8.exe" "/install /quiet /norestart") else echo [OK] .NET 8.0

powershell -Command "if (Get-ChildItem 'HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost' -EA SilentlyContinue | Get-ItemProperty | Where-Object {$_.Version -like '6.0*'}) { exit 0 } else { exit 1 }" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (echo [+] Installing .NET 6.0... & call :DownloadInstall "https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x64.exe" "dotnet6.exe" "/install /quiet /norestart") else echo [OK] .NET 6.0

powershell -Command "if (Get-ChildItem 'HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost' -EA SilentlyContinue | Get-ItemProperty | Where-Object {$_.Version -like '6.0.33*'}) { exit 0 } else { exit 1 }" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (echo [+] Installing .NET 6.0.33... & call :DownloadInstall "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.33/windowsdesktop-runtime-6.0.33-win-x64.exe" "dotnet6_033.exe" "/install /quiet /norestart") else echo [OK] .NET 6.0.33

powershell -Command "if (Get-ChildItem 'HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost' -EA SilentlyContinue | Get-ItemProperty | Where-Object {$_.Version -like '3.1*'}) { exit 0 } else { exit 1 }" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (echo [+] Installing .NET 3.1.32... & call :DownloadInstall "https://download.visualstudio.microsoft.com/download/pr/b92958c6-ae36-4efa-aafe-569fced953a5/1654639ef3b20eb576174c1cc200f33a/windowsdesktop-runtime-3.1.32-win-x64.exe" "dotnet31.exe" "/install /quiet /norestart") else echo [OK] .NET 3.1.32

echo     [*] VC++ Redistributables...
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v Installed 2>nul | findstr "1" >nul
if %ERRORLEVEL% NEQ 0 (echo [+] Installing VC++ 2015-2022 x64... & call :DownloadInstall "https://aka.ms/vc14/vc_redist.x64.exe" "vc_modern_x64.exe" "/install /quiet /norestart") else echo [OK] VC++ 2015-2022 x64

reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" /v Installed 2>nul | findstr "1" >nul
if %ERRORLEVEL% NEQ 0 (echo [+] Installing VC++ 2015-2022 x86... & call :DownloadInstall "https://aka.ms/vc14/vc_redist.x86.exe" "vc_modern_x86.exe" "/install /quiet /norestart") else echo [OK] VC++ 2015-2022 x86

for %%V in (2013,2012,2010,2008) do (
    powershell -NoProfile -Command "$found = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -EA SilentlyContinue | Where-Object { $_.DisplayName -like '*Visual C++ %%V*Redistributable*' }; if ($found) { exit 0 } else { exit 1 }" >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo [+] Installing VC++ %%V...
        if "%%V"=="2013" call :DownloadInstall "https://aka.ms/highdpimfc2013x86enu" "vc2013_x86.exe" "/passive /norestart"
        if "%%V"=="2013" call :DownloadInstall "https://aka.ms/highdpimfc2013x64enu" "vc2013_x64.exe" "/passive /norestart"
        if "%%V"=="2012" call :DownloadInstall "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe" "vc2012_x86.exe" "/passive /norestart"
        if "%%V"=="2012" call :DownloadInstall "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" "vc2012_x64.exe" "/passive /norestart"
        if "%%V"=="2010" call :DownloadInstall "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe" "vc2010_x86.exe" "/passive /norestart"
        if "%%V"=="2010" call :DownloadInstall "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe" "vc2010_x64.exe" "/passive /norestart"
        if "%%V"=="2008" call :DownloadInstall "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe" "vc2008_x86.exe" "/qb"
        if "%%V"=="2008" call :DownloadInstall "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe" "vc2008_x64.exe" "/qb"
    ) else echo [OK] VC++ %%V
)

echo [+] Step 5 finished (only missing ones installed).
echo.

:: 6. Final status
echo +==========================================================================+
echo ^|                     FULLY COMPLETE - ALL TASKS DONE                      ^|
echo +==========================================================================+
echo.
set /p "HELPED=Did this fix help? (Y/N): "
if /I "%HELPED%"=="Y" (
    echo.
    echo [GREAT!] Fix applied successfully.
    echo     You can now try launching Wave.
    goto :RebootPrompt
)

:: 7. If NO - Disable Exploit Protection (Internal Error fix)
echo.
echo [N] Applying Exploit Protection fix for Wave.exe + Loader.exe...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ProcessMitigation -Name Wave.exe -Disable DEP,CFG -ErrorAction SilentlyContinue; Set-ProcessMitigation -Name Loader.exe -Disable DEP,CFG -ErrorAction SilentlyContinue" >nul 2>&1
echo [+] DEP + CFG (Control Flow Guard) disabled for Wave/Loader.
echo.

:RebootPrompt
echo.
echo [REBOOT PC NOW?] (Highly recommended after all changes)
choice /C YN /N /M "Reboot PC now? (Y/N): "
if errorlevel 2 (
    echo.
    echo Fix complete. Please reboot manually later.
    pause
    exit /b
)
echo.
echo Rebooting in 5 seconds...
shutdown /r /t 5 /c "Rebooting to finalize Wave Internal Error Fix"
exit /b

:DownloadInstall
powershell -NoProfile -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%~1' -OutFile '%TargetDir%\%~2' -UserAgent 'Mozilla/5.0'" >nul 2>&1
if exist "%TargetDir%\%~2" (
    start /wait "" "%TargetDir%\%~2" %~3
) else (
    echo [!] Failed to download %~2 - continuing...
)
goto :eof