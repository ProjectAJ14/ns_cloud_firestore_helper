import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path_provider/path_provider.dart';

/// This class is used to compress images.
class ImageService {
  /// This method is used to compress an image.
  static Future<File> getCompressedImage(
    File file, {
    int quality = 85,
    bool withIsolates = true,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    File compressedFile;

    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = math.Random().nextInt(10000);
    final compressedImagePath = '$path/image_$rand';

    if (withIsolates) {
      ReceivePort receivePort = ReceivePort();
      IsolateMessage message = IsolateMessage(
        path: file.path,
        quality: quality,
        compressedImagePath: compressedImagePath,
        sendPort: receivePort.sendPort,
      );
      final isolate =
          await Isolate.spawn<IsolateMessage>(performIsolateTask, message);
      final result = await receivePort.first;
      isolate.kill(priority: Isolate.immediate);

      compressedFile = File(result);
    } else {
      compressedFile = await compressImage(
        file.path,
        quality: quality,
        compressedImagePath: compressedImagePath,
      );
    }
    stopwatch.stop();
    debugPrint(
      'Compressed image[$quality] in ${stopwatch.elapsedMilliseconds}ms',
    );
    return compressedFile;
  }
}

/// Object to send to isolate.
class IsolateMessage {
  final String path;
  final int quality;
  final String compressedImagePath;
  final SendPort sendPort;

  IsolateMessage({
    required this.path,
    required this.quality,
    required this.compressedImagePath,
    required this.sendPort,
  });
}

/// This function is to compress image
Future<File> compressImage(
  String path, {
  required String compressedImagePath,
  int quality = 85,
}) async {
  image_lib.Image? image = image_lib.decodeImage(File(path).readAsBytesSync());
  image_lib.Image smallerImage = image_lib.copyResize(
    image!,
    width: image.width ~/ 2,
  ); // choose the size here, it will maintain aspect ratio

  var compressedImage = File('$compressedImagePath.jpg')
    ..writeAsBytesSync(image_lib.encodeJpg(
      smallerImage,
      quality: quality,
    ));
  return compressedImage;
}

/// This function is to compress image in isolate
void performIsolateTask(IsolateMessage message) async {
  var file = await compressImage(
    message.path,
    quality: message.quality,
    compressedImagePath: message.compressedImagePath,
  );
  message.sendPort.send(file.path);
}
