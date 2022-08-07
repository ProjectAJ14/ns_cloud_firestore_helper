import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'models/compress_type.dart';
import 'models/compute_message.dart';
import 'utils/constants.dart';
import 'utils/methods.dart';

/// This class is used to compress images.
class ImageService {
  /// This method is used to compress an image from image path
  /// and return compressed image.
  static Future<File> compressImage(
    String filePath, {
    int quality = defaultQuality,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    final tempDir = await getTemporaryDirectory();
    final tempDirPath = tempDir.path;
    int postFix = math.Random().nextInt(1000);
    int perFix = math.Random().nextInt(1000);
    final tempPath = '$tempDirPath/temp_${perFix}_$postFix';

    String extension = path.extension(filePath); // '.png'

    CompressType compressType = compressQuality(
      extension,
      await File(filePath).length(),
      quality,
    );

    ComputeMessage message = ComputeMessage(
      filePath: filePath,
      compressType: compressType,
      tempPath: tempPath,
    );

    return await _computeTask(
      filePath,
      compressType: compressType,
      tempPath: tempPath,
    );

    File compressedFile = await compute(performComputeTask, message);
    stopwatch.stop();
    developer.log(
      'Compressed image[$filePath][$quality][$extension] in '
      '${stopwatch.elapsed.inSeconds}s [$tempPath]',
    );
    return compressedFile;
  }

  /// This function is to compress image
  static Future<File> _computeTask(
    String filePath, {
    required String tempPath,
    required CompressType compressType,
  }) async {
    developer.log(
      '_computeTask[$filePath][$compressType][$tempPath]',
    );
    image_lib.Image? image =
        image_lib.decodeImage(File(filePath).readAsBytesSync());

    image_lib.Image smallerImage = image_lib.copyResize(
      image!,
      width: image.width ~/ 2,
    ); // choose the size here, it will maintain aspect ratio

    List<int> bytes = [];

    if (compressType.isPng) {
      bytes = image_lib.encodePng(
        smallerImage,
        level: compressType.quality,
      );
    } else {
      bytes = image_lib.encodeJpg(
        smallerImage,
        quality: compressType.quality,
      );
    }

    File compressedFile = File(tempPath)..writeAsBytes(bytes);
    return compressedFile;
  }

  /// This function is to compress image using compute function
  static Future<File> performComputeTask(ComputeMessage message) async {
    return await _computeTask(
      message.filePath,
      compressType: message.compressType,
      tempPath: message.tempPath,
    );
  }
}
