import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../core/providers/editor_provider.dart';
import '../../../../core/models/frame_template.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/watermark_canvas.dart';
import '../../../../core/utils/export_util.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;

  Future<void> _exportImage() async {
    setState(() => _isExporting = true);

    final success = await ExportUtil.saveToGallery(_screenshotController);

    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Saved to Gallery!' : 'Failed to save image.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        centerTitle: true,
        actions: [
          if (_isExporting)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportImage,
            ),
        ],
      ),
      body: Column(
        children: [
          // Canvas Area
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WatermarkCanvas(
                    screenshotController: _screenshotController,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Tools
          Container(
            height: 80,
            color: AppTheme.surfaceColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolIcon(
                  Icons.layers,
                  'device',
                  () => _showDevicePicker(context),
                ),
                _buildToolIcon(
                  Icons.color_lens,
                  'color',
                  () => _showColorPicker(context),
                ),
                _buildToolIcon(
                  Icons.font_download,
                  'font',
                  null,
                ), // Placeholder
                _buildToolIcon(
                  Icons.dashboard,
                  'style',
                  () => _showTemplatePicker(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: onTap != null ? Colors.white : Colors.white30),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: onTap != null ? Colors.white : Colors.white30,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showDevicePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          color: AppTheme.surfaceColor,
          child: ListView(
            shrinkWrap: true,
            children: DeviceBrand.values.map((brand) {
              return ListTile(
                title: Text(
                  brand.displayName,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  context.read<EditorProvider>().updateBrand(brand);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showColorPicker(BuildContext context) {
    final colors = [
      Colors.white,
      Colors.black,
      Colors.red.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      AppTheme.primaryColor,
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          color: AppTheme.surfaceColor,
          height: 120,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: colors.map((c) {
                  return GestureDetector(
                    onTap: () {
                      context.read<EditorProvider>().updateBackgroundColor(c);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTemplatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          color: AppTheme.surfaceColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Style',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: TemplatePresets.allTemplates.length,
                  itemBuilder: (context, index) {
                    final preset = TemplatePresets.allTemplates[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.style,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text(
                        preset.layout.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        context.read<EditorProvider>().updateStyle(preset);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
