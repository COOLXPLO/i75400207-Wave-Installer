@echo off
setlocal EnableExtensions EnableDelayedExpansion
::  Copyright (c) 2026 i75400207
::  All rights reserved.
::
::  Unauthorized copying, modification, or redistribution
::  of this script, in whole or in part, is strictly prohibited.

set "CURRENT_VER=2.4.7"
set "RAW_VER=https://raw.githubusercontent.com/redyfoxsyr0/Fixwater/refs/heads/main/version.txt"
set "RAW_BAT=https://raw.githubusercontent.com/redyfoxsyr0/Fixwater/refs/heads/main/FixWave.bat"

for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP=%%D"
set "NEWFILE=%DESKTOP%\FixWave.bat"
set "LATEST_VER="

for /f "usebackq delims=" %%V in (`
  powershell -NoProfile -Command ^
  "try { (Invoke-WebRequest -UseBasicParsing '%RAW_VER%').Content.Trim() } catch { '' }"
`) do set "LATEST_VER=%%V"

if not defined LATEST_VER goto :after_update
if "%LATEST_VER%"=="%CURRENT_VER%" goto :after_update

echo [UPDATE] %CURRENT_VER% -> %LATEST_VER%
echo [UPDATE] Downloading new version...
powershell -NoProfile -Command ^
  "Invoke-WebRequest -UseBasicParsing '%RAW_BAT%' -OutFile '%NEWFILE%'"

if not exist "%NEWFILE%" (
    echo [UPDATE][FAIL] Download blocked
    pause
    goto :after_update
)

copy /y "%NEWFILE%" "%~f0" >nul
del "%DESKTOP%\version.txt" >nul 2>&1
del "%DESKTOP%\%LATEST_VER%" >nul 2>&1
del "%DESKTOP%\%CURRENT_VER%" >nul 2>&1
for /f "delims=" %%F in ('dir /b "%DESKTOP%" ^| findstr /R "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$"') do (
    del "%DESKTOP%\%%F" >nul 2>&1
)
del "%DESKTOP%\version.txt" >nul 2>&1

echo [UPDATE] Update applied successfully.
echo [UPDATE] Relaunching...
start "" "%~f0"
exit /b

:after_update

title RedFox Wave Installer - v3.0
color 0B

