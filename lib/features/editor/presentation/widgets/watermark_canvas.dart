import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/editor_provider.dart';
import '../../../../core/models/frame_template.dart';
import '../../../../core/utils/exif_util.dart';

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

    return Screenshot(
      controller: screenshotController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine realistic width constraints instead of depending blindly on the total screen size
          final double baseWidth =
              constraints.maxWidth > 0 && constraints.maxWidth < double.infinity
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;

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

          return Container(
            color: style.backgroundColor,
            padding: EdgeInsets.all(baseWidth * style.paddingRatio),
            child: layoutWidget,
          );
        },
      ),
    );
  }

  // ==========================================
  // TEMPLATE 1: CLASSIC DEVICE (Professional Leica/Flagship Style)
  // ==========================================
  Widget _buildClassicLayout(
    FrameStyle style,
    DeviceBrand brand,
    ExifData? exif,
    String imagePath,
  ) {
    final textColor = _getTextColor(style);
    final secondaryColor = textColor.withOpacity(0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageWithShadow(style, imagePath),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. BRAND LOGO
                _buildBrandLogo(brand, textColor, style),

                // 2. VERTICAL DIVIDER
                if (exif != null)
                  Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: textColor.withOpacity(0.3),
                  ),

                // 3. EXIF DETAILS (Shot On + Specs)
                if (exif != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Shot on ',
                                style: GoogleFonts.inter(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: exif.cameraModel.isNotEmpty
                                    ? exif.cameraModel
                                    : brand.displayName,
                                style: GoogleFonts.inter(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildExifString(exif, style),
                          style: GoogleFonts.inter(
                            color: secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                // 4. DATE AND TIME (Right Aligned)
                if (exif != null &&
                    style.showDate &&
                    exif.dateTimeOriginal.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        exif.dateTimeOriginal.split(' ').first,
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (exif.dateTimeOriginal.split(' ').length > 1)
                        Text(
                          exif.dateTimeOriginal.split(' ')[1],
                          style: GoogleFonts.inter(
                            color: secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _buildExifString(ExifData exif, FrameStyle style) {
    List<String> parts = [];
    if (style.showLens && exif.focalLength.isNotEmpty) {
      parts.add(exif.focalLength);
    }
    if (style.showExposure) {
      if (exif.fNumber.isNotEmpty) parts.add('f/${exif.fNumber}');
      if (exif.exposureTime.isNotEmpty) parts.add(exif.exposureTime);
      if (exif.isoSpeedRatings.isNotEmpty)
        parts.add('ISO ${exif.isoSpeedRatings}');
    }
    return parts.join('   ');
  }

  // ==========================================
  // TEMPLATE 2: POLAROID (Vintage Paper Frame)
  // ==========================================
  Widget _buildPolaroidLayout(
    FrameStyle style,
    DeviceBrand brand,
    ExifData? exif,
    String imagePath,
  ) {
    final bool isDark = style.backgroundColor.computeLuminance() < 0.5;

    return Container(
      // Subtle paper texture equivalent via shadow and borders
      decoration: BoxDecoration(
        color: style.backgroundColor,
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(2, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Inner frame around the image to make it look like actual printed photo
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.black54 : Colors.black12,
                width: 1,
              ),
            ),
            child: _buildImageWithShadow(style, imagePath, applyShadow: false),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              exif?.dateTimeOriginal.split(' ').first ?? 'MY MEMORY',
              style: GoogleFonts.caveat(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TEMPLATE 3: MINIMALIST (Clean & Centered)
  // ==========================================
  Widget _buildMinimalistLayout(
    FrameStyle style,
    DeviceBrand brand,
    ExifData? exif,
    String imagePath,
  ) {
    final textColor = _getTextColor(style);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageWithShadow(style, imagePath),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              _buildBrandLogo(brand, textColor, style, isMinimalist: true),
              const SizedBox(height: 8),
              if (exif != null)
                Text(
                  _buildExifString(exif, style),
                  style: GoogleFonts.spaceGrotesk(
                    color: textColor.withOpacity(0.6),
                    fontSize: 11,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w500,
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

  Widget _buildBrandLogo(
    DeviceBrand brand,
    Color color,
    FrameStyle style, {
    bool isMinimalist = false,
  }) {
    if (style.customText != null && style.customText!.isNotEmpty) {
      return Text(
        style.customText!,
        style: GoogleFonts.montserrat(
          color: color,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          fontSize: isMinimalist ? 18 : 22,
          letterSpacing: 1.5,
        ),
      );
    }

    if (brand.svgIconUrl != null) {
      return SizedBox(
        height: isMinimalist ? 20 : 28,
        width: 48,
        child: SvgPicture.network(
          brand.svgIconUrl!,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
      );
    }
    return Text(
      brand.displayName,
      style: GoogleFonts.montserrat(
        color: color,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        fontSize: isMinimalist ? 18 : 22,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildImageWithShadow(
    FrameStyle style,
    String imagePath, {
    bool applyShadow = true,
  }) {
    Widget imageWidget = Image.file(File(imagePath), fit: BoxFit.contain);

    // Apply Photo Filters
    if (style.filter != PhotoFilter.none) {
      imageWidget = ColorFiltered(
        colorFilter: _getColorFilterMatrix(style.filter),
        child: imageWidget,
      );
    }

    return Container(
      decoration: (style.hasShadow && applyShadow)
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 15),
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

  // Exif text building is now handled inside _buildClassicLayout directly
}
