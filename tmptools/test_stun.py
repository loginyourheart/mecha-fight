#!/usr/bin/env python3
"""
STUN 服务器延迟测试工具
测试 STUN 服务器的连接延迟
"""

import socket
import struct
import time
import random
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

# STUN 服务器列表 (来自 always-online-stun 仓库)
STUN_SERVERS = [
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
    '51.68.45.75:3478',
    # 额外添加的服务器
    'stun.l.google.com:19302',
    'stun1.l.google.com:19302',
    'stun2.l.google.com:19302',
    'stun.qq.com:3478',
    'stun.miwifi.com:3478',
    'stun.nordvpn.com:3478',
    'global.stun.twilio.com:3478',
]

# IP地理位置猜测
GEO_HINTS = {
    '52.': 'AWS (美国)',
    '34.': 'AWS (美国)',
    '3.': 'AWS (美国)',
    '44.': 'AWS (美国)',
    '54.': 'AWS (美国)',
    '35.': 'AWS (欧洲)',
    '143.': 'DigitalOcean (新加坡)',
    '172.': 'Fastly/其他',
    '129.': 'Oracle Cloud',
    '147.': 'Google Cloud',
    '199.': 'Internet2 (美国)',
    '192.': 'Quest (美国)',
    '195.': '德国/欧洲',
    '188.': '德国 (Hetzner)',
    '62.': '荷兰',
    '95.': '瑞士',
    '176.': '德国 (Hetzner)',
    '49.': '德国 (Hetzner)',
    '51.': '法国/欧洲',
    '5.': '荷兰/其他',
    '66.': 'Linode (美国)',
    '46.': '瑞典',
    '85.': '爱沙尼亚',
    '91.': '欧洲',
    '88.': '德国 (Hetzner)',
    '213.': '法国',
    '81.': '比利时/荷兰',
    '87.': '德国 (1&1)',
    '137.': 'Scaleway (法国)',
    '108.': 'Host1Plus (南非)',
    '24.': '加拿大',
    '80.': '德国',
    '83.': '奥地利',
    '89.': '罗马尼亚',
    '90.': '瑞典',
    '94.': '德国 (Hetzner)',
    '136.': '德国 (Hetzner)',
    '197.': '尼日利亚/非洲',
    '202.': '新西兰/澳大利亚',
    '203.': '澳大利亚',
    '209.': '美国',
    '212.': '德国',
    '217.': '德国 (Intergenia)',
    'stun.l': 'Google',
    'stun1.l': 'Google',
    'stun2.l': 'Google',
    'stun.q': '腾讯 QQ (中国)',
    'stun.m': '小米 (中国)',
    'stun.n': 'NordVPN',
    'global.s': 'Twilio',
}

def get_geo_hint(addr):
    """获取服务器的大致地理位置"""
    for hint, location in GEO_HINTS.items():
        if addr.startswith(hint):
            return location
    return '未知'

def create_stun_binding_request():
    """创建 STUN BINDING REQUEST 数据包"""
    # STUN 消息头
    msg_type = 0x0001  # BINDING REQUEST
    msg_length = 0
    magic_cookie = 0x2112A442
    transaction_id = bytes([random.randint(0, 255) for _ in range(12)])
    
    # 消息头: type(2) + length(2) + magic_cookie(4) + transaction_id(12)
    header = struct.pack('!HHI12s', msg_type, msg_length, magic_cookie, transaction_id)
    
    # MESSAGE-INTEGRITY (20 bytes) - 可选，这里省略
    # FINGERPRINT (4 bytes) - 可选，这里省略
    
    return header

def test_stun_server(addr, timeout=2):
    """测试单个 STUN 服务器的延迟"""
    try:
        # 解析地址
        if ':' in addr:
            host, port_str = addr.rsplit(':', 1)
            port = int(port_str)
        else:
            host = addr
            port = 3478
        
        # 创建 UDP 套接字
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(timeout)
        
        # 发送 STUN BINDING REQUEST
        request = create_stun_binding_request()
        start_time = time.time()
        sock.sendto(request, (host, port))
        
        # 接收响应
        response, _ = sock.recvfrom(1024)
        end_time = time.time()
        
        sock.close()
        
        latency_ms = int((end_time - start_time) * 1000)
        return {
            'addr': addr,
            'latency': latency_ms,
            'status': '成功',
            'geo': get_geo_hint(addr)
        }
        
    except socket.timeout:
        return {
            'addr': addr,
            'latency': None,
            'status': '超时',
            'geo': get_geo_hint(addr)
        }
    except Exception as e:
        return {
            'addr': addr,
            'latency': None,
            'status': f'错误: {str(e)[:30]}',
            'geo': get_geo_hint(addr)
        }

def format_latency(latency):
    """格式化延迟显示"""
    if latency is None:
        return '失败'
    elif latency < 50:
        return f'{latency}ms ✓'
    elif latency < 100:
        return f'{latency}ms'
    elif latency < 200:
        return f'{latency}ms'
    else:
        return f'{latency}ms'

def main():
    print("=" * 70)
    print("🔍 STUN 服务器延迟测试")
    print("=" * 70)
    print(f"\n总共测试 {len(STUN_SERVERS)} 个服务器...\n")
    
    results = []
    completed = 0
    
    # 并发测试
    with ThreadPoolExecutor(max_workers=10) as executor:
        future_to_server = {
            executor.submit(test_stun_server, server): server 
            for server in STUN_SERVERS
        }
        
        for future in as_completed(future_to_server):
            result = future.result()
            results.append(result)
            completed += 1
            
            # 显示进度
            latency_str = format_latency(result['latency'])
            geo_str = result['geo'][:15]
            print(f"[{completed:2d}/{len(STUN_SERVERS)}] {result['addr']:<35} {latency_str:>12} {geo_str}")
    
    # 排序：成功的排前面，按延迟升序
    results.sort(key=lambda x: (x['latency'] is None, x['latency'] or 0))
    
    # 统计
    successful = [r for r in results if r['latency'] is not None]
    failed = [r for r in results if r['latency'] is None]
    
    print("\n" + "=" * 70)
    print("📊 测试结果摘要")
    print("=" * 70)
    print(f"总服务器数: {len(results)}")
    print(f"成功连接: {len(successful)}")
    print(f"失败: {len(failed)}")
    
    if successful:
        avg_latency = sum(r['latency'] for r in successful) / len(successful)
        print(f"平均延迟: {avg_latency:.1f}ms")
    
    # 显示最佳服务器
    print("\n" + "=" * 70)
    print("🏆 最佳服务器 (可复制到游戏配置中)")
    print("=" * 70)
    
    best_servers = successful[:10]
    for i, server in enumerate(best_servers, 1):
        print(f"{i:2d}. stun:{server['addr']:<30} ({server['latency']}ms) [{server['geo']}]")
    
    # 生成配置代码
    print("\n" + "=" * 70)
    print("📋 可直接使用的 ICE 配置")
    print("=" * 70)
    print("iceServers: [")
    for server in best_servers[:5]:
        print(f"    {{ urls: 'stun:{server['addr']}' }},")
    print("]")
    
    return best_servers

if __name__ == '__main__':
    try:
        best = main()
    except KeyboardInterrupt:
        print("\n\n测试被用户中断")
        sys.exit(0)
