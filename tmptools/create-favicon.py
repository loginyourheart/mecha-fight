#!/usr/bin/env python3
"""
生成 mecha-fight 游戏的 favicon.ico
"""
from PIL import Image, ImageDraw

def create_favicon():
    # 创建一个 32x32 的图像
    size = 32
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 颜色定义
    red = (255, 68, 68, 255)
    dark_red = (200, 50, 30, 255)
    yellow = (255, 255, 0, 255)
    gray = (85, 85, 85, 255)
    white = (255, 255, 255, 255)
    black = (0, 0, 0, 255)
    
    # 像素艺术图案 (8x8 网格，每个像素 = 4x4 真实像素)
    pixels = [
        "........",
        "..GGGG..",
        ".GRRRRG.",
        ".GYYYYG.",
        ".GWWBWG.",
        ".GGGGGG.",
        "..RRRR..",
        "........"
    ]
    
    # 颜色映射
    color_map = {
        'G': gray,
        'R': red,
        'Y': yellow,
        'W': white,
        'B': black
    }
    
    # 绘制像素艺术
    pixel_size = 4
    for y, row in enumerate(pixels):
        for x, char in enumerate(row):
            if char != '.':
                color = color_map[char]
                # 绘制带边框的像素
                draw.rectangle([x * pixel_size, y * pixel_size, 
                              (x + 1) * pixel_size - 1, (y + 1) * pixel_size - 1], 
                              fill=color)
    
    # 添加边框
    draw.rectangle([0, 0, size - 1, size - 1], outline=red, width=2)
    
    # 保存为 ICO 格式
    favicon_path = 'favicon.ico'
    img.save(favicon_path, format='ICO', sizes=[(size, size)])
    print(f"✓ favicon.ico 已生成: {favicon_path}")
    
    # 同时生成 PNG 预览
    png_path = 'favicon-preview.png'
    img.save(png_path, format='PNG')
    print(f"✓ 预览图片已生成: {png_path}")
    
    return img

if __name__ == '__main__':
    create_favicon()
