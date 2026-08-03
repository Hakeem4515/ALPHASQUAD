// ignore_for_file: avoid_print, depend_on_referenced_packages, unused_element

import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() async {
  final scriptDir = Directory.current.path;
  final sourcePath = '$scriptDir/app_icon.png';

  print('Loading source image: $sourcePath');
  final sourceFile = File(sourcePath);

  if (!await sourceFile.exists()) {
    print('ERROR: app_icon.png not found!');
    exit(1);
  }

  final sourceBytes = await sourceFile.readAsBytes();
  final sourceImage = img.decodeImage(sourceBytes)!;
  print('Source size: ${sourceImage.width}x${sourceImage.height}');

  // Function to add rounded corners
  img.Image addRoundedCorners(img.Image source, double radiusPercent) {
    final width = source.width;
    final height = source.height;
    final radius = (math.min(width, height) * radiusPercent / 100).round();

    final result = img.Image(width: width, height: height, numChannels: 4);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = source.getPixel(x, y);

        // Check if pixel is in the rounded corner region
        bool inCorner = false;

        // Top-left corner
        if (x < radius && y < radius) {
          final dx = radius - x - 1;
          final dy = radius - y - 1;
          inCorner = dx * dx + dy * dy > radius * radius;
        }
        // Top-right corner
        else if (x >= width - radius && y < radius) {
          final dx = x - (width - radius);
          final dy = radius - y - 1;
          inCorner = dx * dx + dy * dy > radius * radius;
        }
        // Bottom-left corner
        else if (x < radius && y >= height - radius) {
          final dx = radius - x - 1;
          final dy = y - (height - radius);
          inCorner = dx * dx + dy * dy > radius * radius;
        }
        // Bottom-right corner
        else if (x >= width - radius && y >= height - radius) {
          final dx = x - (width - radius);
          final dy = y - (height - radius);
          inCorner = dx * dx + dy * dy > radius * radius;
        }

        if (inCorner) {
          result.setPixelRgba(x, y, 0, 0, 0, 0);
        } else {
          result.setPixelRgba(
            x,
            y,
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            pixel.a.toInt(),
          );
        }
      }
    }
    return result;
  }

  // Function to composite RGBA image on dark background -> RGB
  img.Image compositeOnBackground(
    img.Image source,
    int size, {
    int r = 10,
    int g = 25,
    int b = 49,
  }) {
    final resized = img.copyResize(
      source,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
    final bg = img.Image(width: size, height: size, numChannels: 3);
    img.fill(bg, color: img.ColorRgb8(r, g, b));

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = resized.getPixel(x, y);
        final alpha = pixel.a / 255.0;
        if (alpha > 0) {
          final bgPixel = bg.getPixel(x, y);
          final newR = (pixel.r * alpha + bgPixel.r * (1 - alpha)).round();
          final newG = (pixel.g * alpha + bgPixel.g * (1 - alpha)).round();
          final newB = (pixel.b * alpha + bgPixel.b * (1 - alpha)).round();
          bg.setPixelRgb(x, y, newR, newG, newB);
        }
      }
    }
    return bg;
  }

  Future<void> saveIcon(img.Image image, String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(img.encodePng(image));
    print('  Saved: ${file.path.split(Platform.pathSeparator).last}');
  }

  // === Android Icons ===
  print('\nGenerating Android icons...');
  final androidRes = '$scriptDir/android/app/src/main/res';

  final androidSizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in androidSizes.entries) {
    final folder = entry.key;
    final size = entry.value;

    // ic_launcher.png - with rounded corners on dark background
    final resized = img.copyResize(
      sourceImage,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
    final rounded = addRoundedCorners(resized, 22);
    final composited = img.Image(width: size, height: size, numChannels: 3);
    img.fill(composited, color: img.ColorRgb8(10, 25, 49));
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = rounded.getPixel(x, y);
        final alpha = pixel.a / 255.0;
        if (alpha > 0) {
          final bgPixel = composited.getPixel(x, y);
          final newR = (pixel.r * alpha + bgPixel.r * (1 - alpha)).round();
          final newG = (pixel.g * alpha + bgPixel.g * (1 - alpha)).round();
          final newB = (pixel.b * alpha + bgPixel.b * (1 - alpha)).round();
          composited.setPixelRgb(x, y, newR, newG, newB);
        }
      }
    }
    await saveIcon(composited, '$androidRes/$folder/ic_launcher.png');

    // ic_launcher_round.png - circular version
    final roundFile = File('$androidRes/$folder/ic_launcher_round.png');
    if (await roundFile.exists()) {
      final resized2 = img.copyResize(
        sourceImage,
        width: size,
        height: size,
        interpolation: img.Interpolation.cubic,
      );
      final rounded2 = addRoundedCorners(resized2, 50); // Full circle
      final composited2 = img.Image(width: size, height: size, numChannels: 3);
      img.fill(composited2, color: img.ColorRgb8(10, 25, 49));
      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          final pixel = rounded2.getPixel(x, y);
          final alpha = pixel.a / 255.0;
          if (alpha > 0) {
            final bgPixel = composited2.getPixel(x, y);
            final newR = (pixel.r * alpha + bgPixel.r * (1 - alpha)).round();
            final newG = (pixel.g * alpha + bgPixel.g * (1 - alpha)).round();
            final newB = (pixel.b * alpha + bgPixel.b * (1 - alpha)).round();
            composited2.setPixelRgb(x, y, newR, newG, newB);
          }
        }
      }
      await saveIcon(composited2, '$androidRes/$folder/ic_launcher_round.png');
    }
  }

  // === iOS Icons ===
  print('\nGenerating iOS icons...');
  final iosIconset = '$scriptDir/ios/Runner/Assets.xcassets/AppIcon.appiconset';

  final iosIcons = [
    ('Icon-App-20x20@1x.png', 20),
    ('Icon-App-20x20@2x.png', 40),
    ('Icon-App-20x20@3x.png', 60),
    ('Icon-App-29x29@1x.png', 29),
    ('Icon-App-29x29@2x.png', 58),
    ('Icon-App-29x29@3x.png', 87),
    ('Icon-App-40x40@1x.png', 40),
    ('Icon-App-40x40@2x.png', 80),
    ('Icon-App-40x40@3x.png', 120),
    ('Icon-App-60x60@2x.png', 120),
    ('Icon-App-60x60@3x.png', 180),
    ('Icon-App-76x76@1x.png', 76),
    ('Icon-App-76x76@2x.png', 152),
    ('Icon-App-83.5x83.5@2x.png', 167),
    ('Icon-App-1024x1024@1x.png', 1024),
  ];

  for (final entry in iosIcons) {
    final filename = entry.$1;
    final size = entry.$2;

    // iOS applies its own rounded corners - just composite on background
    final resized = img.copyResize(
      sourceImage,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
    final composited = img.Image(width: size, height: size, numChannels: 3);
    img.fill(composited, color: img.ColorRgb8(10, 25, 49));
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = resized.getPixel(x, y);
        final alpha = pixel.a / 255.0;
        if (alpha > 0) {
          final bgPixel = composited.getPixel(x, y);
          final newR = (pixel.r * alpha + bgPixel.r * (1 - alpha)).round();
          final newG = (pixel.g * alpha + bgPixel.g * (1 - alpha)).round();
          final newB = (pixel.b * alpha + bgPixel.b * (1 - alpha)).round();
          composited.setPixelRgb(x, y, newR, newG, newB);
        }
      }
    }
    await saveIcon(composited, '$iosIconset/$filename');
  }

  print('\n✅ All icons generated successfully!');
}
