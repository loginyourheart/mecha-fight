$content = Get-Content 'd:\AIcode\mecha-fight\index.html' -Raw

$oldIceServers = @'
iceServers: [
                        // Google STUN servers (全球最稳定)
                        { urls: 'stun:stun.l.google.com:19302' },
                        { urls: 'stun:stun1.l.google.com:19302' },
                        { urls: 'stun:stun2.l.google.com:19302' },
                        { urls: 'stun:stun3.l.google.com:19305' },
                        { urls: 'stun:stun4.l.google.com:19305' },
                        // 国内STUN服务器
                        { urls: 'stun:stun.qq.com:3478' },
                        { urls: 'stun:stun.miwifi.com:3478' },
                        // NordVPN STUN
                        { urls: 'stun:stun.nordvpn.com:3478' },
                        // Twilio STUN
                        { urls: 'stun:global.stun.twilio.com:3478' },
                        // 公共 TURN 服务器 (用于极端NAT环境)
                        { urls: 'turn:numb.viagenie.ca', credential: 'muazkh', username: 'webrtc@live.com' },
                        { urls: 'turn:openrelay.metered.ca:80', credential: 'openrelayproject', username: 'openrelayproject' },
                        { urls: 'turn:openrelay.metered.ca:443', credential: 'openrelayproject', username: 'openrelayproject' }
                    ],
'@

$newIceServers = @'
iceServers: [
                        // 用户测试最佳服务器 (延迟 <200ms)
                        { urls: 'stun:52.47.70.236:3478' },
                        { urls: 'stun:3.78.237.53:3478' },
                        { urls: 'stun:188.40.203.74:3478' },
                        { urls: 'stun:143.198.60.79:3478' },
                        { urls: 'stun:46.225.95.169:3478' },
                        { urls: 'stun:137.74.112.113:3478' },
                        // Google STUN (备用)
                        { urls: 'stun:stun.l.google.com:19302' },
                        { urls: 'stun:stun1.l.google.com:19302' },
                        { urls: 'stun:stun2.l.google.com:19302' },
                        // Twilio STUN
                        { urls: 'stun:global.stun.twilio.com:3478' },
                        // 公共 TURN 服务器 (用于极端NAT环境)
                        { urls: 'turn:numb.viagenie.ca', credential: 'muazkh', username: 'webrtc@live.com' },
                        { urls: 'turn:openrelay.metered.ca:443', credential: 'openrelayproject', username: 'openrelayproject' }
                    ],
'@

$count = ($content | Select-String -Pattern [regex]::Escape($oldIceServers) -AllMatches).Matches.Count
Write-Host "Found $count occurrences of old iceServers config"

$content = $content -replace [regex]::Escape($oldIceServers), $newIceServers

Set-Content -Path 'd:\AIcode\mecha-fight\index.html' -Value $content -NoNewline
Write-Host "Updated iceServers config"
