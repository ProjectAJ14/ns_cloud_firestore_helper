import 'compress_type.dart';

/// Object to send to compute.
class ComputeMessage {
  final String filePath;
  final CompressType compressType;
  final String tempPath;

  ComputeMessage({
    required this.filePath,
    required this.compressType,
    required this.tempPath,
  });
}
