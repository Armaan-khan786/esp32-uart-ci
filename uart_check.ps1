$port = "COM6"
$baud = 115200
$log  = "$env:TEMP\uart_result.txt"

Remove-Item $log -ErrorAction Ignore

$p = New-Object System.IO.Ports.SerialPort $port,$baud
$p.ReadTimeout = 7000
$p.Open()

try {
    $line = $p.ReadLine()
    $line | Out-File $log
}
catch {
    "UART_TEST_FAIL" | Out-File $log
}

$p.Close()
