@echo off
setlocal EnableDelayedExpansion

REM ================= CONFIG =================
set ARDUINO_CLI=arduino-cli.exe
set BOARD=esp32:esp32:esp32
set SENDER_PORT=COM5
set RECEIVER_PORT=COM6
set BAUD=115200
REM ==========================================

echo ================================
echo Flashing ESP32 sender...
echo ================================

%ARDUINO_CLI% compile --fqbn %BOARD% sender || exit /b 1
%ARDUINO_CLI% upload -p %SENDER_PORT% --fqbn %BOARD% sender || exit /b 1

echo ================================
echo Flashing ESP32 receiver...
echo ================================

%ARDUINO_CLI% compile --fqbn %BOARD% receiver || exit /b 1
%ARDUINO_CLI% upload -p %RECEIVER_PORT% --fqbn %BOARD% receiver || exit /b 1

echo ================================
echo Waiting for ESP32 reboot...
echo ================================
timeout /t 3 >nul

echo ================================
echo Waiting for UART toggle result...
echo ================================

powershell -NoProfile -ExecutionPolicy Bypass ^
  -File uart_check.ps1 ^
  -Port %RECEIVER_PORT% ^
  -Baud %BAUD%

IF ERRORLEVEL 1 (
    echo ================================
    echo UART TEST RESULT: FAIL
    echo ================================
    exit /b 1
)

echo ================================
echo UART TEST RESULT: PASS
echo ================================
exit /b 0
