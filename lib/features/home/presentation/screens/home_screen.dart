import 'dart:ui';
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
      backgroundColor: AppTheme.backgroundColor,
      body: _currentIndex == 0
          ? CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: true,
                  pinned: true,
                  backgroundColor: AppTheme.surfaceColor.withOpacity(0.9),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 60),
                    title: const Text(
                      'Photo Frame',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.surfaceColor,
                            AppTheme.backgroundColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 1,
                          ),
                        ),
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: Colors.white54,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: _tabs
                            .map(
                              (t) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Tab(text: t),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs
                        .map((tab) => _buildGalleryTab(tab))
                        .toList(),
                  ),
                ),
              ],
            )
          : const ProfileScreen(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () => _pickAndNavigate(context, false),
          backgroundColor: AppTheme.primaryColor,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.add_a_photo, color: Colors.black, size: 28),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: AppTheme.surfaceColor.withOpacity(0.8),
            elevation: 0,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.white54,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (index) {
              if (index == 1) {
                _pickAndNavigate(context, true);
              } else {
                setState(() => _currentIndex = index);
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.view_carousel_rounded, size: 28),
                label: 'Gallery',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera, color: Colors.transparent),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded, size: 28),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryTab(String title) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Templates',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.75, // Make them tall, elegant portrait cards
          ),
          itemCount: TemplatePresets.allTemplates.length,
          itemBuilder: (context, index) {
            return _buildTemplateCard(
              TemplatePresets.allTemplates[index],
              index,
            );
          },
        ),
        const SizedBox(height: 100), // padding for floating action button
      ],
    );
  }

  Widget _buildTemplateCard(FrameStyle preset, int index) {
    return InkWell(
      onTap: () => _pickAndNavigate(context, false, preset: preset),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: preset.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Mock Photo inside the frame
            Positioned(
              top: preset.layout == FrameLayout.polaroid ? 16 : 30,
              left: 16,
              right: 16,
              bottom: preset.layout == FrameLayout.polaroid ? 60 : 40,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: preset.hasShadow
                      ? [BoxShadow(color: Colors.black12, blurRadius: 10)]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white24,
                    size: 32,
                  ),
                ),
              ),
            ),
            // Template Info Strip
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border(
                        top: BorderSide(color: Colors.white12, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.layout.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Style ${index + 1}',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
