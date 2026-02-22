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
      child: Image.file(File(imagePath), fit: BoxFit.contain),
    );
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
