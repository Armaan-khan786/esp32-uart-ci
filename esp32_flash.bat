@echo off
setlocal ENABLEDELAYEDEXPANSION

echo ================================
echo ESP32 UART CI TEST STARTED
echo ================================

REM ===== CONFIGURATION =====
set ARDUINO_CLI=arduino-cli.exe
set FQBN=esp32:esp32:esp32

set SENDER_PORT=COM7
set RECEIVER_PORT=COM6

set BAUD=115200

REM ===== COMPILE SENDER =====
echo.
echo Compiling sender...
%ARDUINO_CLI% compile --fqbn %FQBN% sender
IF ERRORLEVEL 1 (
    echo SENDER COMPILE FAILED
    exit /b 1
)

REM ===== UPLOAD SENDER =====
echo Uploading sender to %SENDER_PORT% ...
%ARDUINO_CLI% upload -p %SENDER_PORT% --fqbn %FQBN% sender
IF ERRORLEVEL 1 (
    echo SENDER UPLOAD FAILED
    exit /b 1
)

REM ===== COMPILE RECEIVER =====
echo.
echo Compiling receiver...
%ARDUINO_CLI% compile --fqbn %FQBN% receiver
IF ERRORLEVEL 1 (
    echo RECEIVER COMPILE FAILED
    exit /b 1
)

REM ===== UPLOAD RECEIVER =====
echo Uploading receiver to %RECEIVER_PORT% ...
%ARDUINO_CLI% upload -p %RECEIVER_PORT% --fqbn %FQBN% receiver
IF ERRORLEVEL 1 (
    echo RECEIVER UPLOAD FAILED
    exit /b 1
)

REM ===== WAIT FOR ESP RESET =====
echo Waiting for ESP32 reboot...
timeout /t 3 >nul

REM ===== UART TEST =====
echo.
echo Waiting for UART test result...

set RESULT=FAIL

for /L %%i in (1,1,15) do (
    for /f "delims=" %%A in ('powershell -command ^
        "$p = new-Object System.IO.Ports.SerialPort('%RECEIVER_PORT%',%BAUD%); ^
         $p.Open(); ^
         Start-Sleep -Milliseconds 300; ^
         if ($p.BytesToRead -gt 0) { $p.ReadLine() } ^
         $p.Close();"') do (

        echo %%A

        if "%%A"=="UART_TEST_PASS" (
            set RESULT=PASS
            goto END
        )

        if "%%A"=="UART_TEST_FAIL" (
            set RESULT=FAIL
            goto END
        )
    )
)

:END
echo.
echo ================================
echo UART TEST RESULT: %RESULT%
echo ================================

if "%RESULT%"=="PASS" (
    exit /b 0
) else (
    exit /b 1
)
