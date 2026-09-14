@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM =============================================================================
REM Sherin TTS / Vite app launcher
REM Installs Node project dependencies, validates npm/npx/vite, picks a free port,
REM then starts the development server.
REM
REM Note: "node" is a Python test runner and is not required for this Vite app.
REM       "nm" is treated as npm. npx ships with Node.js/npm.
REM =============================================================================

set "DEFAULT_PORT=5500"
set "FALLBACK_PORT=5501"
set "APP_PORT=%DEFAULT_PORT%"
set "EXIT_CODE=0"

echo.
echo ============================================================
echo   Application bootstrap
echo ============================================================
echo.

REM ---------------------------------------------------------------------------
REM 1) Require Node.js / npm (npx is installed with npm)
REM ---------------------------------------------------------------------------
echo [1/5] Checking for Node.js and npm...
where node >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Node.js was not found on PATH.
    echo Install Node.js LTS from https://nodejs.org/ then re-run this script.
    set "EXIT_CODE=1"
    goto :fail
)

where npm >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: npm was not found on PATH.
    echo Reinstall Node.js and ensure "Add to PATH" is enabled during setup.
    set "EXIT_CODE=1"
    goto :fail
)

for /f "tokens=*" %%V in ('node -v 2^>nul') do set "NODE_VER=%%V"
for /f "tokens=*" %%V in ('npm -v 2^>nul') do set "NPM_VER=%%V"
echo       Node.js: %NODE_VER%
echo       npm:     %NPM_VER%

REM ---------------------------------------------------------------------------
REM 2) Validate npx (required to run vite when invoked via npx)
REM ---------------------------------------------------------------------------
echo.
echo [2/5] Validating npx...
where npx >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: npx was not found on PATH.
    echo npx is installed with npm. Reinstall Node.js, then reopen this terminal.
    set "EXIT_CODE=1"
    goto :fail
)
echo       npx is available.

REM ---------------------------------------------------------------------------
REM 3) Install project dependencies (includes vite when listed in package.json)
REM ---------------------------------------------------------------------------
echo.
echo [3/5] Installing dependencies...
if not exist "package.json" (
    echo.
    echo ERROR: package.json not found in:
    echo        %CD%
    echo Run this script from the project root that contains package.json.
    set "EXIT_CODE=1"
    goto :fail
)

call npm install
if errorlevel 1 (
    echo.
    echo ERROR: npm install failed. See messages above.
    set "EXIT_CODE=1"
    goto :fail
)
echo       npm install completed.

REM Ensure vite is present (project dependency or global)
echo.
echo       Verifying vite...
call npx --yes vite --version >nul 2>&1
if errorlevel 1 (
    echo       vite not found via project/npx — installing vite as a dev dependency...
    call npm install --save-dev vite
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install vite.
        set "EXIT_CODE=1"
        goto :fail
    )
)
for /f "tokens=*" %%V in ('npx --yes vite --version 2^>nul') do set "VITE_VER=%%V"
echo       vite: %VITE_VER%

REM Optional: user-requested names that are not part of a standard Vite stack
REM nose = Python package; skip with a notice rather than failing the Node app.
echo.
echo       Note: "nose" is a Python test framework and is not installed here.
echo             Use "pip install nose" only if you need it for Python tests.
echo       Note: "nm" is treated as npm (already verified above).

REM ---------------------------------------------------------------------------
REM 4) Port check — use FALLBACK_PORT if DEFAULT_PORT is busy
REM ---------------------------------------------------------------------------
echo.
echo [4/5] Checking port availability...
set "PORT_IN_USE=0"

REM netstat: look for LISTENING sockets on DEFAULT_PORT
netstat -ano 2>nul | findstr /R /C:":%DEFAULT_PORT% .*LISTENING" >nul 2>&1
if not errorlevel 1 set "PORT_IN_USE=1"

if "%PORT_IN_USE%"=="1" (
    set "APP_PORT=%FALLBACK_PORT%"
    echo.
    echo NOTICE: Default port %DEFAULT_PORT% is in use on this machine.
    echo         The application will start on port %FALLBACK_PORT% instead.
    echo.
) else (
    echo       Port %DEFAULT_PORT% is free.
    set "APP_PORT=%DEFAULT_PORT%"
)

REM ---------------------------------------------------------------------------
REM 5) Launch the Vite-powered application
REM ---------------------------------------------------------------------------
echo.
echo [5/5] Launching application on port %APP_PORT%...
echo       Open: http://127.0.0.1:%APP_PORT%/
echo.

REM Prefer package.json scripts when present; fall back to npx vite
findstr /I /C:"\"dev\"" package.json >nul 2>&1
if not errorlevel 1 (
    REM Pass host/port so Vite binds as requested even if the script has defaults
    call npm run dev -- --host 0.0.0.0 --port %APP_PORT%
) else (
    call npx --yes vite --host 0.0.0.0 --port %APP_PORT%
)

if errorlevel 1 (
    echo.
    echo ERROR: Application failed to start.
    set "EXIT_CODE=1"
    goto :fail
)

goto :eof

:fail
echo.
echo ------------------------------------------------------------
echo Bootstrap stopped with errors. Exit code: %EXIT_CODE%
echo ------------------------------------------------------------
echo.
pause
exit /b %EXIT_CODE%
