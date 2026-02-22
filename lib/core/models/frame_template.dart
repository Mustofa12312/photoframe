import 'package:flutter/material.dart';

enum DeviceBrand { sony, fujifilm, apple, leica, canon, nikon, unknown }

extension DeviceBrandExt on DeviceBrand {
  String get displayName {
    switch (this) {
      case DeviceBrand.sony:
        return 'SONY';
      case DeviceBrand.fujifilm:
        return 'FUJIFILM';
      case DeviceBrand.apple:
        return 'Apple';
      case DeviceBrand.leica:
        return 'Leica';
      case DeviceBrand.canon:
        return 'Canon';
      case DeviceBrand.nikon:
        return 'Nikon';
      case DeviceBrand.unknown:
        return 'Unknown Device';
    }
  }

  // Helper to parse from EXIF make
  static DeviceBrand fromMake(String make) {
    final lower = make.toLowerCase();
    if (lower.contains('sony')) return DeviceBrand.sony;
    if (lower.contains('fuji')) return DeviceBrand.fujifilm;
    if (lower.contains('apple')) return DeviceBrand.apple;
    if (lower.contains('leica')) return DeviceBrand.leica;
    if (lower.contains('canon')) return DeviceBrand.canon;
    if (lower.contains('nikon')) return DeviceBrand.nikon;
    return DeviceBrand.unknown;
  }
}

enum FrameLayout { deviceClassic, polaroid, minimalist }

class FrameStyle {
  final FrameLayout layout;
  final Color backgroundColor;
  final double paddingRatio; // padding as a ratio of image width e.g., 0.05
  final double bottomBarHeightRatio; // space for exif info
  final bool hasShadow;
  final DeviceBrand brandOverride;

  const FrameStyle({
    this.layout = FrameLayout.deviceClassic,
    this.backgroundColor = Colors.white,
    this.paddingRatio = 0.05,
    this.bottomBarHeightRatio = 0.15,
    this.hasShadow = true,
    this.brandOverride = DeviceBrand.unknown,
  });

  FrameStyle copyWith({
    FrameLayout? layout,
    Color? backgroundColor,
    double? paddingRatio,
    double? bottomBarHeightRatio,
    bool? hasShadow,
    DeviceBrand? brandOverride,
  }) {
    return FrameStyle(
      layout: layout ?? this.layout,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      paddingRatio: paddingRatio ?? this.paddingRatio,
      bottomBarHeightRatio: bottomBarHeightRatio ?? this.bottomBarHeightRatio,
      hasShadow: hasShadow ?? this.hasShadow,
      brandOverride: brandOverride ?? this.brandOverride,
    );
  }
}

// Koleksi Template Siap Pakai
class TemplatePresets {
  static const List<FrameStyle> allTemplates = [
    FrameStyle(
      layout: FrameLayout.deviceClassic,
      backgroundColor: Colors.white,
      hasShadow: true,
    ),
    FrameStyle(
      layout: FrameLayout.polaroid,
      backgroundColor: Color(0xFFF9F6EE), // Warna kertas vintage
      paddingRatio: 0.08,
      hasShadow: true,
    ),
    FrameStyle(
      layout: FrameLayout.minimalist,
      backgroundColor: Colors.black,
      paddingRatio: 0.1,
      hasShadow: false,
    ),
  ];
}
