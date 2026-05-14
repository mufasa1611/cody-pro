@echo off
setlocal

set "ROOT=%~dp0"
set "BUN="

where bun >nul 2>nul
if %ERRORLEVEL%==0 set "BUN=bun"

if not defined BUN if exist "%USERPROFILE%\.bun\bin\bun.exe" set "BUN=%USERPROFILE%\.bun\bin\bun.exe"
if not defined BUN if exist "%USERPROFILE%\AppData\Roaming\npm\bun.cmd" set "BUN=%USERPROFILE%\AppData\Roaming\npm\bun.cmd"

if not defined BUN (
  echo Bun was not found.
  echo Run install.bat from this checkout, or install Bun from https://bun.sh and retry.
  exit /b 1
)

if exist "%USERPROFILE%\.bun\bin" set "PATH=%USERPROFILE%\.bun\bin;%PATH%"
if exist "%USERPROFILE%\AppData\Roaming\npm" set "PATH=%USERPROFILE%\AppData\Roaming\npm;%PATH%"
set "CODY_PRO=1"

set "CODY_PRO_DISCOVER_MODELS=1"
for %%A in (%*) do (
  if /I "%%~A"=="--help" set "CODY_PRO_DISCOVER_MODELS=0"
  if /I "%%~A"=="-h" set "CODY_PRO_DISCOVER_MODELS=0"
  if /I "%%~A"=="help" set "CODY_PRO_DISCOVER_MODELS=0"
  if /I "%%~A"=="--version" set "CODY_PRO_DISCOVER_MODELS=0"
  if /I "%%~A"=="-v" set "CODY_PRO_DISCOVER_MODELS=0"
  if /I "%%~A"=="version" set "CODY_PRO_DISCOVER_MODELS=0"
)

set "CODY_PRO_GENERATED_CONFIG=%ROOT%.opencode\generated\opencode.jsonc"
set "CODY_PRO_SHOULD_DISCOVER_MODELS=0"
if not "%CODY_PRO_SKIP_MODEL_DISCOVERY%"=="1" if "%CODY_PRO_DISCOVER_MODELS%"=="1" (
  if "%CODY_PRO_REFRESH_MODELS%"=="1" set "CODY_PRO_SHOULD_DISCOVER_MODELS=1"
  if not exist "%CODY_PRO_GENERATED_CONFIG%" set "CODY_PRO_SHOULD_DISCOVER_MODELS=1"
)

if "%CODY_PRO_SHOULD_DISCOVER_MODELS%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%script\discover-local-models.ps1" -Root "%ROOT:~0,-1%"
)

if not defined OPENCODE_CONFIG_DIR (
  set "OPENCODE_CONFIG_DIR=%ROOT%.opencode\generated"
)

call "%BUN%" run --cwd "%ROOT%packages\opencode" --conditions=browser src\index.ts %*
exit /b %ERRORLEVEL%
