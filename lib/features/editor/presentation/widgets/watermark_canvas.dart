import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../core/providers/editor_provider.dart';
import '../../../../core/models/frame_template.dart';
import '../../../../core/utils/exif_util.dart';
import 'dart:io';

class WatermarkCanvas extends StatelessWidget {
  final ScreenshotController screenshotController;

  const WatermarkCanvas({super.key, required this.screenshotController});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    if (!provider.hasImage) {
      return const Center(child: Text('No Image Selected'));
    }

    final style = provider.currentStyle;
    final exif = provider.exifData;
    final brand = provider.activeBrand;

    // Select the builder based on the layout type
    Widget layoutWidget;
    switch (style.layout) {
      case FrameLayout.polaroid:
        layoutWidget = _buildPolaroidLayout(
          style,
          brand,
          exif,
          provider.selectedImage!.path,
        );
        break;
      case FrameLayout.minimalist:
        layoutWidget = _buildMinimalistLayout(
          style,
          brand,
          exif,
          provider.selectedImage!.path,
        );
        break;
      case FrameLayout.deviceClassic:
        layoutWidget = _buildClassicLayout(
          style,
          brand,
          exif,
          provider.selectedImage!.path,
        );
        break;
    }

    return Screenshot(
      controller: screenshotController,
      child: Container(
        color: style.backgroundColor,
        padding: const EdgeInsets.all(
          20,
        ), // Responsive padding should be calculated here eventually
        child: layoutWidget,
      ),
    );
  }

  // ==========================================
  // TEMPLATE 1: CLASSIC DEVICE (Original)
  // ==========================================
  Widget _buildClassicLayout(
    FrameStyle style,
    DeviceBrand brand,
    ExifData? exif,
    String imagePath,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageWithShadow(style, imagePath),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              brand.displayName,
              style: TextStyle(
                color: _getTextColor(style),
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: 24,
                letterSpacing: 2.0,
              ),
            ),
            if (exif != null) _buildExifTextRight(exif, style),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // TEMPLATE 2: POLAROID (Vintage, thick bottom)
  // ==========================================
  Widget _buildPolaroidLayout(
    FrameStyle style,
    DeviceBrand brand,
    ExifData? exif,
    String imagePath,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageWithShadow(style, imagePath),
        const SizedBox(height: 40), // Ruang bawah yang luas khas polaroid
        Center(
          child: Text(
            exif?.dateTimeOriginal.split(' ').first ?? 'MY MEMORY',
            style: const TextStyle(
              color: Colors.black87,
              fontFamily: 'Caveat', // Jika menggunakan Google Fonts handwritten
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // ==========================================
  // TEMPLATE 3: MINIMALIST
  // ==========================================
  Widget _buildMinimalistLayout(
    FrameStyle style,
    DeviceBrand brand,
    ExifData? exif,
    String imagePath,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageWithShadow(style, imagePath),
        const SizedBox(height: 30),
        Center(
          child: Column(
            children: [
              Text(
                '— ${brand.displayName} —',
                style: TextStyle(
                  color: _getTextColor(style),
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 8),
              if (exif != null)
                Text(
                  '${exif.focalLength} | f/${exif.fNumber} | ISO${exif.isoSpeedRatings}',
                  style: TextStyle(
                    color: _getTextColor(style).withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 2.0,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Color _getTextColor(FrameStyle style) {
    // Determine text color based on background lightness
    return style.backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  Widget _buildImageWithShadow(FrameStyle style, String imagePath) {
    Widget imageWidget = Image.file(File(imagePath), fit: BoxFit.contain);

    // Apply Photo Filters
    if (style.filter != PhotoFilter.none) {
      imageWidget = ColorFiltered(
        colorFilter: _getColorFilterMatrix(style.filter),
        child: imageWidget,
      );
    }

    return Container(
      decoration: style.hasShadow
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            )
          : null,
      child: imageWidget,
    );
  }

  ColorFilter _getColorFilterMatrix(PhotoFilter filter) {
    switch (filter) {
      case PhotoFilter.blackAndWhite:
        return const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.sepia:
        return const ColorFilter.matrix([
          0.393,
          0.769,
          0.189,
          0,
          0,
          0.349,
          0.686,
          0.168,
          0,
          0,
          0.272,
          0.534,
          0.131,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.vintage:
        return const ColorFilter.matrix([
          1.2,
          0,
          0,
          0,
          0,
          0,
          1.1,
          0,
          0,
          0,
          0,
          0,
          0.9,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.warm:
        return const ColorFilter.matrix([
          1.1,
          0,
          0,
          0,
          0,
          0,
          1.0,
          0,
          0,
          0,
          0,
          0,
          0.85,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.cool:
        return const ColorFilter.matrix([
          0.85,
          0,
          0,
          0,
          0,
          0,
          0.95,
          0,
          0,
          0,
          0,
          0,
          1.1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case PhotoFilter.none:
        return const ColorFilter.mode(Colors.transparent, BlendMode.multiply);
    }
  }

  Widget _buildExifTextRight(ExifData exif, FrameStyle style) {
    final textColor = _getTextColor(style);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${exif.focalLength}   f/${exif.fNumber}   ${exif.exposureTime}   ISO${exif.isoSpeedRatings}',
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          exif.dateTimeOriginal,
          style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 9),
        ),
      ],
    );
  }
}
