@echo off
setlocal EnableDelayedExpansion

echo ================================
echo ESP32 UART CI TEST
echo ================================

set ARDUINO_CLI=arduino-cli.exe
set FQBN=esp32:esp32:esp32
set SENDER_PORT=COM7
set RECEIVER_PORT=COM6
set LOG=%TEMP%\uart_result.txt

REM absolute path to this BAT file
set ROOT=%~dp0
set PS_SCRIPT=%ROOT%uart_listen.ps1

del "%LOG%" 2>nul

echo Upload sender
%ARDUINO_CLI% upload -p %SENDER_PORT% --fqbn %FQBN% sender || exit /b 1

echo Upload receiver
%ARDUINO_CLI% upload -p %RECEIVER_PORT% --fqbn %FQBN% receiver || exit /b 1

echo Waiting for reboot...
timeout /t 4 >nul

echo UART toggle test started
echo Using PS script: %PS_SCRIPT%

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

if not exist "%LOG%" (
    echo UART log not found
    exit /b 1
)

type "%LOG%"

findstr /C:"UART_TEST_PASS" "%LOG%" >nul && (
    echo ================================
    echo UART TEST RESULT: PASS
    echo ================================
    exit /b 0
)

echo ================================
echo UART TEST RESULT: FAIL
echo ================================
exit /b 1
