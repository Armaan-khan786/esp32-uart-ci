param (
    [string]$Port,
    [int]$Baud = 115200,
    [string]$LogFile
)

$ErrorActionPreference = "Stop"

# Open serial port
$serial = New-Object System.IO.Ports.SerialPort $Port, $Baud
$serial.ReadTimeout = 500
$serial.NewLine = "`n"

try {
    $serial.Open()
} catch {
    "UART_TEST_FAIL: Cannot open port" | Out-File $LogFile
    exit 1
}

$start = Get-Date
$found = $false

while ((Get-Date) - $start -lt [TimeSpan]::FromSeconds(5)) {
    try {
        $line = $serial.ReadLine().Trim()

        if ($line -match "TOGGLE_OK") {
            "UART_TEST_PASS" | Out-File $LogFile
            $found = $true
            break
        }

        if ($line -match "TOGGLE_FAIL") {
            "UART_TEST_FAIL" | Out-File $LogFile
            break
        }
    } catch {
        # timeout – ignore
    }
}

$serial.Close()

if (-not $found) {
    "UART_TEST_FAIL" | Out-File $LogFile
    exit 1
}

exit 0
