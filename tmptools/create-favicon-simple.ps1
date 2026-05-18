# PowerShell script to create a simple favicon.ico for mecha-fight
# This creates a minimal valid ICO file with a 16x16 and 32x32 icon

$outputPath = Join-Path $PSScriptRoot "favicon.ico"

# Create a simple ICO file with pixel data
# ICO format: Header (6 bytes) + Directory Entry (16 bytes per image) + Image Data

function Create-SimpleIco {
    param([string]$OutputPath)
    
    # ICO Header (6 bytes)
    $header = [byte[]]@(
        0, 0,  # Reserved, must be 0
        1, 0,  # Type: 1 = ICO
        2, 0   # Number of images: 2
    )
    
    # We'll create two sizes: 16x16 and 32x32
    $sizes = @(16, 32)
    $imageDataList = @()
    
    foreach ($size in $sizes) {
        # Create bitmap data (BGRA format, bottom-up)
        $bmpData = @()
        
        # Bitmap Info Header (40 bytes) - BITMAPINFOHEADER
        $bmpHeader = [byte[]]@(
            40, 0, 0, 0,   # biSize = 40
            [byte]($size -band 0xFF), [byte](($size -shr 8) -band 0xFF), 0, 0,  # biWidth
            [byte]($size * 2 -band 0xFF), [byte](($size * 2 -shr 8) -band 0xFF), 0, 0,  # biHeight (doubled for AND mask)
            1, 0,           # biPlanes = 1
            32, 0,          # biBitCount = 32
            0, 0, 0, 0,    # biCompression = 0
            0, 0, 0, 0,    # biSizeImage (can be 0 for uncompressed)
            0, 0, 0, 0,    # biXPelsPerMeter
            0, 0, 0, 0,    # biYPelsPerMeter
            0, 0, 0, 0,    # biClrUsed
            0, 0, 0, 0     # biClrImportant
        )
        
        # Pixel data (BGRA, bottom-up)
        $pixelSize = $size * 4  # 4 bytes per pixel (BGRA)
        $rowSize = $pixelSize
        
        # Create pixel art (simplified mecha face)
        # Pattern: 8x8 scaled to size
        $scale = $size / 8
        
        # Colors (BGRA format)
        $transparent = @(0, 0, 0, 0)
        $red = @(68, 68, 255, 255)       # BGRA
        $darkRed = @(50, 50, 200, 255)   # BGRA
        $yellow = @(0, 255, 255, 255)    # BGRA
        $gray = @(85, 85, 85, 255)       # BGRA
        $white = @(255, 255, 255, 255)   # BGRA
        $black = @(0, 0, 0, 255)         # BGRA
        
        # Pixel pattern (8x8)
        $pattern = @(
            "........",
            "..GGGG..",
            ".GRRRRG.",
            ".GYYYYG.",
            ".GWWBWG.",
            ".GGGGGG.",
            "..RRRR..",
            "........"
        )
        
        $colorMap = @{
            '.' = $transparent
            'G' = $gray
            'R' = $red
            'Y' = $yellow
            'W' = $white
            'B' = $black
        }
        
        # Generate pixel data (bottom-up, so reverse Y)
        for ($y = 7; $y -ge 0; $y--) {
            $row = $pattern[$y]
            for ($px = 0; $px -lt $size; $px++) {
                $patternX = [int]($px / $scale)
                $char = if ($patternX -lt 8) { $row[$patternX] } else { '.' }
                $color = $colorMap[$char]
                
                # Add pixel (BGRA)
                $bmpData += $color
            }
        }
        
        # AND mask (1 bit per pixel, padded to 4 bytes per row)
        $andMaskRowSize = [int]([Math]::Ceiling($size / 32) * 4)
        $andMask = @()
        for ($y = 0; $y -lt $size; $y++) {
            for ($byteIdx = 0; $byteIdx -lt $andMaskRowSize; $byteIdx++) {
                $andMask += 0
            }
        }
        
        $imageData = $bmpHeader + $bmpData + $andMask
        $imageDataList += ,@{
            Size = $size
            Data = $imageData
        }
    }
    
    # Build directory entries
    $directory = @()
    $offset = 6 + (16 * $sizes.Count)  # After header and directory entries
    
    foreach ($img in $imageDataList) {
        $s = $img.Size
        $dataLen = $img.Data.Length
        
        $entry = [byte[]]@(
            [byte]($s -band 0xFF),  # Width (0 means 256)
            [byte]($s -band 0xFF),  # Height (0 means 256)
            0,                        # Color palette (0 = no palette)
            0,                        # Reserved
            1, 0,                    # Color planes
            32, 0,                   # Bits per pixel
            [byte]($dataLen -band 0xFF),
            [byte](($dataLen -shr 8) -band 0xFF),
            [byte](($dataLen -shr 16) -band 0xFF),
            [byte](($dataLen -shr 24) -band 0xFF),
            [byte]($offset -band 0xFF),
            [byte](($offset -shr 8) -band 0xFF),
            [byte](($offset -shr 16) -band 0xFF),
            [byte](($offset -shr 24) -band 0xFF)
        )
        $directory += $entry
        $offset += $dataLen
    }
    
    # Combine all parts
    $icoData = $header
    foreach ($entry in $directory) {
        $icoData += $entry
    }
    foreach ($img in $imageDataList) {
        $icoData += $img.Data
    }
    
    # Write to file
    [System.IO.File]::WriteAllBytes($OutputPath, [byte[]]$icoData)
    Write-Host "✓ favicon.ico 已生成: $OutputPath" -ForegroundColor Green
}

# Run
Create-SimpleIco -OutputPath $outputPath
