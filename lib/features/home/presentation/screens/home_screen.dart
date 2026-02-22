import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/image_picker_util.dart';
import '../../../../core/utils/exif_util.dart';
import '../../../../core/models/frame_template.dart';
import '../../../editor/presentation/screens/editor_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/editor_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  final List<String> _tabs = [
    'Album',
    'WaterMark',
    'Camera',
    'Theme',
    'Polaroid',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndNavigate(
    BuildContext context,
    bool fromCamera, {
    FrameStyle? preset,
  }) async {
    final xFile = fromCamera
        ? await ImagePickerUtil.pickFromCamera()
        : await ImagePickerUtil.pickFromGallery();

    if (xFile != null) {
      // Extract EXIF
      final exif = await ExifUtil.extractExif(xFile.path);

      if (!context.mounted) return;

      // Update Provider
      context.read<EditorProvider>().setImage(xFile, exif);

      if (preset != null) {
        context.read<EditorProvider>().updateStyle(preset);
      }

      // Navigate to Editor
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditorScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text(
                'Photo Frame',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppTheme.primaryColor,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white70,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppTheme.primaryColor,
                ),
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: -16,
                  vertical: 8,
                ),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            )
          : null,
      body: _currentIndex == 0
          ? TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildGalleryTab(tab)).toList(),
            )
          : const ProfileScreen(), // Assuming index 2 is Profile
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Camera FAB handles the middle action, but if tapped here:
            _pickAndNavigate(context, true);
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.crop_square),
            label: 'Frame',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, color: Colors.transparent),
            label: '',
          ), // Spacer for FAB
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'User',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndNavigate(
          context,
          false,
        ), // Or true for camera, depending on preference
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.camera_alt, color: Colors.black),
        elevation: 4,
      ),
    );
  }

  Widget _buildGalleryTab(String title) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Hot Frame ($title)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 4 / 3,
          ),
          itemCount: TemplatePresets.allTemplates.length,
          itemBuilder: (context, index) {
            return _buildTemplateCard(TemplatePresets.allTemplates[index]);
          },
        ),
      ],
    );
  }

  Widget _buildTemplateCard(FrameStyle preset) {
    return InkWell(
      onTap: () => _pickAndNavigate(context, false, preset: preset),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: preset.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 30,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                preset.layout.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
