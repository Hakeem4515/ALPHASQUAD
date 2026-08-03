Add-Type -AssemblyName System.Drawing

function Save-RoundedIcon {
    param (
        [System.Drawing.Bitmap]$Source,
        [int]$TargetSize,
        [double]$RadiusPercent = 22.0,
        [bool]$Rounded = $true,
        [bool]$Transparent = $false
    )
    
    # Create result bitmap
    $pixelFormat = if ($Transparent) { [System.Drawing.Imaging.PixelFormat]::Format32bppArgb } else { [System.Drawing.Imaging.PixelFormat]::Format32bppRgb }
    $result = New-Object System.Drawing.Bitmap($TargetSize, $TargetSize, $pixelFormat)
    $gr = [System.Drawing.Graphics]::FromImage($result)
    $gr.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gr.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $gr.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $gr.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    if ($Transparent) {
        $gr.Clear([System.Drawing.Color]::Transparent)
    } else {
        $gr.Clear([System.Drawing.Color]::FromArgb(10, 25, 49))
    }
    
    if ($Rounded) {
        # Clamp radius so it's at most 50% of half the size
        $maxRadius = [int]($TargetSize / 2) - 1
        $radius = [math]::Min([int]($TargetSize * $RadiusPercent / 100.0), $maxRadius)
        if ($radius -lt 1) { $radius = 1 }
        $diameter = $radius * 2
        
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        # Top-left arc
        $path.AddArc([float]0, [float]0, [float]$diameter, [float]$diameter, [float]180, [float]90)
        # Top-right arc
        $path.AddArc([float]($TargetSize - $diameter), [float]0, [float]$diameter, [float]$diameter, [float]270, [float]90)
        # Bottom-right arc
        $path.AddArc([float]($TargetSize - $diameter), [float]($TargetSize - $diameter), [float]$diameter, [float]$diameter, [float]0, [float]90)
        # Bottom-left arc
        $path.AddArc([float]0, [float]($TargetSize - $diameter), [float]$diameter, [float]$diameter, [float]90, [float]90)
        $path.CloseFigure()
        
        $gr.SetClip($path)
        $gr.DrawImage($Source, 0, 0, $TargetSize, $TargetSize)
        $path.Dispose()
    } else {
        $gr.DrawImage($Source, 0, 0, $TargetSize, $TargetSize)
    }
    
    $gr.Dispose()
    return $result
}

# Load source image
$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcePath = Join-Path $projectDir "app_icon.png"

Write-Host "Loading source image: $sourcePath" -ForegroundColor Cyan
$source = New-Object System.Drawing.Bitmap($sourcePath)
Write-Host "Source size: $($source.Width)x$($source.Height)" -ForegroundColor Green

# === Android Icons ===
Write-Host "`nGenerating Android icons..." -ForegroundColor Yellow
$androidRes = Join-Path $projectDir "android\app\src\main\res"

$androidSizes = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($folder in @("mipmap-mdpi", "mipmap-hdpi", "mipmap-xhdpi", "mipmap-xxhdpi", "mipmap-xxxhdpi")) {
    $size = $androidSizes[$folder]
    $folderPath = Join-Path $androidRes $folder
    
    # ic_launcher.png - with rounded corners (22% = ~same as Android icon shape)
    $bitmap = Save-RoundedIcon -Source $source -TargetSize $size -RadiusPercent 22 -Rounded $true
    $outPath = Join-Path $folderPath "ic_launcher.png"
    $bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    Write-Host "  Saved: $folder/ic_launcher.png ($size x $size)" -ForegroundColor Green
    
    # ic_launcher_round.png - full circle (50%)
    $roundPath = Join-Path $folderPath "ic_launcher_round.png"
    if (Test-Path $roundPath) {
        $bitmap2 = Save-RoundedIcon -Source $source -TargetSize $size -RadiusPercent 50 -Rounded $true
        $bitmap2.Save($roundPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap2.Dispose()
        Write-Host "  Saved: $folder/ic_launcher_round.png ($size x $size)" -ForegroundColor Green
    }
}

# === iOS Icons ===
Write-Host "`nGenerating iOS icons..." -ForegroundColor Yellow
$iosIconset = Join-Path $projectDir "ios\Runner\Assets.xcassets\AppIcon.appiconset"

$iosIcons = @(
    @{Name="Icon-App-20x20@1x.png";     Size=20},
    @{Name="Icon-App-20x20@2x.png";     Size=40},
    @{Name="Icon-App-20x20@3x.png";     Size=60},
    @{Name="Icon-App-29x29@1x.png";     Size=29},
    @{Name="Icon-App-29x29@2x.png";     Size=58},
    @{Name="Icon-App-29x29@3x.png";     Size=87},
    @{Name="Icon-App-40x40@1x.png";     Size=40},
    @{Name="Icon-App-40x40@2x.png";     Size=80},
    @{Name="Icon-App-40x40@3x.png";     Size=120},
    @{Name="Icon-App-60x60@2x.png";     Size=120},
    @{Name="Icon-App-60x60@3x.png";     Size=180},
    @{Name="Icon-App-76x76@1x.png";     Size=76},
    @{Name="Icon-App-76x76@2x.png";     Size=152},
    @{Name="Icon-App-83.5x83.5@2x.png"; Size=167},
    @{Name="Icon-App-1024x1024@1x.png"; Size=1024}
)

foreach ($icon in $iosIcons) {
    $outPath = Join-Path $iosIconset $icon.Name
    # iOS handles its own rounding system-wide - just composite clean image on bg
    $bitmap = Save-RoundedIcon -Source $source -TargetSize $icon.Size -Rounded $false
    $bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    Write-Host "  Saved: $($icon.Name) ($($icon.Size) x $($icon.Size))" -ForegroundColor Green
}

$source.Dispose()

Write-Host "`n✅ All icons generated successfully!" -ForegroundColor Cyan
Write-Host "Android: rounded corners (22% radius) applied to ic_launcher.png" -ForegroundColor White
Write-Host "iOS: clean image (system applies its own rounded corners)" -ForegroundColor White
