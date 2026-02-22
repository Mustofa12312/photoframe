import 'package:flutter/material.dart';

enum LayerType { text, image, qr, exifInfo }

class CanvasLayer {
  final String id;
  LayerType type;
  Offset position;
  double scale;
  double rotation;
  Color color;
  String text;
  String fontFamily;
  String? imageUrl;

  CanvasLayer({
    required this.id,
    this.type = LayerType.text,
    this.position = const Offset(50, 50),
    this.scale = 1.0,
    this.rotation = 0.0,
    this.color = Colors.white,
    this.text = '',
    this.fontFamily = 'Inter',
    this.imageUrl,
  });

  CanvasLayer copyWith({
    Offset? position,
    double? scale,
    double? rotation,
    Color? color,
    String? text,
    String? fontFamily,
    String? imageUrl,
  }) {
    return CanvasLayer(
      id: id,
      type: type,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      color: color ?? this.color,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
