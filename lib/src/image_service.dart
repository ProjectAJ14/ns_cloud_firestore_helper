import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as image_lib;
import 'package:path_provider/path_provider.dart';

Future<File> compressImage(File file) async {
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  int rand = math.Random().nextInt(10000);

  image_lib.Image? image = image_lib.decodeImage(file.readAsBytesSync());
  image_lib.Image smallerImage = image_lib.copyResize(
    image!,
    width: 1000,
  ); // choose the size here, it will maintain aspect ratio

  var compressedImage = File('$path/img_$rand.jpg')
    ..writeAsBytesSync(image_lib.encodeJpg(smallerImage, quality: 85));
  return compressedImage;
}
