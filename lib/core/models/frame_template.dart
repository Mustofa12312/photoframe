import 'package:flutter/material.dart';

enum DeviceBrand {
  // Mobile / Phone Brands
  apple,
  samsung,
  google,
  xiaomi,
  oppo,
  vivo,
  oneplus,
  realme,
  asus,
  sonyPhone,
  motorola,
  huawei,

  // Camera & Lens Brands
  sony,
  canon,
  nikon,
  fujifilm,
  leica,
  panasonic,
  lumix,
  olympus,
  hasselblad,
  pentax,
  ricoh,
  sigma,
  tamron,

  unknown,
}

extension DeviceBrandExtension on DeviceBrand {
  String get displayName {
    switch (this) {
      // Mobile
      case DeviceBrand.apple:
        return 'SHOT ON IPHONE';
      case DeviceBrand.samsung:
        return 'SAMSUNG GALAXY';
      case DeviceBrand.google:
        return 'GOOGLE PIXEL';
      case DeviceBrand.xiaomi:
        return 'XIAOMI';
      case DeviceBrand.oppo:
        return 'OPPO';
      case DeviceBrand.vivo:
        return 'VIVO';
      case DeviceBrand.oneplus:
        return 'ONEPLUS';
      case DeviceBrand.realme:
        return 'REALME';
      case DeviceBrand.asus:
        return 'ASUS ROG / ZENFONE';
      case DeviceBrand.sonyPhone:
        return 'SONY XPERIA';
      case DeviceBrand.motorola:
        return 'MOTOROLA';
      case DeviceBrand.huawei:
        return 'HUAWEI XIMAGE';

      // Cameras
      case DeviceBrand.sony:
        return 'SONY ALPHA';
      case DeviceBrand.canon:
        return 'CANON EOS';
      case DeviceBrand.nikon:
        return 'NIKON';
      case DeviceBrand.fujifilm:
        return 'FUJIFILM';
      case DeviceBrand.leica:
        return 'LEICA';
      case DeviceBrand.panasonic:
        return 'PANASONIC';
      case DeviceBrand.lumix:
        return 'LUMIX';
      case DeviceBrand.olympus:
        return 'OLYMPUS';
      case DeviceBrand.hasselblad:
        return 'HASSELBLAD';
      case DeviceBrand.pentax:
        return 'PENTAX';
      case DeviceBrand.ricoh:
        return 'RICOH GR';
      case DeviceBrand.sigma:
        return 'SIGMA';
      case DeviceBrand.tamron:
        return 'TAMRON LENS';

      case DeviceBrand.unknown:
        return 'UNKNOWN DEVICE';
    }
  }

  String? get svgIconUrl {
    switch (this) {
      case DeviceBrand.apple:
        return 'https://cdn.simpleicons.org/apple';
      case DeviceBrand.samsung:
        return 'https://cdn.simpleicons.org/samsung';
      case DeviceBrand.google:
        return 'https://cdn.simpleicons.org/google';
      case DeviceBrand.xiaomi:
        return 'https://cdn.simpleicons.org/xiaomi';
      case DeviceBrand.oppo:
        return 'https://cdn.simpleicons.org/oppo';
      case DeviceBrand.vivo:
        return 'https://cdn.simpleicons.org/vivo';
      case DeviceBrand.oneplus:
        return 'https://cdn.simpleicons.org/oneplus';
      case DeviceBrand.asus:
        return 'https://cdn.simpleicons.org/asus';
      case DeviceBrand.sonyPhone:
      case DeviceBrand.sony:
        return 'https://cdn.simpleicons.org/sony';
      case DeviceBrand.motorola:
        return 'https://cdn.simpleicons.org/motorola';
      case DeviceBrand.huawei:
        return 'https://cdn.simpleicons.org/huawei';
      case DeviceBrand.canon:
        return 'https://cdn.simpleicons.org/canon';
      case DeviceBrand.nikon:
        return 'https://cdn.simpleicons.org/nikon';
      case DeviceBrand.fujifilm:
        return 'https://cdn.simpleicons.org/fujifilm';
      case DeviceBrand.panasonic:
      case DeviceBrand.lumix:
        return 'https://cdn.simpleicons.org/panasonic';
      default:
        return null;
    }
  }

