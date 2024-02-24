import 'dart:html';
import 'dart:typed_data';
import 'dart:html' as html;

void saveImage(Uint8List bytes, String filename) {
  // Convert bytes to a Blob

  final blob = html.Blob([bytes], 'image/png');

  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
