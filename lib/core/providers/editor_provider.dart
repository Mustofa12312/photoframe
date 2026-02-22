import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:io';
import '../utils/exif_util.dart';
import '../models/frame_template.dart';
import '../models/canvas_layer.dart';

class EditorProvider extends ChangeNotifier {
  XFile? _selectedImage;
  ExifData? _exifData;
  FrameStyle _currentStyle = const FrameStyle();
  DeviceBrand _activeBrand = DeviceBrand.unknown;

  // Custom Canva Mode Layers
  List<CanvasLayer> _layers = [];
  String? _selectedLayerId;

  XFile? get selectedImage => _selectedImage;
  ExifData? get exifData => _exifData;
  FrameStyle get currentStyle => _currentStyle;
  DeviceBrand get activeBrand => _activeBrand;
  List<CanvasLayer> get layers => _layers;
  String? get selectedLayerId => _selectedLayerId;

  bool get hasImage => _selectedImage != null;

  void setImage(XFile image, ExifData? exif) async {
    _selectedImage = image;
    _exifData = exif;

    // Auto-detect brand from exif
    if (exif != null) {
      _activeBrand = DeviceBrandExtension.fromMake(exif.cameraMake);
    } else {
      _activeBrand = DeviceBrand.unknown;
    }

    notifyListeners();

    // Async color extraction
    try {
      final imageProvider = FileImage(File(image.path)) as ImageProvider;
      final palette = await PaletteGenerator.fromImageProvider(imageProvider);
      if (palette.dominantColor != null) {
        // Automatically set background color to a complimentary color or lightened dominant color
        // For premium feel, we just provide it as an option, but let's set it as default for 'Aesthetic' styles
        // Setting frame to dominant color slightly lightened
        var hsl = HSLColor.fromColor(palette.dominantColor!.color);
        _currentStyle = _currentStyle.copyWith(
          backgroundColor: hsl
              .withLightness((hsl.lightness + 0.4).clamp(0.0, 1.0))
              .toColor(),
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  void updateStyle(FrameStyle newStyle) {
    _currentStyle = newStyle;
    notifyListeners();
  }

  void updateBrand(DeviceBrand brand) {
    _activeBrand = brand;
    notifyListeners();
  }

  void updateBackgroundColor(Color color) {
    _currentStyle = _currentStyle.copyWith(backgroundColor: color);
    notifyListeners();
  }

  void clear() {
    _selectedImage = null;
    _exifData = null;
    _currentStyle = const FrameStyle();
    _activeBrand = DeviceBrand.unknown;
    _layers.clear();
    _selectedLayerId = null;
    notifyListeners();
  }

  // --- Layer Management (Canva Mode) ---
  void addLayer(CanvasLayer layer) {
    _layers.add(layer);
    _selectedLayerId = layer.id;
    notifyListeners();
  }

  void removeLayer(String id) {
    _layers.removeWhere((l) => l.id == id);
    if (_selectedLayerId == id) _selectedLayerId = null;
    notifyListeners();
  }

  void updateLayer(String id, CanvasLayer newLayer) {
    final index = _layers.indexWhere((l) => l.id == id);
    if (index != -1) {
      _layers[index] = newLayer;
      notifyListeners();
    }
  }

  void selectLayer(String? id) {
    _selectedLayerId = id;
    notifyListeners();
  }
}
