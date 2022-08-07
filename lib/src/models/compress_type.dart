class CompressType {
  int quality = 85;
  String type = 'png';

  bool get isPng => type == 'png';

  @override
  String toString() {
    return 'CompressType{quality: $quality, type: $type}';
  }
}
