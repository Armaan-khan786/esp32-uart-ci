$port = "COM6"
$baud = 115200
$log  = "$env:TEMP\uart_result.txt"

Remove-Item $log -ErrorAction Ignore

$sp = New-Object System.IO.Ports.SerialPort $port,$baud
$sp.ReadTimeout = 8000
$sp.Open()

try {
    $line = $sp.ReadLine()
    $line | Out-File -Encoding ascii $log
}
catch {
    "UART_TEST_FAIL" | Out-File -Encoding ascii $log
}

$sp.Close()
