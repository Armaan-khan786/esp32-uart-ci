@echo off
setlocal EnableDelayedExpansion

REM ================== CONFIG ==================
set ARDUINO_CLI=arduino-cli
set BOARD=esp32:esp32:esp32
set BAUD=115200

set SENDER_PORT=COM5
set RECEIVER_PORT=COM6

set SENDER_SKETCH=sender
set RECEIVER_SKETCH=receiver

set UART_LOG=%TEMP%\uart_result.txt
REM ============================================

echo ============================================
echo Releasing any locked COM ports
echo ============================================

powershell -NoProfile -Command ^
  "Get-WmiObject Win32_SerialPort | ForEach-Object { try { $_.Dispose() } catch {} }"

timeout /t 2 >nul

REM ================== FLASH SENDER ==================
echo ============================================
echo Flashing ESP32 sender...
echo ============================================

set RETRIES=3
:FLASH_SENDER
%ARDUINO_CLI% upload -p %SENDER_PORT% --fqbn %BOARD% %SENDER_SKETCH%
if %ERRORLEVEL% EQU 0 goto FLASH_SENDER_OK
set /a RETRIES-=1
if %RETRIES% LEQ 0 exit /b 1
timeout /t 2 >nul
goto FLASH_SENDER
:FLASH_SENDER_OK

REM ================== FLASH RECEIVER ==================
echo ============================================
echo Flashing ESP32 receiver...
echo ============================================

set RETRIES=3
:FLASH_RECEIVER
%ARDUINO_CLI% upload -p %RECEIVER_PORT% --fqbn %BOARD% %RECEIVER_SKETCH%
if %ERRORLEVEL% EQU 0 goto FLASH_RECEIVER_OK
set /a RETRIES-=1
if %RETRIES% LEQ 0 exit /b 1
timeout /t 2 >nul
goto FLASH_RECEIVER
:FLASH_RECEIVER_OK

REM ================== WAIT FOR BOOT ==================
echo Waiting for ESP32 reboot...
timeout /t 5 >nul

REM ================== UART TOGGLE TEST ==================
echo.
echo Waiting for UART toggle result...

set RESULT=FAIL
del "%UART_LOG%" 2>nul

for /L %%i in (1,1,15) do (

    powershell -NoProfile -Command ^
      "$p = New-Object System.IO.Ports.SerialPort('%RECEIVER_PORT%',%BAUD%); ^
       $p.Open(); ^
       Start-Sleep -Milliseconds 300; ^
       while ($p.BytesToRead -gt 0) { $p.ReadLine() | Out-File -Append '%UART_LOG%' }; ^
       $p.Close();"

    if exist "%UART_LOG%" (
        findstr /C:"UART_TEST_PASS" "%UART_LOG%" >nul && (
            set RESULT=PASS
            goto UART_DONE
        )
        findstr /C:"UART_TEST_FAIL" "%UART_LOG%" >nul && (
            set RESULT=FAIL
            goto UART_DONE
        )
    )

    timeout /t 1 >nul
)

:UART_DONE
echo UART TEST RESULT: %RESULT%

if "%RESULT%"=="PASS" (
    exit /b 0
) else (
    exit /b 1
)
