# STUN Server Latency Test Tool
# Using PowerShell to test STUN server connection latency

$STUN_SERVERS = @(
    'stun.l.google.com:19302',
    'stun1.l.google.com:19302',
    'stun2.l.google.com:19302',
    'stun.qq.com:3478',
    'stun.miwifi.com:3478',
    'stun.nordvpn.com:3478',
    'global.stun.twilio.com:3478',
    '52.52.70.85:3478',
    '199.4.110.11:3478',
    '34.192.137.246:3478',
    '87.106.115.74:3478',
    '203.56.112.226:3478',
    '52.47.70.236:3478',
    '192.76.120.66:3478',
    '217.146.224.74:3478',
    '137.74.112.113:3478',
    '49.12.125.53:3478',
    '51.83.201.84:3478',
    '91.213.98.54:3478',
    '51.83.15.212:3478',
    '81.82.206.117:3478',
    '3.78.237.53:3478',
    '143.198.60.79:3478',
    '89.37.98.122:3478',
    '91.198.51.140:3478',
    '91.212.41.85:3478',
    '188.138.90.169:3478',
    '193.22.17.97:3478',
    '188.40.203.74:3478',
    '85.197.87.182:3478',
    '172.233.245.118:3478',
    '176.9.24.184:3478',
    '81.83.12.46:3478',
    '35.158.233.7:3478',
    '62.72.83.10:3478',
    '45.15.102.34:3478',
    '94.130.130.49:3478',
    '202.49.164.49:3478',
    '195.208.107.138:3478',
    '185.125.180.70:3478',
    '197.155.250.157:3478',
    '34.74.124.204:3478',
    '44.230.252.214:3478',
    '195.145.93.141:3478',
    '52.24.174.49:3478',
    '192.172.233.145:3478',
    '54.197.117.0:3478',
    '34.195.177.19:3478',
    '95.216.78.222:3478',
    '35.177.202.92:3478',
    '5.39.72.109:3478',
    '212.18.0.14:3478',
    '46.225.95.169:3478',
    '136.243.59.79:3478',
    '51.68.112.203:3478',
    '195.201.132.113:3478',
    '108.163.134.186:3478',
    '5.161.52.174:3478',
    '34.206.168.53:3478',
    '193.182.111.151:3478',
    '51.15.210.80:3478',
    '203.56.114.226:3478',
    '88.218.220.40:3478',
    '80.155.54.123:3478',
    '23.21.199.62:3478',
    '129.153.212.128:3478',
    '81.3.27.44:3478',
    '80.156.214.187:3478',
    '3.70.219.198:3478',
    '52.26.251.34:3478',
    '147.182.188.245:3478',
    '209.251.63.76:3478',
    '5.161.57.75:3478',
    '66.228.54.23:3478',
    '46.225.95.169:443',
    '90.145.158.66:3478',
    '197.155.248.157:3478',
    '24.204.48.11:3478',
    '88.99.67.241:3478',
    '202.49.164.50:3478',
    '213.251.48.147:3478',
    '188.40.18.246:3478',
    '91.224.227.30:3478',
    '83.64.250.246:3478',
    '51.68.45.75:3478'
)

# Geo location hints
$GEO_HINTS = @{
    'stun.l' = 'Google'
    'stun1.l' = 'Google'
    'stun2.l' = 'Google'
    'stun.qq' = 'Tencent (China)'
    'stun.miwifi' = 'Xiaomi (China)'
    'stun.nordvpn' = 'NordVPN'
    'global.stun.twilio' = 'Twilio'
    '52.' = 'AWS (US)'
    '34.' = 'AWS (US)'
    '3.' = 'AWS (US)'
    '44.' = 'AWS (US)'
    '54.' = 'AWS (US)'
    '35.' = 'AWS (Europe)'
    '143.' = 'DigitalOcean (SG)'
    '172.' = 'Fastly/Other'
    '129.' = 'Oracle Cloud'
    '147.' = 'Google Cloud'
    '199.' = 'Internet2 (US)'
    '192.' = 'Quest (US)'
    '195.' = 'Germany/Europe'
    '188.' = 'Germany (Hetzner)'
    '62.' = 'Netherlands'
    '95.' = 'Switzerland'
    '176.' = 'Germany (Hetzner)'
    '49.' = 'Germany (Hetzner)'
    '51.' = 'France/Europe'
    '5.' = 'Netherlands/Other'
    '66.' = 'Linode (US)'
    '46.' = 'Sweden'
    '85.' = 'Estonia'
    '91.' = 'Europe'
    '88.' = 'Germany (Hetzner)'
    '213.' = 'France'
    '81.' = 'Belgium/Netherlands'
    '87.' = 'Germany (1&1)'
    '137.' = 'Scaleway (France)'
    '108.' = 'South Africa'
    '24.' = 'Canada'
    '80.' = 'Germany'
    '83.' = 'Austria'
    '89.' = 'Romania'
    '90.' = 'Sweden'
    '94.' = 'Germany (Hetzner)'
    '136.' = 'Germany (Hetzner)'
    '197.' = 'Nigeria/Africa'
    '202.' = 'NZ/Australia'
    '203.' = 'Australia'
    '209.' = 'US'
    '212.' = 'Germany'
    '217.' = 'Germany (Intergenia)'
}

