# PowerShell script to generate favicon.ico using .NET System.Drawing
Add-Type -AssemblyName System.Drawing

$outputPath = Join-Path $PSScriptRoot "favicon.ico"

# Create a 32x32 bitmap
$size = 32
$bitmap = New-Object System.Drawing.Bitmap($size, $size)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Clear background (transparent)
$graphics.Clear([System.Drawing.Color]::Transparent)

# Define colors
$red = [System.Drawing.Color]::FromArgb(255, 68, 68)
$gray = [System.Drawing.Color]::FromArgb(85, 85, 85)
$yellow = [System.Drawing.Color]::FromArgb(255, 255, 0)
$white = [System.Drawing.Color]::FromArgb(255, 255, 255)
$black = [System.Drawing.Color]::FromArgb(0, 0, 0)

# Pixel art pattern (8x8)
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

# Color mapping
$colorMap = @{
    'G' = $gray
    'R' = $red
    'Y' = $yellow
    'W' = $white
    'B' = $black
}

# Draw pixels (each pattern pixel = 4x4 real pixels)
$pixelSize = 4
for ($y = 0; $y -lt 8; $y++) {
    $row = $pattern[$y]
    for ($x = 0; $x -lt 8; $x++) {
        $char = $row[$x]
        if ($char -ne '.') {
            $color = $colorMap[$char]
            $graphics.FillRectangle((New-Object System.Drawing.SolidBrush($color)), 
                ($x * $pixelSize), 
                ($y * $pixelSize), 
                $pixelSize, 
                $pixelSize)
        }
    }
}

# Draw border
$pen = New-Object System.Drawing.Pen($red, 2)
$graphics.DrawRectangle($pen, 1, 1, ($size - 2), ($size - 2))

# Save as ICO using Icon class
$hicon = $bitmap.GetHicon()
$icon = [System.Drawing.Icon]::FromHandle($hicon)

# Save to file
$stream = [System.IO.File]::Create($outputPath)
$icon.Save($stream)
$stream.Close()

# Cleanup
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "favicon.ico has been generated at: $outputPath" -ForegroundColor Green
