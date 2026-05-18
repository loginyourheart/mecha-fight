// 生成 favicon.ico
const fs = require('fs');

// 像素艺术图案 (8x8)
const pattern = [
    "........",
    "..GGGG..",
    ".GRRRRG.",
    ".GYYYYG.",
    ".GWWBWG.",
    ".GGGGGG.",
    "..RRRR..",
    "........"
];

// 颜色 (RGBA)
const colors = {
    '.': [0, 0, 0, 0],       // 透明
    'G': [85, 85, 85, 255],  // 灰色
    'R': [255, 68, 68, 255], // 红色
    'Y': [255, 255, 0, 255], // 黄色
    'W': [255, 255, 255, 255], // 白色
    'B': [0, 0, 0, 255]      // 黑色
};

function createBitmapData(size) {
    const pixelData = [];
    
    // BITMAPINFOHEADER (40 bytes)
    const header = Buffer.alloc(40);
    header.writeUInt32LE(40, 0);           // biSize
    header.writeInt32LE(size, 4);          // biWidth
    header.writeInt32LE(size * 2, 8);      // biHeight (加倍，包含 AND mask)
    header.writeUInt16LE(1, 12);           // biPlanes
    header.writeUInt16LE(32, 14);          // biBitCount
    header.writeUInt32LE(0, 16);            // biCompression
    // biSizeImage 和其他字段
    
    // 像素数据 (BGRA 格式，底部向上)
    for (let y = 7; y >= 0; y--) {
        const row = pattern[y];
        for (let x = 0; x < 8; x++) {
            const char = row[x];
            const color = colors[char];
            // BGRA 格式
            pixelData.push(color[2], color[1], color[0], color[3]);
        }
        // 填充到 size 像素
        for (let x = 8; x < size; x++) {
            pixelData.push(0, 0, 0, 0);
        }
    }
    
    // 填充剩余的行
    for (let y = 7; y >= 0; y--) {
        for (let x = 8; x < size; x++) {
            pixelData.push(0, 0, 0, 0);
        }
    }
    
    // AND mask
    const andMaskRowSize = Math.ceil(size / 32) * 4;
    const andMaskSize = andMaskRowSize * size;
    const andMask = Buffer.alloc(andMaskSize, 0);
    
    // 更新 header
    header.writeUInt32LE(pixelData.length + andMaskSize, 20);
    
    return Buffer.concat([header, Buffer.from(pixelData), andMask]);
}

function createIco() {
    const size = 32;
    const imageData = createBitmapData(size);
    
    // ICO Header (6 bytes)
    const header = Buffer.alloc(6);
    header.writeUInt16LE(0, 0);     // Reserved
    header.writeUInt16LE(1, 2);     // Type: ICO
    header.writeUInt16LE(1, 4);     // Count: 1
    
    // Directory Entry (16 bytes)
    const dirEntry = Buffer.alloc(16);
    dirEntry.writeUInt8(size, 0);           // Width
    dirEntry.writeUInt8(size, 1);           // Height
    dirEntry.writeUInt8(0, 2);             // ColorCount
    dirEntry.writeUInt8(0, 3);             // Reserved
    dirEntry.writeUInt16LE(1, 4);          // Planes
    dirEntry.writeUInt16LE(32, 6);         // BitCount
    dirEntry.writeUInt32LE(imageData.length, 8);  // Size
    dirEntry.writeUInt32LE(22, 12);         // Offset (6 + 16)
    
    return Buffer.concat([header, dirEntry, imageData]);
}

// 生成并保存
const icoData = createIco();
fs.writeFileSync('favicon.ico', icoData);
console.log('✓ favicon.ico 已生成！');
