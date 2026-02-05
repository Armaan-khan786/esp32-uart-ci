param (
    [string]$Port,
    [int]$Baud,
    [string]$LogFile
)

$p = New-Object System.IO.Ports.SerialPort $Port, $Baud
$p.ReadTimeout = 500
$p.Open()

Start-Sleep -Milliseconds 300

try {
    while ($p.BytesToRead -gt 0) {
        $line = $p.ReadLine()
        $line | Out-File -Append $LogFile
    }
}
catch {
    # ignore read timeout
}

$p.Close()
