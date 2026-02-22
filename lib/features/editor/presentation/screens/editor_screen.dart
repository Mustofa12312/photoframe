import 'dart:ui';
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
      backgroundColor: Colors.black, // Sleek dark canvas
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit. Share.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.2,
          ),
        ),
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
            Container(
              margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
              child: ElevatedButton.icon(
                onPressed: _exportImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Canvas Area - Pan & Zoom enabled
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: WatermarkCanvas(
                    screenshotController: _screenshotController,
                  ),
                ),
              ),
            ),
          ),

          // Floating Bottom Tools
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 24, right: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white12, width: 1.5),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildToolIcon(
                              Icons.layers_outlined,
                              'Brand',
                              () => _showDevicePicker(context),
                            ),
                            _buildToolIcon(
                              Icons.format_color_fill,
                              'Color',
                              () => _showColorPicker(context),
                            ),
                            _buildToolIcon(
                              Icons.camera_enhance_outlined,
                              'Filter',
                              () => _showFilterPicker(context),
                            ),
                            _buildToolIcon(
                              Icons.dashboard_customize_outlined,
                              'Style',
                              () => _showTemplatePicker(context),
                            ),
                            const SizedBox(width: 8),
                            _buildToolIcon(
                              Icons.tune,
                              'Data',
                              () => _showDataEditor(context),
                            ),
                            const SizedBox(width: 8),
                            _buildToolIcon(
                              Icons.crop_free,
                              'Size',
                              () => _showSizeSlider(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onTap != null ? Colors.white : Colors.white24,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: onTap != null ? Colors.white : Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
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

  void _showFilterPicker(BuildContext context) {
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
                'Photo Filters',
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
                  itemCount: PhotoFilter.values.length,
                  itemBuilder: (context, index) {
                    final filter = PhotoFilter.values[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.blur_linear,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text(
                        filter.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        final currentStyle = context
                            .read<EditorProvider>()
                            .currentStyle;
                        context.read<EditorProvider>().updateStyle(
                          currentStyle.copyWith(filter: filter),
                        );
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

  void _showSizeSlider(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Consumer<EditorProvider>(
          builder: (context, provider, child) {
            final paddingRatio = provider.currentStyle.paddingRatio;
            return Container(
              color: AppTheme.surfaceColor,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Adjust Frame Size',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.zoom_out_map, color: Colors.white54),
                      Expanded(
                        child: Slider(
                          value: paddingRatio,
                          min: 0.0,
                          max: 0.25,
                          activeColor: AppTheme.primaryColor,
                          inactiveColor: Colors.white24,
                          onChanged: (val) {
                            provider.updateStyle(
                              provider.currentStyle.copyWith(paddingRatio: val),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDataEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _DataEditorSheet();
      },
    );
  }
}

class _DataEditorSheet extends StatefulWidget {
  @override
  _DataEditorSheetState createState() => _DataEditorSheetState();
}

class _DataEditorSheetState extends State<_DataEditorSheet> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<EditorProvider>();
    _textController = TextEditingController(
      text: provider.currentStyle.customText ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets.bottom;
    return Consumer<EditorProvider>(
      builder: (context, provider, child) {
        final style = provider.currentStyle;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            color: AppTheme.surfaceColor,
            padding: EdgeInsets.fromLTRB(20, 20, 20, padding + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Data & Toggles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Custom Signature/Brand Text',
                      labelStyle: const TextStyle(color: Colors.white54),
                      hintText: 'e.g., Shot on Potato',
                      hintStyle: const TextStyle(color: Colors.white24),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: () {
                          provider.updateStyle(
                            style.copyWith(customText: _textController.text),
                          );
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    onSubmitted: (val) {
                      provider.updateStyle(style.copyWith(customText: val));
                    },
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text(
                      'Show Technical Specs (ISO, Shutter)',
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: AppTheme.primaryColor,
                    value: style.showExposure,
                    onChanged: (val) =>
                        provider.updateStyle(style.copyWith(showExposure: val)),
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Show Lens Focal Length',
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: AppTheme.primaryColor,
                    value: style.showLens,
                    onChanged: (val) =>
                        provider.updateStyle(style.copyWith(showLens: val)),
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Show Date/Time',
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: AppTheme.primaryColor,
                    value: style.showDate,
                    onChanged: (val) =>
                        provider.updateStyle(style.copyWith(showDate: val)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
