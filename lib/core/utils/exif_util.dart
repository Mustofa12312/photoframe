import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';

class ExifData {
  final String cameraMake;
  final String cameraModel;
  final String lensModel;
  final String focalLength;
  final String fNumber;
  final String exposureTime;
  final String isoSpeedRatings;
  final String dateTimeOriginal;

  ExifData({
    this.cameraMake = '',
    this.cameraModel = '',
    this.lensModel = '',
    this.focalLength = '',
    this.fNumber = '',
    this.exposureTime = '',
    this.isoSpeedRatings = '',
    this.dateTimeOriginal = '',
  });

  @override
  String toString() {
    return 'Make: $cameraMake, Model: $cameraModel, Lens: $lensModel, '
        'Focal: $focalLength, Aperture: f/$fNumber, Shutter: $exposureTime, '
        'ISO: $isoSpeedRatings, Date: $dateTimeOriginal';
  }
}

class ExifUtil {
  /// Extracts EXIF metadata from the given image path
  static Future<ExifData?> extractExif(String imagePath) async {
    try {
      final fileBytes = await File(imagePath).readAsBytes();
      final tags = await readExifFromBytes(fileBytes);

      if (tags.isEmpty) {
        return null;
      }

      if (kDebugMode) {
        tags.forEach((key, value) {
          // Uncomment to see all tags
          // print('$key: $value');
        });
      }

      String make = tags['Image Make']?.printable ?? 'Unknown Device';
      String model = tags['Image Model']?.printable ?? '';
      String lensModel = tags['EXIF LensModel']?.printable ?? '';

      // Aperture
      String fNumber = '';
      if (tags.containsKey('EXIF FNumber')) {
        String p = tags['EXIF FNumber']!.printable;
        List<String> parts = p.split('/');
        if (parts.length == 2) {
          double num = double.tryParse(parts[0]) ?? 0;
          double den = double.tryParse(parts[1]) ?? 1;
          if (den != 0) {
            fNumber = (num / den).toStringAsFixed(1);
          }
        } else {
          fNumber = p;
        }
      }

      // Shutter Speed (Exposure Time)
      String exposureTime = tags['EXIF ExposureTime']?.printable ?? '';

      // ISO
      String iso = tags['EXIF ISOSpeedRatings']?.printable ?? '';

      // Focal Length
      String focalLength = '';
      if (tags.containsKey('EXIF FocalLength')) {
        String p = tags['EXIF FocalLength']!.printable;
        List<String> parts = p.split('/');
        if (parts.length == 2) {
          double num = double.tryParse(parts[0]) ?? 0;
          double den = double.tryParse(parts[1]) ?? 1;
          if (den != 0) {
            focalLength = '${(num / den).round()}mm';
          }
        } else {
          focalLength = p.replaceAll(RegExp(r'[^0-9]'), '') + 'mm';
        }
      }

      // Date Time
      String dateTime = tags['EXIF DateTimeOriginal']?.printable ?? '';
      if (dateTime.isNotEmpty) {
        // usually format is "YYYY:MM:DD HH:MM:SS" -> convert to "YYYY.MM.DD HH:MM"
        try {
          var parts = dateTime.split(' ');
          var dateParts = parts[0].replaceAll(':', '.');
          var timeParts = parts[1].substring(0, 5); // HH:MM
          dateTime = '$dateParts $timeParts';
        } catch (e) {
          // keep original if parsing fails
        }
      }

      return ExifData(
        cameraMake: make.trim(),
        cameraModel: model.trim(),
        lensModel: lensModel.trim(),
        focalLength: focalLength,
        fNumber: fNumber,
        exposureTime: exposureTime + (exposureTime.isNotEmpty ? 's' : ''),
        isoSpeedRatings: iso,
        dateTimeOriginal: dateTime,
      );
    } catch (e) {
      debugPrint('Error reading EXIF: $e');
      return null;
    }
  }
}
