#!/usr/bin/env python3
"""
生成 mecha-fight 游戏的 favicon.ico
"""
import struct
import zlib

def create_favicon():
    # 像素艺术图案 (8x8)
    pattern = [
        "........",
        "..GGGG..",
        ".GRRRRG.",
        ".GYYYYG.",
        ".GWWBWG.",
        ".GGGGGG.",
        "..RRRR..",
        "........"
    ]
    
    # 颜色 (RGBA)
    colors = {
        '.': (0, 0, 0, 0),       # 透明
        'G': (85, 85, 85, 255),  # 灰色
        'R': (255, 68, 68, 255), # 红色
        'Y': (255, 255, 0, 255), # 黄色
        'W': (255, 255, 255, 255), # 白色
        'B': (0, 0, 0, 255)      # 黑色
    }
    
    # 生成 32x32 的图像数据 (BGRA格式，底部向上)
    size = 32
    pixel_data = []
    
    for y in range(7, -1, -1):  # 反向遍历 Y
        row = pattern[y]
        for x in range(8):
            char = row[x]
            color = colors[char]
            # BGRA 格式
            pixel_data.extend([color[2], color[1], color[0], color[3]])
        
        # 填充到 32 像素
        for x in range(8, size):
            pixel_data.extend([0, 0, 0, 0])
    
    # 填充整个行
    row_padding = (size - 8) * 4
    for y in range(7, -1, -1):
        for x in range(size):
            if x >= 8:
                pixel_data.extend([0, 0, 0, 0])
    
    # 计算实际数据大小
    pixel_data_size = len(pixel_data)
    
    # 创建 AND mask (所有像素都不透明)
    and_mask_size = ((size + 31) // 32) * 4 * size  # 每行 4 字节对齐
    and_mask = [0] * and_mask_size
    
    # BITMAPINFOHEADER (40 bytes)
    bmp_header = struct.pack('<IiiHHIIiiII', 
        40,           # biSize
        size,         # biWidth
        size * 2,     # biHeight (加倍，包含 AND mask)
        1,            # biPlanes
        32,           # biBitCount (32-bit ARGB)
        0,            # biCompression
        pixel_data_size + and_mask_size,  # biSizeImage
        0, 0,         # biXPelsPerMeter, biYPelsPerMeter
        0, 0          # biClrUsed, biClrImportant
    )
    
    # 完整的图像数据
    image_data = bmp_header + bytes(pixel_data) + bytes(and_mask)
    
    # ICO Header (6 bytes)
    ico_header = struct.pack('<HHH', 0, 1, 1)  # Reserved, Type=ICO, Count=1
    
    # Directory Entry (16 bytes)
    dir_entry = struct.pack('<BBBBHHII',
        size,           # Width
        size,           # Height
        0,              # ColorCount
        0,              # Reserved
        1,              # Planes
        32,             # BitCount
        len(image_data),# BytesInRes
        6 + 16          # ImageOffset
    )
    
    # 合并所有数据
    ico_file = ico_header + dir_entry + image_data
    
    # 写入文件
    with open('favicon.ico', 'wb') as f:
        f.write(ico_file)
    
    print('✓ favicon.ico 已生成！')

if __name__ == '__main__':
    create_favicon()