function Get-GeoHint {
    param($addr)
    foreach ($hint in $GEO_HINTS.Keys) {
        if ($addr.StartsWith($hint)) {
            return $GEO_HINTS[$hint]
        }
    }
    return 'Unknown'
}

function Test-StunServer {
    param($addr, $timeout = 2000)
    
    try {
        # Parse address
        $parts = $addr -split ':'
        $host = $parts[0]
        $port = if ($parts.Length -gt 1) { [int]$parts[1] } else { 3478 }
        
        # Create UDP client
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Client.ReceiveTimeout = $timeout
        $udpClient.Client.SendTimeout = $timeout
        
        # Create STUN BINDING REQUEST
        # STUN header: Type(2) + Length(2) + Magic Cookie(4) + Transaction ID(12)
        $transactionId = [byte[]]::new(12)
        $rand = New-Object System.Random
        $rand.NextBytes($transactionId)
        
        $magicCookie = [byte[]]@(0x21, 0x12, 0xA4, 0x42)
        $header = [byte[]]@(0x00, 0x01) + [byte[]]@(0x00, 0x00) + $magicCookie + $transactionId
        
        # Send request
        $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
        $startTime = Get-Date
        
        $udpClient.Send($header, $header.Length, $host, $port) | Out-Null
        $response = $udpClient.Receive([ref]$endpoint)
        $endTime = Get-Date
        
        $udpClient.Close()
        
        $latency = [int](($endTime - $startTime).TotalMilliseconds)
        
        return @{
            addr = $addr
            latency = $latency
            status = 'OK'
            geo = Get-GeoHint $addr
        }
    }
    catch {
        if ($udpClient) { $udpClient.Close() }
        return @{
            addr = $addr
            latency = $null
            status = "Failed"
            geo = Get-GeoHint $addr
        }
    }
}

# Main test logic
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  STUN Server Latency Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Testing $($STUN_SERVERS.Count) servers..." -ForegroundColor Yellow
Write-Host ""

$results = @()
$completed = 0

foreach ($server in $STUN_SERVERS) {
    $completed++
    $result = Test-StunServer $server
    $results += $result
    
    if ($result.latency -ne $null) {
        $color = if ($result.latency -lt 100) { 'Green' } elseif ($result.latency -lt 200) { 'Yellow' } else { 'Red' }
        Write-Host "[$completed/$($STUN_SERVERS.Count)] " -NoNewline -ForegroundColor Gray
        Write-Host $result.addr.PadRight(35) -NoNewline
        Write-Host (" " + $result.latency.ToString() + "ms").PadRight(12) -NoNewline -ForegroundColor $color
        Write-Host $result.geo -ForegroundColor Gray
    } else {
        Write-Host "[$completed/$($STUN_SERVERS.Count)] " -NoNewline -ForegroundColor Gray
        Write-Host $result.addr.PadRight(35) -NoNewline
        Write-Host " Failed".PadRight(12) -NoNewline -ForegroundColor Red
        Write-Host $result.geo -ForegroundColor Gray
    }
}

# Sort: successful first, then by latency
$results = $results | Sort-Object @{Expression={$_.latency -eq $null}}, latency

# Statistics
$successful = $results | Where-Object { $_.latency -ne $null }
$failed = $results | Where-Object { $_.latency -eq $null }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total servers: $($results.Count)"
Write-Host "Successful: $($successful.Count)" -ForegroundColor Green
Write-Host "Failed: $($failed.Count)" -ForegroundColor Red

if ($successful.Count -gt 0) {
    $avgLatency = ($successful | Measure-Object -Property latency -Average).Average
    Write-Host ("Average latency: " + [math]::Round($avgLatency, 1) + "ms")
}

# Display best servers
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Best Servers (for game config)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$bestServers = $successful | Select-Object -First 10
for ($i = 0; $i -lt $bestServers.Count; $i++) {
    $server = $bestServers[$i]
    $color = if ($server.latency -lt 100) { 'Green' } elseif ($server.latency -lt 200) { 'Yellow' } else { 'Red' }
    Write-Host ("$($i + 1). ") -NoNewline
    Write-Host ("stun:" + $server.addr) -NoNewline
    Write-Host (" (" + $server.latency + "ms)") -NoNewline -ForegroundColor $color
    Write-Host (" [" + $server.geo + "]") -ForegroundColor Gray
}

# Generate config code
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ICE Config for Game" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "iceServers: ["
$top5 = $successful | Select-Object -First 5
foreach ($server in $top5) {
    Write-Host ("    { urls: 'stun:" + $server.addr + "' },")
}
Write-Host "]"
Write-Host ""
