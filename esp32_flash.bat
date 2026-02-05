@echo off
setlocal EnableDelayedExpansion

REM ================= CONFIG =================
set ARDUINO_CLI=arduino-cli
set BOARD=esp32:esp32:esp32
set BAUD=115200

set SENDER_PORT=COM5
set RECEIVER_PORT=COM6

set SENDER_SKETCH=sender
set RECEIVER_SKETCH=receiver

set UART_LOG=uart_output.txt
REM ==========================================

echo ===============================
echo Flashing SENDER
echo ===============================

%ARDUINO_CLI% upload -p %SENDER_PORT% --fqbn %BOARD% %SENDER_SKETCH%
if errorlevel 1 exit /b 1

echo ===============================
echo Flashing RECEIVER
echo ===============================

%ARDUINO_CLI% upload -p %RECEIVER_PORT% --fqbn %BOARD% %RECEIVER_SKETCH%
if errorlevel 1 exit /b 1

echo ===============================
echo Waiting for ESP32 reboot
echo ===============================
timeout /t 8 >nul

REM ================= UART TEST =================
echo ===============================
echo UART toggle test started
echo ===============================

del "%UART_LOG%" 2>nul

REM Configure serial port (THIS DOES NOT LOCK)
mode %RECEIVER_PORT% BAUD=%BAUD% PARITY=N DATA=8 STOP=1 >nul

REM Read UART once (blocking-safe)
type %RECEIVER_PORT% > "%UART_LOG%" & timeout /t 3 >nul

findstr /C:"UART_TEST_PASS" "%UART_LOG%" >nul
if %ERRORLEVEL% EQU 0 (
    echo UART TEST RESULT: PASS
    exit /b 0
)

findstr /C:"UART_TEST_FAIL" "%UART_LOG%" >nul
if %ERRORLEVEL% EQU 0 (
    echo UART TEST RESULT: FAIL
    exit /b 1
)

echo UART TEST RESULT: FAIL (NO OUTPUT)
exit /b 1
