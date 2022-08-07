import 'dart:developer' as developer;

import '../models/compress_type.dart';
import 'constants.dart';

CompressType compressQuality(
  String extension,
  int fileSize,
  int quality,
) {
  //1MB~1048576KB
  //2MB~2097152KB
  //4MB~4194304KB
  //5MB~5242880KB

  CompressType compressType = CompressType();

  if (extension.endsWith('.jpg') || extension.endsWith('.jpeg')) {
    compressType.type = 'jpg';
    if (quality != defaultQuality) {
      compressType.quality = defaultQuality;
    }
    if (fileSize <= 1048576) {
      compressType.quality = 95;
    } else if (fileSize <= 2097152) {
      compressType.quality = 90;
    } else if (fileSize <= 4194304) {
      compressType.quality = 85;
    } else if (fileSize <= 5242880) {
      compressType.quality = 80;
    } else {
      compressType.quality = 75;
    }
  } else {
    compressType.type = 'png';
    if (fileSize <= 1048576) {
      compressType.quality = 6;
    } else if (fileSize <= 2097152) {
      compressType.quality = 5;
    } else if (fileSize <= 4194304) {
      compressType.quality = 4;
    } else if (fileSize <= 5242880) {
      compressType.quality = 3;
    } else {
      compressType.quality = 2;
    }
  }

  developer.log(
    'Compress Quality compressType'
    '[${compressType.type}][${compressType.quality}]',
  );
  return compressType;
}
