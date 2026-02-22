import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../core/providers/editor_provider.dart';
import '../../../../core/models/frame_template.dart';
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

    // Use a layout builder to maintain aspect ratio based on available space
    // For saving, screenshot controller captures this widget tree
    return Screenshot(
      controller: screenshotController,
      child: Container(
        color: style.backgroundColor,
        padding: EdgeInsets.all(
          20,
        ), // Standard padding for preview, can be responsive later
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The Image with optional shadow
            Container(
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
              child: Image.file(
                File(provider.selectedImage!.path),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            // The EXIF Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Brand Text (Replace with SVG later if desired)
                Text(
                  brand.displayName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    fontSize: 24,
                    letterSpacing: 2.0,
                  ),
                ),
                // Exif info
                if (exif != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${exif.focalLength}   f/${exif.fNumber}   ${exif.exposureTime}   ISO${exif.isoSpeedRatings}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exif.dateTimeOriginal,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
