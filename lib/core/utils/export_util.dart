import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ExportUtil {
  static Future<bool> saveToGallery(ScreenshotController controller) async {
    try {
      // Capture the widget as Uint8List at higher resolution
      final Uint8List? imageBytes = await controller.capture(pixelRatio: 3.0);

      if (imageBytes != null) {
        final fileName = "PhotoFrame_${DateTime.now().millisecondsSinceEpoch}";

        if (!kIsWeb &&
            (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
          // Desktop Fallback: Save to Downloads
          final directory = await getDownloadsDirectory();
          if (directory != null) {
            final filePath = '${directory.path}/$fileName.png';
            final file = File(filePath);
            await file.writeAsBytes(imageBytes);
            debugPrint('Saved to Desktop Downloads: $filePath');
            return true;
          }
          return false;
        }

        // Mobile Strategy
        final result = await ImageGallerySaver.saveImage(
          imageBytes,
          quality: 100,
          name: fileName,
        );
        debugPrint('Save result: $result');
        return result['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }
}
