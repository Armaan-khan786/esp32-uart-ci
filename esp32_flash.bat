@echo off
setlocal EnableDelayedExpansion

echo ================================
echo ESP32 UART CI TEST STARTED
echo ================================

REM ===== CONFIG =====
set ARDUINO_CLI=arduino-cli.exe
set FQBN=esp32:esp32:esp32

set SENDER_PORT=COM7
set RECEIVER_PORT=COM6
set BAUD=115200

set UART_LOG=%TEMP%\uart_result.txt
if exist "%UART_LOG%" del "%UART_LOG%"

REM ===== COMPILE SENDER =====
echo.
echo Compiling sender...
%ARDUINO_CLI% compile --no-input --fqbn %FQBN% sender || exit /b 1

REM ===== UPLOAD SENDER =====
echo Uploading sender...
%ARDUINO_CLI% upload --no-input -p %SENDER_PORT% --fqbn %FQBN% sender || exit /b 1

REM ===== COMPILE RECEIVER =====
echo.
echo Compiling receiver...
%ARDUINO_CLI% compile --no-input --fqbn %FQBN% receiver || exit /b 1

REM ===== UPLOAD RECEIVER =====
echo Uploading receiver...
%ARDUINO_CLI% upload --no-input -p %RECEIVER_PORT% --fqbn %FQBN% receiver || exit /b 1

REM ===== WAIT FOR BOOT =====
echo Waiting for ESP32 reboot...
timeout /t 3 >nul

REM ===== UART TOGGLE TEST =====
echo.
echo Waiting for UART toggle result...

set RESULT=FAIL

for /L %%i in (1,1,15) do (

    powershell -NoProfile -ExecutionPolicy Bypass ^
      -File uart_check.ps1 ^
      -Port %RECEIVER_PORT% ^
      -Baud %BAUD% ^
      -LogFile "%UART_LOG%"

    if exist "%UART_LOG%" (
        findstr /C:"UART_TEST_PASS" "%UART_LOG%" >nul && (
            set RESULT=PASS
            goto END
        )

        findstr /C:"UART_TEST_FAIL" "%UART_LOG%" >nul && (
            set RESULT=FAIL
            goto END
        )
    )

    timeout /t 1 >nul
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
