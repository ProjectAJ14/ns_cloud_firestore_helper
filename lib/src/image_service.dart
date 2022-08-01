import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';

enum CompressWith {
  isolate,
  compute,
  mainThread,
}

/// Object to send to compute.
class ComputeMessage {
  final String path;
  final int quality;
  final String compressedImagePath;

  ComputeMessage({
    required this.path,
    required this.quality,
    required this.compressedImagePath,
  });
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

/// This class is used to compress images.
class ImageService {
  /// This method is used to compress an image from image path
  /// and return compressed image.
  static Future<File> compressImage(
    String path, {
    int quality = defaultQuality,
    CompressWith compressWith = CompressWith.compute,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    File compressedFile;
    final tempDir = await getTemporaryDirectory();
    final tempDirPath = tempDir.path;
    int rand = math.Random().nextInt(10000);
    final compressedImagePath = '$tempDirPath/image_$rand';
    switch (compressWith) {
      case CompressWith.isolate:
        ReceivePort receivePort = ReceivePort();
        IsolateMessage message = IsolateMessage(
          path: path,
          quality: quality,
          compressedImagePath: compressedImagePath,
          sendPort: receivePort.sendPort,
        );
        final isolate =
            await Isolate.spawn<IsolateMessage>(performIsolateTask, message);
        final result = await receivePort.first;
        isolate.kill(priority: Isolate.immediate);
        compressedFile = File(result);
        break;
      case CompressWith.compute:
        ComputeMessage message = ComputeMessage(
          path: path,
          quality: quality,
          compressedImagePath: compressedImagePath,
        );
        compressedFile = await compute(performComputeTask, message);
        break;
      case CompressWith.mainThread:
        compressedFile = await _compressImage(
          path,
          quality: quality,
          compressedImagePath: compressedImagePath,
        );
        break;
    }
    stopwatch.stop();
    debugPrint(
      'Compressed image[$quality] in ${stopwatch.elapsedMilliseconds}ms',
    );
    return compressedFile;
  }

  /// This function is to compress image
  static Future<File> _compressImage(
    String path, {
    required String compressedImagePath,
    int quality = defaultQuality,
  }) async {
    image_lib.Image? image =
        image_lib.decodeImage(File(path).readAsBytesSync());
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
  static void performIsolateTask(IsolateMessage message) async {
    var file = await _compressImage(
      message.path,
      quality: message.quality,
      compressedImagePath: message.compressedImagePath,
    );
    message.sendPort.send(file.path);
  }

  /// This function is to compress image using compute function
  static Future<File> performComputeTask(ComputeMessage message) async {
    return await _compressImage(
      message.path,
      quality: message.quality,
      compressedImagePath: message.compressedImagePath,
    );
  }
}