set "WINMAJOR="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command ^
  "$v=[Environment]::OSVersion.Version.Major; if($v){$v}"`
) do set "WINMAJOR=%%V"

if defined WINMAJOR (
    for /f "delims=0123456789" %%Z in ("%WINMAJOR%") do set "WINMAJOR="
)
if defined WINMAJOR if %WINMAJOR% GEQ 10 (
    reg query "HKCU\Console" >nul 2>&1 || reg add "HKCU\Console" >nul
    reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)

set "SELF=%~f0"
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ ! ] Requesting admin rights...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Start-Process -FilePath '%SELF%' -Verb RunAs -ArgumentList @('-elevated')"
    exit /b
)

if /I "%~1"=="-elevated" shift

set "TargetDir=C:\WaveSetup"
set "InstallerPath=%TargetDir%\Wave.exe"
set "WaveURL=https://getwave.gg/downloads/Wave.exe"

goto mainmenu

:CreateDesktopShortcut
set "SC_TARGET=%~1"
set "SC_NAME=%~2"
if not exist "%SC_TARGET%" (
    echo [Error] Target missing: "%SC_TARGET%"
    pause
    goto :eof
)
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESK=%%D"
set "LNK=%DESK%\%SC_NAME%.lnk"
echo [*] Desktop resolved to: "%DESK%"
echo [*] Creating shortcut: "%LNK%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$w=New-Object -ComObject WScript.Shell; $s=$w.CreateShortcut('%LNK%'); $s.TargetPath='%SC_TARGET%'; $s.WorkingDirectory=(Split-Path '%SC_TARGET%'); $s.IconLocation='%SC_TARGET%,0'; $s.Save()"
if exist "%LNK%" (
    echo [Success] Shortcut created!
) else (
    echo [Error] Shortcut not found at "%LNK%"
)
goto :eof

:mainmenu
cls
echo.
echo +==========================================================================+
echo ^|                         i75400207 WAVE INSTALLER                         ^|
echo ^|                      (Install. Repair. Move on.)                         ^|
echo ^|             Copyright (c) 2026 i75400207 All rights reserved.            ^|
echo +==========================================================================+
echo ^| [1] Install Wave                                                         ^|
echo ^| [2] Fix Module Error                                                     ^|
echo ^| [3] Fix loader Error / Initializing Issue                                ^|
echo ^| [4] Fix Dependencies (Reinstalls files needed to run wave)               ^|
echo ^| [5] Fix Failed to Generate HWID - Invalid Class                          ^|
echo ^| [6] Fix Invalid License / Expired License Error                          ^|
echo ^| [7] Install Cloudflare WARP (VPN/ISP Bypass)                             ^|
echo ^| [8] Whitelist Wave to Anti-Virus (Defender)                              ^|
echo ^| [9] Install Roblox Bootstrapper                                          ^|
echo +==========================================================================+
echo ^| [X] Exit                                                                 ^|
echo +==========================================================================+
echo.
set /p "MAINCHOICE=Choose option: "

if /I "%MAINCHOICE%"=="1" goto install_wave
if /I "%MAINCHOICE%"=="2" goto Fix_Module_Error
if /I "%MAINCHOICE%"=="3" goto Loader_fix
if /I "%MAINCHOICE%"=="4" goto Auto_Fix_Runtimes
if /I "%MAINCHOICE%"=="5" goto Auto_Fix_HWID
if /I "%MAINCHOICE%"=="6" goto TIME_DNS_FIX
if /I "%MAINCHOICE%"=="7" goto install_warp
if /I "%MAINCHOICE%"=="8" goto DEFENDER_EXCLUSIONS
if /I "%MAINCHOICE%"=="9" goto boot_menu
if /I "%MAINCHOICE%"=="X" exit /b

echo Invalid choice. Try again.
timeout /t 2 >nul
goto mainmenu

:install_wave
cls
echo +==========================================================================+
echo ^|                          INSTALLING WAVE                              111 ^|
echo +==========================================================================+
echo.

:: --- Admin Check ---
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [!] Admin rights required.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: --- Paths and Config ---
set "WAVE_INSTALL=C:\WaveSetup"
set "WAVE_DIR=%LOCALAPPDATA%\Wave"
set "WAVE_WEBVIEW=%LOCALAPPDATA%\Wave.WebView2"
set "WAVE_ZIP_URL=https://getwave.gg/downloads/Wave.zip"
set "TEMP_ZIP=%TEMP%\Wave.zip"
set "EXTRACT_TEMP=%TEMP%\WaveExtract"

:: --- Cleanup & Exclusions ---
echo [+] Applying Windows Defender exclusions...
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%WAVE_INSTALL%','%WAVE_DIR%','%WAVE_WEBVIEW%' -ErrorAction SilentlyContinue"

echo [*] Cleaning up old processes...
taskkill /f /im "Wave.exe" /im "Wave-Setup.exe" /im "Roblox.exe" >nul 2>&1

if not exist "%WAVE_INSTALL%" mkdir "%WAVE_INSTALL%"

:: --- Dependency Check (All Versions) ---
echo.
echo [*] Checking Dependencies...
echo.

:: .NET 8.0
powershell -Command "if (Get-ChildItem 'HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost' -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {$_.Version -like '8.0*'}) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo [+] Installing .NET 8.0...
    call :DownloadInstall "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe" "dotnet8.exe" "/install /quiet /norestart"
) else ( echo [OK] .NET 8.0 detected. )

:: .NET 6.0
powershell -Command "if (Get-ChildItem 'HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost' -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {$_.Version -like '6.0*'}) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo [+] Installing .NET 6.0...
    call :DownloadInstall "https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x64.exe" "dotnet6.exe" "/install /quiet /norestart"
) else ( echo [OK] .NET 6.0 detected. )

:: VC++ 2015-2022 (x64)
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v "Installed" | findstr "1" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [+] Installing VC++ 2015-2022...
    call :DownloadInstall "https://aka.ms/vc14/vc_redist.x64.exe" "vc_modern_x64.exe" "/install /quiet /norestart"
) else ( echo [OK] VC++ 2015-2022 detected. )

:: Universal Checker for Older VC++ (2013, 2012, 2010, 2008)
for %%V in (2013,2012,2010,2008) do (
    powershell -NoProfile -Command "$found = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like '*Visual C++ %%V*Redistributable (x64)*' }; if ($found) { exit 0 } else { exit 1 }"
    if %ERRORLEVEL% EQU 0 (
        echo [OK] VC++ %%V x64 detected.
    ) else (
        echo [+] Missing VC++ %%V. Installing...
        if "%%V"=="2013" call :DownloadInstall "https://aka.ms/highdpimfc2013x64enu" "vc2013_x64.exe" "/passive /norestart"
        if "%%V"=="2012" call :DownloadInstall "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" "vc2012_x64.exe" "/passive /norestart"
        if "%%V"=="2010" call :DownloadInstall "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe" "vc2010_x64.exe" "/passive /norestart"
        if "%%V"=="2008" call :DownloadInstall "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe" "vc2008_x64.exe" "/qb"
    )
)

:: WebView2Loader
if not exist "%WAVE_INSTALL%\WebView2Loader.dll" (
    echo [+] Downloading WebView2Loader...
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/redyfoxsyr0/Fixwater/releases/download/oryourdumb/WebView2Loader.dll' -OutFile '%WAVE_INSTALL%\WebView2Loader.dll'"
)

:: --- Download and Extract Wave ---
echo.
echo [*] Downloading Wave Update...
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%WAVE_ZIP_URL%' -OutFile '%TEMP_ZIP%'"

echo [*] Extracting and organizing files...
if exist "%EXTRACT_TEMP%" rmdir /s /q "%EXTRACT_TEMP%"
powershell -NoProfile -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%EXTRACT_TEMP%' -Force"

:: Moves contents of the 'Wave' folder inside the zip directly to C:\WaveSetup
xcopy /e /y /h /i "%EXTRACT_TEMP%\Wave\*" "%WAVE_INSTALL%\" >nul

:: Cleanup Zip/Temp
rmdir /s /q "%EXTRACT_TEMP%"
del /f /q "%TEMP_ZIP%"

:: --- Final Launch ---
if exist "%WAVE_INSTALL%\Wave.exe" (
    echo [Success] Wave updated in %WAVE_INSTALL%
    call :CreateDesktopShortcut "%WAVE_INSTALL%\Wave.exe" "Wave"
    start "" "%WAVE_INSTALL%\Wave.exe"
) else (
    echo [ERROR] Wave.exe not found after extraction!
    pause
)

timeout /t 5 >nul
goto boot_menu

:DEFENDER_EXCLUSIONS
cls
set "WAVE_INSTALL=C:\WaveSetup"
set "WAVE_DIR=%LOCALAPPDATA%\Wave"
set "WAVE_WEBVIEW=%LOCALAPPDATA%\Wave.WebView2"
set "WAVE_LOADER=%LOCALAPPDATA%\Wave\Loader.exe"

echo [+] Adding Windows Defender exclusions:
echo     %WAVE_INSTALL%
echo     %WAVE_DIR%
echo     %WAVE_WEBVIEW%
echo     %WAVE_LOADER%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"try { ^
  Add-MpPreference -ExclusionPath '%WAVE_INSTALL%' -ErrorAction Stop; ^
  Add-MpPreference -ExclusionPath '%WAVE_DIR%' -ErrorAction Stop; ^
  Add-MpPreference -ExclusionPath '%WAVE_WEBVIEW%' -ErrorAction Stop; ^
  if (Test-Path '%WAVE_LOADER%') { Add-MpPreference -ExclusionProcess '%WAVE_LOADER%' -ErrorAction Stop } ^
  Write-Host '[OK] Exclusions added.' ^
} catch { ^
  Write-Host '[FAIL]' $_.Exception.Message ^
  exit 1 ^
}"
if %errorlevel% neq 0 (
  echo.
  echo [!] Defender exclusions failed.
  echo     - If you are using a stripped Windows build, Defender cmdlets may be missing.
  echo     - If Tamper Protection is on, exclusions may be blocked.
  pause
  goto mainmenu
)

echo.
echo [+] All Defender exclusions applied!
pause
goto mainmenu

:Fix_Module_Error
cls
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [!] Admin rights required.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs -ArgumentList @('-elevated')"
    exit /b
)

set "WAVE_INSTALL=C:\WaveSetup"
set "WAVE_DIR=%LOCALAPPDATA%\Wave"
set "WAVE_WEBVIEW=%LOCALAPPDATA%\Wave.WebView2"
echo [+] Adding Windows Defender exclusions:
echo     %WAVE_INSTALL%
echo     %WAVE_DIR%
echo     %WAVE_WEBVIEW%
echo.
powershell -NoProfile -Command ^
"Add-MpPreference -ExclusionPath '%WAVE_INSTALL%' -ErrorAction SilentlyContinue; ^
 Add-MpPreference -ExclusionPath '%WAVE_DIR%' -ErrorAction SilentlyContinue; ^
 Add-MpPreference -ExclusionPath '%WAVE_WEBVIEW%' -ErrorAction SilentlyContinue"

echo [+] Defender exclusions applied.
echo.
echo [*] Fixing Wave Module...
echo.

set "MODULE_URL=https://github.com/redyfoxsyr0/Fixwater/releases/download/oryourdumb/Module.zip"
set "ZIP_NAME=Wave_Module.zip"
set "DEST_DIR=%LOCALAPPDATA%"
set "WAVE_DIR=%DEST_DIR%\Wave"
set "WV2_DIR=%DEST_DIR%\Wave.WebView2"
echo [*] Target folder: "%DEST_DIR%"
echo.

echo [*] Stopping Wave processes...
taskkill /f /im Wave.exe >nul 2>&1
taskkill /f /im msedgewebview2.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
timeout /t 2 >nul

echo [*] Removing old Wave folders...
if exist "%WAVE_DIR%" (
    echo     - Deleting "%WAVE_DIR%"
    rmdir /s /q "%WAVE_DIR%"
)
if exist "%WV2_DIR%" (
    echo     - Deleting "%WV2_DIR%"
    rmdir /s /q "%WV2_DIR%"
)

if exist "%WAVE_DIR%" (
    echo [ERROR] Failed to delete "%WAVE_DIR%"
    pause
    goto mainmenu
)
if exist "%WV2_DIR%" (
    echo [ERROR] Failed to delete "%WV2_DIR%"
    pause
    goto mainmenu
)

echo [*] Cleanup complete.
echo.
echo [*] Downloading module...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Invoke-WebRequest -Uri '%MODULE_URL%' -OutFile '%DEST_DIR%\%ZIP_NAME%'"

if not exist "%DEST_DIR%\%ZIP_NAME%" (
    echo [ERROR] Download failed.
    pause
    goto mainmenu
)

echo [*] Extracting module...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Expand-Archive -Force '%DEST_DIR%\%ZIP_NAME%' '%DEST_DIR%'"

del "%DEST_DIR%\%ZIP_NAME%" >nul 2>&1
echo.

echo [*] Fixing permissions for Wave folders...
if exist "%WAVE_DIR%" (
  takeown /f "%WAVE_DIR%" /r /d y >nul 2>&1
)
if exist "%WV2_DIR%" (
  takeown /f "%WV2_DIR%" /r /d y >nul 2>&1
)
if exist "%WAVE_DIR%" (
  icacls "%WAVE_DIR%" /inheritance:e /T /C >nul 2>&1
)
if exist "%WV2_DIR%" (
  icacls "%WV2_DIR%" /inheritance:e /T /C >nul 2>&1
)
if exist "%WAVE_DIR%" (
  icacls "%WAVE_DIR%" /grant "%USERNAME%:(OI)(CI)F" /T /C >nul 2>&1
)
if exist "%WV2_DIR%" (
  icacls "%WV2_DIR%" /grant "%USERNAME%:(OI)(CI)F" /T /C >nul 2>&1
)

echo [+] Permissions applied to:
echo     %WAVE_DIR%
echo     %WV2_DIR%
echo.
sc stop PcaSvc >nul 2>&1
sc config PcaSvc start= disabled >nul 2>&1
echo [*] Wave module fixed successfully.
echo [*] Launching Wave...

echo [*] Looking for Wave...
set "WAVE_FOUND="

if exist "%USERPROFILE%\Desktop\wave.lnk" (
    echo     - Found Desktop shortcut: wave.lnk
    start "" "%USERPROFILE%\Desktop\wave.lnk"
    goto :LaunchDone
)

for %%P in (
  "%USERPROFILE%\Desktop\wave.exe"
  "%USERPROFILE%\Downloads\wave.exe"
  "%LOCALAPPDATA%\wave\wave.exe"
  "%LOCALAPPDATA%\Wave\wave.exe"
  "C:\WaveSetup\Wave.exe"
) do (
  if exist "%%~P" (
    set "WAVE_FOUND=%%~P"
    goto :WaveExeFound
  )
)

:WaveExeFound
if defined WAVE_FOUND (
    echo     - Found Wave exe: "%WAVE_FOUND%"
    start "" "%WAVE_FOUND%"
    goto :LaunchDone
)

for %%S in (
  "%APPDATA%\Microsoft\Windows\Start Menu\Programs\wave.lnk"
  "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\wave.lnk"
) do (
  if exist "%%~S" (
    echo     - Found Start Menu shortcut: "%%~S"
    start "" "%%~S"
    goto :LaunchDone
  )
)

echo [*] Not found in common locations. Scanning C:\ for wave.exe (this may take a bit)...
for /f "delims=" %%F in ('where /r C:\ wave.exe 2^>nul') do (
    set "WAVE_FOUND=%%F"
    goto :WaveExeFound2
)

:WaveExeFound2
if defined WAVE_FOUND (
    echo     - Found by scan: "%WAVE_FOUND%"
    start "" "%WAVE_FOUND%"
    goto :LaunchDone
)

echo [WARN] Wave not found (no wave.lnk or wave.exe detected).
echo        Put wave.exe in Desktop/Downloads/%%LOCALAPPDATA%%\wave, or install to C:\WaveSetup.
timeout /t 3 >nul
goto mainmenu

:Loader_fix
cls
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [!] Admin rights required.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs -ArgumentList @('-elevated')"
    exit /b
)

set "WAVE_INSTALL=C:\WaveSetup"
set "WAVE_DIR=%LOCALAPPDATA%\Wave"
set "WAVE_WEBVIEW=%LOCALAPPDATA%\Wave.WebView2"
echo [+] Adding Windows Defender exclusions:
echo     %WAVE_INSTALL%
echo     %WAVE_DIR%
echo     %WAVE_WEBVIEW%
echo     %LOCALAPPDATA%\Wave\Loader.exe
echo.
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%WAVE_INSTALL%','%WAVE_DIR%','%WAVE_WEBVIEW%' -ErrorAction SilentlyContinue; if (Test-Path '%LOCALAPPDATA%\Wave\Loader.exe') { Add-MpPreference -ExclusionProcess '%LOCALAPPDATA%\Wave\Loader.exe' -ErrorAction SilentlyContinue }"
echo [+] Defender exclusions applied.
echo.
echo [*] Fixing Wave Loader...
echo.
echo [*] Stopping Wave processes...
taskkill /f /im Wave.exe >nul 2>&1
taskkill /f /im msedgewebview2.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
timeout /t 2 >nul

set "WAVE_LOADER_DIR=%LOCALAPPDATA%\wave"
set "ZIP_URL=https://github.com/redyfoxsyr0/Fixwater/releases/download/oryourdumb/Loader.zip"
set "ZIP_PATH=%TEMP%\Loader.zip"
if not exist "%WAVE_LOADER_DIR%" mkdir "%WAVE_LOADER_DIR%"

echo [*] Downloading Loader.zip...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"try { ^
  Invoke-WebRequest -UseBasicParsing -Uri '%ZIP_URL%' -OutFile '%ZIP_PATH%' -ErrorAction Stop; ^
  exit 0 ^
} catch { ^
  Write-Host '[ERROR] Download failed:' $_.Exception.Message; ^
  exit 1 ^
}"

if errorlevel 1 (
    echo [ERROR] Failed to download Loader.zip
    echo        URL:  %ZIP_URL%
    echo        Path: %ZIP_PATH%
    pause
    goto mainmenu
)

if not exist "%ZIP_PATH%" (
    echo [ERROR] Download reported success but file is missing.
    echo        Path: %ZIP_PATH%
    pause
    goto mainmenu
)

for %%A in ("%ZIP_PATH%") do echo [*] Downloaded bytes: %%~zA
echo.
echo [*] Extracting Loader...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"try { ^
  Expand-Archive -Force '%ZIP_PATH%' '%WAVE_LOADER_DIR%' -ErrorAction Stop; ^
  exit 0 ^
} catch { ^
  Write-Host '[ERROR] Extract failed:' $_.Exception.Message; ^
  exit 1 ^
}"

del "%ZIP_PATH%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Extraction failed.
    pause
    goto mainmenu
)

echo.
echo [*] Fixing permissions for Loader/Wave folders...
if exist "%WAVE_LOADER_DIR%" (
  takeown /f "%WAVE_LOADER_DIR%" /r /d y >nul 2>&1
)
if exist "%WAVE_DIR%" (
  takeown /f "%WAVE_DIR%" /r /d y >nul 2>&1
)
if exist "%WAVE_WEBVIEW%" (
  takeown /f "%WAVE_WEBVIEW%" /r /d y >nul 2>&1
)
if exist "%WAVE_LOADER_DIR%" (
  icacls "%WAVE_LOADER_DIR%" /inheritance:e /T /C >nul 2>&1
)
if exist "%WAVE_DIR%" (
  icacls "%WAVE_DIR%" /inheritance:e /T /C >nul 2>&1
)
if exist "%WAVE_WEBVIEW%" (
  icacls "%WAVE_WEBVIEW%" /inheritance:e /T /C >nul 2>&1
)
if exist "%WAVE_LOADER_DIR%" (
  icacls "%WAVE_LOADER_DIR%" /grant "%USERNAME%:(OI)(CI)F" /T /C >nul 2>&1
)
if exist "%WAVE_DIR%" (
  icacls "%WAVE_DIR%" /grant "%USERNAME%:(OI)(CI)F" /T /C >nul 2>&1
)
if exist "%WAVE_WEBVIEW%" (
  icacls "%WAVE_WEBVIEW%" /grant "%USERNAME%:(OI)(CI)F" /T /C >nul 2>&1
)
echo [+] Permissions applied to:
echo     %WAVE_LOADER_DIR%
echo     %WAVE_DIR%
echo     %WAVE_WEBVIEW%
echo.

set "FOUND_LOADER="
for /r "%WAVE_LOADER_DIR%" %%F in (Loader.exe) do (
    set "FOUND_LOADER=%%F"
    goto :LoaderFound
)

:LoaderFound
if defined FOUND_LOADER (
    echo [+] Loader installed: "%FOUND_LOADER%"
) else (
    echo [ERROR] Loader.exe not found after extraction.
    echo [*] Files containing "loader" under "%WAVE_LOADER_DIR%":
    dir /s /b "%WAVE_LOADER_DIR%" | findstr /i "loader"
    pause
    goto mainmenu
)
sc stop PcaSvc >nul 2>&1
sc config PcaSvc start= disabled >nul 2>&1
echo.
echo [*] Looking for Wave...

set "WAVE_FOUND="
if exist "%USERPROFILE%\Desktop\wave.lnk" (
    echo     - Found Desktop shortcut: wave.lnk
    start "" "%USERPROFILE%\Desktop\wave.lnk"
    goto :LaunchDone
)

for %%P in (
  "%USERPROFILE%\Desktop\wave.exe"
  "%USERPROFILE%\Downloads\wave.exe"
  "%LOCALAPPDATA%\wave\wave.exe"
  "%LOCALAPPDATA%\Wave\wave.exe"
  "C:\WaveSetup\Wave.exe"
) do (
  if exist "%%~P" (
    set "WAVE_FOUND=%%~P"
    goto :WaveExeFound_L
  )
)

:WaveExeFound_L
if defined WAVE_FOUND (
    echo     - Found Wave exe: "%WAVE_FOUND%"
    start "" "%WAVE_FOUND%"
    goto :LaunchDone
)

for %%S in (
  "%APPDATA%\Microsoft\Windows\Start Menu\Programs\wave.lnk"
  "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\wave.lnk"
) do (
  if exist "%%~S" (
    echo     - Found Start Menu shortcut: "%%~S"
    start "" "%%~S"
    goto :LaunchDone
  )
)

echo [*] Not found in common locations. Scanning C:\ for wave.exe (this may take a bit)...
for /f "delims=" %%F in ('where /r C:\ wave.exe 2^>nul') do (
    set "WAVE_FOUND=%%F"
    goto :WaveExeFound2_L
)

:WaveExeFound2_L
if defined WAVE_FOUND (
    echo     - Found by scan: "%WAVE_FOUND%"
    start "" "%WAVE_FOUND%"
    goto :LaunchDone
)

echo [WARN] Wave not found (no wave.lnk or wave.exe detected).
echo        Put wave.exe in Desktop/Downloads/%%LOCALAPPDATA%%\wave, or install to C:\WaveSetup.
timeout /t 3 >nul
goto mainmenu

:install_warp
cls
echo +==========================================================================+
echo ^|                  INSTALLING CLOUDFLARE WARP (VPN)                        ^|
echo +==========================================================================+
echo.
if not exist "%TargetDir%" mkdir "%TargetDir%"
echo [*] Downloading...
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://1111-releases.cloudflareclient.com/windows/Cloudflare_WARP_Release-x64.msi' -OutFile '%TargetDir%\warp.msi'"
if not exist "%TargetDir%\warp.msi" (
    echo [Error] Download failed.
    pause
    goto mainmenu
)
echo [*] Installing...
start /wait msiexec /i "%TargetDir%\warp.msi" /quiet /norestart
set "WarpCliPath=%ProgramFiles%\Cloudflare\Cloudflare WARP\warp-cli.exe"
if exist "%WarpCliPath%" (
    "%WarpCliPath%" registration new >nul
    "%WarpCliPath%" mode warp >nul
    "%WarpCliPath%" connect >nul
    echo [Success] WARP connected!
) else (
    echo [Error] Installed but cli missing.
)
pause
goto mainmenu

:TIME_DNS_FIX
cls
color 0B
echo ==========================================
echo   Time Clock Sync + DNS Flush
echo ==========================================
echo.
echo [1/3] Enabling Windows Time service...
sc config w32time start= auto >nul 2>&1
net start w32time >nul 2>&1
echo [2/3] Forcing time resync...
w32tm /resync /force >nul 2>&1
powershell -NoProfile -Command "Set-Date (Get-Date)" >nul 2>&1
echo [+] Time synchronization complete.
echo.
echo [3/3] Flushing DNS cache...
ipconfig /flushdns
echo.
echo ==========================================
echo   Fix complete.
echo   If license errors persist, reboot.
echo ==========================================
echo.
pause
goto mainmenu

:Auto_Fix_HWID
cls
set "NEED_REBOOT=0"
echo ==========================================
echo   Auto Fix HWID - WMI Repair Tool
echo ==========================================
echo.
echo [1] Testing HWID via CIM...
powershell -NoProfile -Command ^
"$u=(Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue).UUID; ^
 if($u){Write-Host '[OK] UUID:' $u; exit 0} else {exit 1}"
IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [*] HWID is already working. No fix needed.
    pause
    goto mainmenu
)

echo [!] HWID failed. Starting repair...
echo.
echo [2] Verifying WMI repository...
winmgmt /verifyrepository | find /I "inconsistent" >nul
IF %ERRORLEVEL% EQU 0 (
    echo [!] Repository inconsistent. Salvaging...
    winmgmt /salvagerepository
    set "NEED_REBOOT=1"
) ELSE (
    echo [OK] Repository appears consistent (still may be missing classes).
)

echo.
echo [3] Re-testing HWID after salvage...
powershell -NoProfile -Command ^
"$u=(Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue).UUID; ^
 if($u){Write-Host '[OK] UUID:' $u; exit 0} else {exit 1}"
IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [*] Fixed without rebuild.
    echo.
    if "%NEED_REBOOT%"=="1" (
        echo [!] Recommended: reboot to fully reload WMI providers.
        choice /C YN /N /M "Reboot now? (Y/N): "
        if errorlevel 2 goto mainmenu
        shutdown /r /t 5 /c "Auto Fix HWID - Rebooting to finalize WMI repair"
        exit /b
    ) else (
        pause
        goto mainmenu
    )
)

echo.
echo [4] Rebuilding WMI repository (safe rename)...
set "NEED_REBOOT=1"
net stop winmgmt /y >nul 2>&1
if exist "%windir%\System32\wbem\Repository" (
    ren "%windir%\System32\wbem\Repository" Repository.old_%RANDOM%
)
net start winmgmt >nul 2>&1
echo.
echo [5] Repairing system files (DISM + SFC)...
DISM /Online /Cleanup-Image /RestoreHealth
sfc /scannow
echo.
echo [6] Re-registering WMI components...
cd /d %windir%\System32\wbem
for %%i in (*.dll) do regsvr32 /s %%i
for %%i in (*.mof *.mfl) do mofcomp %%i
echo.
echo ==========================================
echo   Repair complete.
echo   Reboot is REQUIRED to finish.
echo ==========================================
echo.
choice /C YN /N /M "Reboot now? (Y/N): "
if errorlevel 2 goto mainmenu
shutdown /r /t 5 /c "Auto Fix HWID - Completing WMI repair"
exit /b

:Auto_Fix_Runtimes
cls
echo +==========================================================================+
echo ^|                    FULL DEPENDENCY INSTALLER                           ^|
echo +==========================================================================+
echo.
set "MainDir=C:\WaveSetup"
set "TargetDir=%MainDir%\Dependencies"
if not exist "%MainDir%" mkdir "%MainDir%"
if not exist "%TargetDir%" mkdir "%TargetDir%"
echo [*] Removing NODE_OPTIONS...
reg delete "HKCU\Environment" /F /V NODE_OPTIONS >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V NODE_OPTIONS >nul 2>&1
echo.
echo [*] Downloading to: %TargetDir%
echo.
echo [+] Installing .NET 8.0 Desktop Runtime...
call :DownloadInstall "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe" "dotnet8.exe" "/install /quiet /norestart"
echo [+] Installing .NET 6.0 Desktop Runtime...
call :DownloadInstall "https://aka.ms/dotnet/6.0/windowsdesktop-runtime-win-x64.exe" "dotnet6.exe" "/install /quiet /norestart"
echo [+] Installing .NET 3.1.32 Desktop Runtime...
call :DownloadInstall "https://download.visualstudio.microsoft.com/download/pr/b92958c6-ae36-4efa-aafe-569fced953a5/1654639ef3b20eb576174c1cc200f33a/windowsdesktop-runtime-3.1.32-win-x64.exe" "dotnet31.exe" "/install /quiet /norestart"
echo [+] Installing VC++ 2015-2022 x86...
call :DownloadInstall "https://aka.ms/vc14/vc_redist.x86.exe" "vc_modern_x86.exe" "/install /quiet /norestart"
echo [+] Installing VC++ 2015-2022 x64...
call :DownloadInstall "https://aka.ms/vc14/vc_redist.x64.exe" "vc_modern_x64.exe" "/install /quiet /norestart"
echo [+] Installing VC++ 2013 x86...
call :DownloadInstall "https://aka.ms/highdpimfc2013x86enu" "vc2013_x86.exe" "/passive /norestart"
echo [+] Installing VC++ 2013 x64...
call :DownloadInstall "https://aka.ms/highdpimfc2013x64enu" "vc2013_x64.exe" "/passive /norestart"
echo [+] Installing VC++ 2012 x86...
call :DownloadInstall "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe" "vc2012_x86.exe" "/passive /norestart"
echo [+] Installing VC++ 2012 x64...
call :DownloadInstall "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" "vc2012_x64.exe" "/passive /norestart"
echo [+] Installing VC++ 2010 x86...
call :DownloadInstall "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe" "vc2010_x86.exe" "/passive /norestart"
echo [+] Installing VC++ 2010 x64...
call :DownloadInstall "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe" "vc2010_x64.exe" "/passive /norestart"
echo [+] Installing VC++ 2008 x86...
call :DownloadInstall "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe" "vc2008_x86.exe" "/qb"
echo [+] Installing VC++ 2008 x64...
call :DownloadInstall "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe" "vc2008_x64.exe" "/qb"
echo [+] Downloading WebView2Loader.dll...
powershell -NoProfile -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/redyfoxsyr0/Fixwater/releases/download/oryourdumb/WebView2Loader.dll' -OutFile '%TargetDir%\WebView2Loader.dll' -UserAgent 'Mozilla/5.0'"
echo.
echo [Success] All .NET and Visual C++ dependencies are ready.
pause
goto mainmenu

:DownloadInstall
powershell -NoProfile -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%~1' -OutFile '%TargetDir%\%~2' -UserAgent 'Mozilla/5.0'"
if exist "%TargetDir%\%~2" (
    echo [Working] Installing %~2...
    start /wait "" "%TargetDir%\%~2" %~3
) else (
    echo [!] ERROR: Failed to download %~2
)
goto :eof

:boot_menu
cls
echo +==========================================================================+
echo ^|                      ROBLOX BOOTSTRAPPER MENU                          ^|
echo +==========================================================================+
echo.
echo [1] WaveStrap (official ZIP - Fixed Path)
echo [2] Bloxstrap v2.9.1
echo [3] Fishstrap v2.9.1.2
echo [B] Back to main menu
echo.
set /p "CHOICE=Select: "
set "BOOT_NAME="
set "BOOT_URL="
set "IS_ZIP=0"

if "%CHOICE%"=="1" (
    set "BOOT_NAME=WaveStrap"
    set "BOOT_URL=https://github.com/redyfoxsyr0/WaveStrap/releases/download/GetWaveStrap/WaveStrap.zip"
    set "IS_ZIP=1"
)
if "%CHOICE%"=="2" (
    set "BOOT_NAME=Bloxstrap"
    set "BOOT_URL=https://github.com/bloxstraplabs/bloxstrap/releases/download/v2.9.1/Bloxstrap-v2.9.1.exe"
)
if "%CHOICE%"=="3" (
    set "BOOT_NAME=Fishstrap"
    set "BOOT_URL=https://github.com/fishstrap/fishstrap/releases/download/v2.9.1.2/Fishstrap-v2.9.1.2.exe"
)

if /I "%CHOICE%"=="B" goto mainmenu
if not defined BOOT_NAME goto boot_menu

if not exist "%TargetDir%\Boot" mkdir "%TargetDir%\Boot"

echo.
if "%IS_ZIP%"=="1" (
    set "TEMP_ZIP=%TargetDir%\Boot\WaveStrap.zip"
    set "EXTRACT_DIR=%TargetDir%\Boot\WaveStrap"

    echo [*] Downloading WaveStrap ZIP...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "try { Invoke-WebRequest -UseBasicParsing -Uri '!BOOT_URL!' -OutFile '!TEMP_ZIP!' -ErrorAction Stop } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message; exit 1 }" >nul 2>&1

    if errorlevel 1 (
        echo [ERROR] WaveStrap ZIP download failed.
        pause
        goto boot_menu
    )
    if not exist "!TEMP_ZIP!" (
        echo [ERROR] Download finished but zip is missing: "!TEMP_ZIP!"
        pause
        goto boot_menu
    )

    echo [*] Extracting package...
    if exist "!EXTRACT_DIR!" rmdir /s /q "!EXTRACT_DIR!"
    mkdir "!EXTRACT_DIR!"

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "try { Expand-Archive -Path '!TEMP_ZIP!' -DestinationPath '!EXTRACT_DIR!' -Force -ErrorAction Stop } catch { Write-Host '[ERROR] Extract failed:' $_.Exception.Message; exit 1 }" >nul 2>&1

    del "!TEMP_ZIP!" 2>nul

    if errorlevel 1 (
        echo [ERROR] Failed to extract WaveStrap ZIP.
        pause
        goto boot_menu
    )

    echo [*] Locating Wave-Strap.exe...
    set "FOUND_PATH="

    rem 1) Check expected path first
    if exist "!EXTRACT_DIR!\Release\net8.0-windows\WaveStrap.exe" (
        set "FOUND_PATH=!EXTRACT_DIR!\Release\net8.0-windows\WaveStrap.exe"
    )

    rem 2) Fallback search
    if not defined FOUND_PATH (
        for /r "!EXTRACT_DIR!" %%f in (Wave-Strap.exe) do (
            set "FOUND_PATH=%%~ff"
            goto :FoundWaveStrapExe
        )
    )

:FoundWaveStrapExe
    if defined FOUND_PATH (
        echo [Success] Found at: "!FOUND_PATH!"
        start "" "!FOUND_PATH!"
    ) else (
        echo [Error] Could not find Wave-Strap.exe after extraction.
        explorer "!EXTRACT_DIR!"
    )

) else (
    set "BOOT_EXE=%TargetDir%\Boot\%BOOT_NAME%.exe"
    echo [*] Downloading %BOOT_NAME%...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "try { Invoke-WebRequest -UseBasicParsing -Uri '%BOOT_URL%' -OutFile '%BOOT_EXE%' -ErrorAction Stop } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message; exit 1 }" >nul 2>&1

    if errorlevel 1 (
        echo [ERROR] %BOOT_NAME% download failed.
        pause
        goto boot_menu
    )

    if exist "%BOOT_EXE%" (
        start "" "%BOOT_EXE%"
    ) else (
        echo [ERROR] Download finished but file is missing: "%BOOT_EXE%"
    )
)

echo.
pause
goto mainmenu

:LaunchDone
echo.
echo [*] Returning to main menu...
timeout /t 2 >nul
goto mainmenu

:: End guard: if anything ever falls through, don’t close
goto mainmenu
