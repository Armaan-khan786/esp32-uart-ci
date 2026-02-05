param (
    [string]$Port,
    [int]$Baud = 115200
)

$ErrorActionPreference = "SilentlyContinue"

$serial = New-Object System.IO.Ports.SerialPort $Port, $Baud
$serial.ReadTimeout = 500
$serial.NewLine = "`n"

try {
    $serial.Open()
} catch {
    Write-Host "UART_TEST_FAIL"
    exit 1
}

$start = Get-Date

while ((Get-Date) - $start -lt [TimeSpan]::FromSeconds(5)) {
    try {
        $line = $serial.ReadLine().Trim()
        Write-Host $line

        if ($line -eq "TOGGLE_OK") {
            Write-Host "UART_TEST_PASS"
            $serial.Close()
            exit 0
        }

        if ($line -eq "TOGGLE_FAIL") {
            Write-Host "UART_TEST_FAIL"
            $serial.Close()
            exit 1
        }
    } catch {
        # ignore timeout
    }
}

$serial.Close()
Write-Host "UART_TEST_FAIL"
exit 1
