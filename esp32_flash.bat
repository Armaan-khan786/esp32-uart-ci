REM ===== UART TEST =====
echo.
echo Waiting for UART test result...

set RESULT=FAIL
set UART_LOG=%TEMP%\uart_result.txt
del "%UART_LOG%" 2>nul

for /L %%i in (1,1,20) do (

    powershell -NoProfile -Command "$p=New-Object System.IO.Ports.SerialPort('%RECEIVER_PORT%',%BAUD%); $p.ReadTimeout=500; $p.Open(); Start-Sleep -Milliseconds 400; if($p.BytesToRead -gt 0){ $p.ReadExisting() | Out-File -Append '%UART_LOG%' }; $p.Close()"

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
