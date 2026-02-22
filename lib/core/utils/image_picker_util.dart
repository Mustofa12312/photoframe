import 'package:image_picker/image_picker.dart';

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery
  static Future<XFile?> pickFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      // Handle or log error
      return null;
    }
  }

  /// Captures an image with the camera
  static Future<XFile?> pickFromCamera() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      // Handle or log error
      return null;
    }
  }
}