  // Helper to parse from EXIF make
  static DeviceBrand fromMake(String make) {
    final lower = make.toLowerCase();

    // Phones
    if (lower.contains('apple') || lower.contains('iphone')) {
      return DeviceBrand.apple;
    }
    if (lower.contains('samsung')) {
      return DeviceBrand.samsung;
    }
    if (lower.contains('google') || lower.contains('pixel')) {
      return DeviceBrand.google;
    }
    if (lower.contains('xiaomi') ||
        lower.contains('redmi') ||
        lower.contains('poco')) {
      return DeviceBrand.xiaomi;
    }
    if (lower.contains('oppo')) {
      return DeviceBrand.oppo;
    }
    if (lower.contains('vivo')) {
      return DeviceBrand.vivo;
    }
    if (lower.contains('oneplus')) {
      return DeviceBrand.oneplus;
    }
    if (lower.contains('realme')) {
      return DeviceBrand.realme;
    }
    if (lower.contains('asus')) {
      return DeviceBrand.asus;
    }
    if (lower.contains('motorola') || lower.contains('moto')) {
      return DeviceBrand.motorola;
    }
    if (lower.contains('huawei')) {
      return DeviceBrand.huawei;
    }

    // Cameras
    if (lower.contains('sony')) {
      return DeviceBrand.sony;
    }
    if (lower.contains('canon')) {
      return DeviceBrand.canon;
    }
    if (lower.contains('nikon')) {
      return DeviceBrand.nikon;
    }
    if (lower.contains('fuji')) {
      return DeviceBrand.fujifilm;
    }
    if (lower.contains('leica')) {
      return DeviceBrand.leica;
    }
    if (lower.contains('panasonic') || lower.contains('lumix')) {
      return DeviceBrand.panasonic;
    }
    if (lower.contains('olympus')) {
      return DeviceBrand.olympus;
    }
    if (lower.contains('hasselblad')) {
      return DeviceBrand.hasselblad;
    }
    if (lower.contains('pentax')) {
      return DeviceBrand.pentax;
    }
    if (lower.contains('ricoh')) {
      return DeviceBrand.ricoh;
    }
    if (lower.contains('sigma')) {
      return DeviceBrand.sigma;
    }
    if (lower.contains('tamron')) {
      return DeviceBrand.tamron;
    }

    return DeviceBrand.unknown;
  }
}

enum FrameLayout { deviceClassic, polaroid, minimalist }

enum PhotoFilter { none, sepia, blackAndWhite, vintage, cool, warm }

class FrameStyle {
  final FrameLayout layout;
  final Color backgroundColor;
  final double paddingRatio;
  final double bottomBarHeightRatio;
  final bool hasShadow;
  final DeviceBrand brandOverride;
  final PhotoFilter filter;

  // Advanced toggles
  final bool showDate;
  final bool showExposure;
  final bool showLens;
  final String? customText;

  const FrameStyle({
    this.layout = FrameLayout.deviceClassic,
    this.backgroundColor = Colors.white,
    this.paddingRatio = 0.05,
    this.bottomBarHeightRatio = 0.15,
    this.hasShadow = true,
    this.brandOverride = DeviceBrand.unknown,
    this.filter = PhotoFilter.none,
    this.showDate = true,
    this.showExposure = true,
    this.showLens = true,
    this.customText,
  });

  FrameStyle copyWith({
    FrameLayout? layout,
    Color? backgroundColor,
    double? paddingRatio,
    double? bottomBarHeightRatio,
    bool? hasShadow,
    DeviceBrand? brandOverride,
    PhotoFilter? filter,
    bool? showDate,
    bool? showExposure,
    bool? showLens,
    String? customText,
  }) {
    return FrameStyle(
      layout: layout ?? this.layout,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      paddingRatio: paddingRatio ?? this.paddingRatio,
      bottomBarHeightRatio: bottomBarHeightRatio ?? this.bottomBarHeightRatio,
      hasShadow: hasShadow ?? this.hasShadow,
      brandOverride: brandOverride ?? this.brandOverride,
      filter: filter ?? this.filter,
      showDate: showDate ?? this.showDate,
      showExposure: showExposure ?? this.showExposure,
      showLens: showLens ?? this.showLens,
      customText: customText ?? this.customText,
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
