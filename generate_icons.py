"""
Script to generate app icons with rounded corners from app_icon.png
"""
# pyrefly: ignore [missing-import]
from PIL import Image, ImageDraw
import os
import shutil

def add_rounded_corners(image, radius_percent=22):
    """Add rounded corners to an image."""
    img = image.convert("RGBA")
    width, height = img.size
    radius = int(min(width, height) * radius_percent / 100)
    
    # Create a mask with rounded corners
    mask = Image.new("L", (width, height), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (width - 1, height - 1)], radius=radius, fill=255)
    
    # Apply the mask
    result = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    result.paste(img, mask=mask)
    return result

def resize_and_save(source_img, size, output_path, bg_color=(10, 25, 49, 255), add_rounded=True, radius_percent=22):
    """Resize image and save to output path."""
    img = source_img.copy()
    img = img.resize((size, size), Image.LANCZOS)
    
    if add_rounded:
        img = add_rounded_corners(img, radius_percent)
    
    # For non-transparent output (Android, iOS), composite on background
    if output_path.endswith('.png') and 'ios' in output_path.lower():
        # iOS doesn't support transparency in icons
        background = Image.new("RGB", (size, size), bg_color[:3])
        if img.mode == 'RGBA':
            background.paste(img, mask=img.split()[3])
        else:
            background.paste(img)
        background.save(output_path, 'PNG', optimize=True)
    else:
        img.save(output_path, 'PNG', optimize=True)
    
    print(f"  Saved: {os.path.basename(output_path)} ({size}x{size})")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    source_path = os.path.join(script_dir, "app_icon.png")
    
    print(f"Loading source image: {source_path}")
    source = Image.open(source_path).convert("RGBA")
    print(f"Source size: {source.size}")
    
    # Apply rounded corners to source (22% radius like iOS/Android icons)
    print("\nApplying rounded corners...")
    rounded_source = add_rounded_corners(source, radius_percent=22)
    
    # Save rounded version back as app_icon.png for flutter_launcher_icons
    rounded_path = os.path.join(script_dir, "app_icon_rounded.png")
    rounded_source.save(rounded_path, 'PNG')
    print(f"Saved rounded icon to: {rounded_path}")
    
    # === Android Icons ===
    print("\nGenerating Android icons...")
    android_res = os.path.join(script_dir, "android", "app", "src", "main", "res")
    
    android_sizes = {
        "mipmap-mdpi":    48,
        "mipmap-hdpi":    72,
        "mipmap-xhdpi":   96,
        "mipmap-xxhdpi":  144,
        "mipmap-xxxhdpi": 192,
    }
    
    for folder, size in android_sizes.items():
        folder_path = os.path.join(android_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        output_path = os.path.join(folder_path, "ic_launcher.png")
        
        # Android: save with rounded corners, composite on dark background
        img = source.copy().resize((size, size), Image.LANCZOS)
        img = add_rounded_corners(img, radius_percent=22)
        
        # Composite on dark background
        background = Image.new("RGB", (size, size), (10, 25, 49))
        background.paste(img, mask=img.split()[3])
        background.save(output_path, 'PNG', optimize=True)
        print(f"  Saved: {folder}/ic_launcher.png ({size}x{size})")
    
    # Also save a round version for ic_launcher_round
    for folder, size in android_sizes.items():
        folder_path = os.path.join(android_res, folder)
        output_path = os.path.join(folder_path, "ic_launcher_round.png")
        if os.path.exists(output_path):
            img = source.copy().resize((size, size), Image.LANCZOS)
            img = add_rounded_corners(img, radius_percent=50)  # Full circle
            background = Image.new("RGB", (size, size), (10, 25, 49))
            background.paste(img, mask=img.split()[3])
            background.save(output_path, 'PNG', optimize=True)
            print(f"  Saved: {folder}/ic_launcher_round.png ({size}x{size})")
    
    # Android foreground for adaptive icon
    foreground_sizes = {
        "mipmap-mdpi":    108,
        "mipmap-hdpi":    162,
        "mipmap-xhdpi":   216,
        "mipmap-xxhdpi":  324,
        "mipmap-xxxhdpi": 432,
    }
    for folder, size in foreground_sizes.items():
        folder_path = os.path.join(android_res, folder)
        fg_path = os.path.join(folder_path, "ic_launcher_foreground.png")
        if os.path.exists(fg_path):
            img = source.copy().resize((size, size), Image.LANCZOS)
            # For foreground, keep transparency (no rounding, system applies shape)
            img.save(fg_path, 'PNG', optimize=True)
            print(f"  Saved: {folder}/ic_launcher_foreground.png ({size}x{size})")
    
    # === iOS Icons ===
    print("\nGenerating iOS icons...")
    ios_appiconset = os.path.join(script_dir, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    
    ios_icons = [
        ("Icon-App-20x20@1x.png",     20),
        ("Icon-App-20x20@2x.png",     40),
        ("Icon-App-20x20@3x.png",     60),
        ("Icon-App-29x29@1x.png",     29),
        ("Icon-App-29x29@2x.png",     58),
        ("Icon-App-29x29@3x.png",     87),
        ("Icon-App-40x40@1x.png",     40),
        ("Icon-App-40x40@2x.png",     80),
        ("Icon-App-40x40@3x.png",     120),
        ("Icon-App-60x60@2x.png",     120),
        ("Icon-App-60x60@3x.png",     180),
        ("Icon-App-76x76@1x.png",     76),
        ("Icon-App-76x76@2x.png",     152),
        ("Icon-App-83.5x83.5@2x.png", 167),
        ("Icon-App-1024x1024@1x.png", 1024),
    ]
    
    for filename, size in ios_icons:
        output_path = os.path.join(ios_appiconset, filename)
        # iOS: NO transparency, composite on dark background
        # iOS applies its own rounding, so we don't round here
        img = source.copy().resize((size, size), Image.LANCZOS)
        background = Image.new("RGB", (size, size), (10, 25, 49))
        if img.mode == 'RGBA':
            background.paste(img, mask=img.split()[3])
        else:
            background.paste(img)
        background.save(output_path, 'PNG', optimize=True)
        print(f"  Saved: {filename} ({size}x{size})")
    
    print("\n✅ All icons generated successfully!")
    print("\nNote: iOS applies its own rounded corners system-wide.")
    print("Android rounded corners have been applied to ic_launcher.png files.")

if __name__ == "__main__":
    main()
