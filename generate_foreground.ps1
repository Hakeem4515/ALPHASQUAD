Add-Type -AssemblyName System.Drawing

$projectDir = "D:\captuers\AlphaSquad\App\SOLARX"
$sourcePath = Join-Path $projectDir "app_icon.png"

Write-Host "Creating ic_launcher_foreground.png files..." -ForegroundColor Cyan
$source = New-Object System.Drawing.Bitmap($sourcePath)

$foregroundSizes = @{
    "mipmap-mdpi"    = 108
    "mipmap-hdpi"    = 162
    "mipmap-xhdpi"   = 216
    "mipmap-xxhdpi"  = 324
    "mipmap-xxxhdpi" = 432
}

$androidRes = Join-Path $projectDir "android\app\src\main\res"

foreach ($folder in @("mipmap-mdpi", "mipmap-hdpi", "mipmap-xhdpi", "mipmap-xxhdpi", "mipmap-xxxhdpi")) {
    $size = $foregroundSizes[$folder]
    $folderPath = Join-Path $androidRes $folder
    
    $bitmap = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gr = [System.Drawing.Graphics]::FromImage($bitmap)
    $gr.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gr.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $gr.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $gr.Clear([System.Drawing.Color]::Transparent)
    $gr.DrawImage($source, 0, 0, $size, $size)
    $gr.Dispose()
    
    $outPath = Join-Path $folderPath "ic_launcher_foreground.png"
    $bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    Write-Host "  Saved: $folder/ic_launcher_foreground.png ($size x $size)" -ForegroundColor Green
}

# Also save in drawable folder
$drawablePath = Join-Path $androidRes "drawable"
$bitmap3 = New-Object System.Drawing.Bitmap(432, 432, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gr3 = [System.Drawing.Graphics]::FromImage($bitmap3)
$gr3.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gr3.Clear([System.Drawing.Color]::Transparent)
$gr3.DrawImage($source, 0, 0, 432, 432)
$gr3.Dispose()
$bitmap3.Save((Join-Path $drawablePath "ic_launcher_foreground.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap3.Dispose()
Write-Host "  Saved: drawable/ic_launcher_foreground.png (432 x 432)" -ForegroundColor Green

$source.Dispose()
Write-Host "`n✅ Foreground icons created!" -ForegroundColor Cyan
