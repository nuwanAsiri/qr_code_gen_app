import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> saveImage(Uint8List bytes, String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes);
  print('Image saved to ${file.path}');
}
