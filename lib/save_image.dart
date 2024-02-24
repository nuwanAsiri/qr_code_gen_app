import 'dart:typed_data';

// This URI will be resolved dynamically based on the platform.
export 'save_image_stub.dart'
    if (dart.library.html) 'save_image_web.dart'
    if (dart.library.io) 'save_image_mobile.dart';

// Define a common interface. Actual implementation will be chosen at runtime.
abstract class ImageSaver {
  static void saveImage(Uint8List bytes, String filename) {}
}
