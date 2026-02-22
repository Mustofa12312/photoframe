import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/editor_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(const PhotoFrameApp());
}

class PhotoFrameApp extends StatelessWidget {
  const PhotoFrameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => EditorProvider())],
      child: MaterialApp(
        title: 'Photo Frame & Watermark',
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
