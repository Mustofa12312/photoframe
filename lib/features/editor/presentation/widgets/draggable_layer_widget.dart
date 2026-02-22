import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/canvas_layer.dart';
import '../../../../core/providers/editor_provider.dart';

class DraggableLayerWidget extends StatefulWidget {
  final CanvasLayer layer;

  const DraggableLayerWidget({Key? key, required this.layer}) : super(key: key);

  @override
  State<DraggableLayerWidget> createState() => _DraggableLayerWidgetState();
}

class _DraggableLayerWidgetState extends State<DraggableLayerWidget> {
  double _initialScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final isSelected = provider.selectedLayerId == widget.layer.id;

    return Positioned(
      left: widget.layer.position.dx,
      top: widget.layer.position.dy,
      child: GestureDetector(
        onTap: () {
          provider.selectLayer(widget.layer.id);
        },
        onScaleStart: (details) {
          if (isSelected) {
            _initialScale = widget.layer.scale;
          }
        },
        onScaleUpdate: (details) {
          if (isSelected) {
            // Calculate new position based on drag delta
            // Using focalPointDelta for smooth dragging along with zooming
            final newPos = widget.layer.position + details.focalPointDelta;

            // Calculate new scale
            final newScale = (_initialScale * details.scale).clamp(0.2, 5.0);

            provider.updateLayer(
              widget.layer.id,
              widget.layer.copyWith(position: newPos, scale: newScale),
            );
          }
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      color: Colors.blue.withOpacity(0.1),
                    )
                  : const BoxDecoration(
                      border: Border.fromBorderSide(BorderSide.none),
                    ),
              child: Transform.scale(
                scale: widget.layer.scale,
                child: Transform.rotate(
                  angle: widget.layer.rotation,
                  child: _buildContent(widget.layer),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: -12,
                right: -12,
                child: GestureDetector(
                  onTap: () => provider.removeLayer(widget.layer.id),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CanvasLayer layer) {
    switch (layer.type) {
      case LayerType.text:
      case LayerType.exifInfo:
        return Text(
          layer.text,
          style: GoogleFonts.getFont(
            layer.fontFamily,
            color: layer.color,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        );
      case LayerType.image:
        if (layer.imageUrl != null) {
          // Simplification: treating network or assets equally using simple icon for now
          // If you decide to add actual custom images later, this is where you load them.
          return const Icon(Icons.image, size: 64, color: Colors.white);
        }
        return const SizedBox();
      case LayerType.qr:
        return const Icon(Icons.qr_code_2, size: 64, color: Colors.black);
    }
  }
}
