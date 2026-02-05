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

del "%UART_LOG%" 2>nul

REM ===== COMPILE + UPLOAD SENDER =====
echo Compiling sender...
%ARDUINO_CLI% compile --fqbn %FQBN% sender || exit /b 1

echo Uploading sender...
%ARDUINO_CLI% upload -p %SENDER_PORT% --fqbn %FQBN% sender || exit /b 1

REM ===== COMPILE + UPLOAD RECEIVER =====
echo Compiling receiver...
%ARDUINO_CLI% compile --fqbn %FQBN% receiver || exit /b 1

echo Uploading receiver...
%ARDUINO_CLI% upload -p %RECEIVER_PORT% --fqbn %FQBN% receiver || exit /b 1

echo Waiting for ESP32 reboot...
timeout /t 4 >nul

echo ================================
echo UART toggle test started
echo ================================

REM ===== START POWERHELL SERIAL LISTENER (ONCE) =====
powershell -NoProfile -Command ^
"$p = New-Object System.IO.Ports.SerialPort('%RECEIVER_PORT%', %BAUD%); ^
$p.ReadTimeout = 7000; ^
$p.Open(); ^
try { $line = $p.ReadLine(); $line | Out-File '%UART_LOG%' } catch {} ^
$p.Close();"

REM ===== CHECK RESULT =====
if exist "%UART_LOG%" (
    type "%UART_LOG%"

    findstr /C:"UART_TEST_PASS" "%UART_LOG%" >nul && (
        echo ================================
        echo UART TEST RESULT: PASS
        echo ================================
        exit /b 0
    )
)

echo ================================
echo UART TEST RESULT: FAIL
echo ================================
exit /b 1
