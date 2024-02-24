import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'save_image.dart';
import 'dart:html' as html;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRCodeGenerator(),
    );
  }
}

Future<bool> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    final result = await Permission.storage.request();
    return result.isGranted;
  }
  return true;
}

class QRCodeGenerator extends StatefulWidget {
  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  String qrData = "welcome to LCR!"; // Default QR data
  GlobalKey qrKey = GlobalKey();

  Future<void> saveQrImage() async {
    if (!kIsWeb) {
      // Request storage permission only on mobile
      if (!(await requestStoragePermission())) {
        // Handle permission denial
        return;
      }
    }
    RenderRepaintBoundary boundary =
        qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    try {
      ImageSaver.saveImage(pngBytes, 'my_image.png');
      // Inform the user that the download has started

//todo need to remove this temp part. this is added because the interface is not working
      final blob = html.Blob([pngBytes], 'image/png');

      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "test.png")
        ..click();
      html.Url.revokeObjectUrl(url);

      // todo remove upto this point

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Downloading QR Code... Check your downloads folder.')),
      );
    } catch (e) {
      // Handle or log error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download QR Code.')),
      );
    }
    // // Save the file
    // final directory = (await getApplicationDocumentsDirectory())
    //     .path; // or getExternalStorageDirectory
    // File imgFile = File('$directory/qr_code.png');
    // await imgFile.writeAsBytes(pngBytes);

    // Optionally, notify user about the location of saved file or handle it further
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RepaintBoundary(
                key: qrKey,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Call the save function when the button is pressed
                  saveQrImage().then((_) {
                    // Handle post-save actions here, like showing a confirmation dialog or snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('QR Code saved successfully')),
                    );
                  }).catchError((error) {
                    // log(error);
                    // Handle errors, such as permission denied or failed to save
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save QR Code')),
                    );
                  });
                },
                child: Text('Save QR Code'),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      qrData = value
                          .trim(); // Update qrData with trimmed value to remove leading/trailing whitespace
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Enter data",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
