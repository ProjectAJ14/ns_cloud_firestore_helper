library ns_cloud_firestore_helper;

export 'src/image_service.dart';

/// A helper class for working with Cloud Firestore.
class CloudFirestoreHelper {
  ///Upload a file to Firestore and return the download URL.
  static Future<String> uploadFile({
    required String localPath,
    required String storageReference,
  }) async {
    return '';
  }

  ///Upload a file to Firestore and
  ///save the download URL to the specified field
  ///in the specified document with a call back.
  ///If the file is an image then compress it before uploading.
  static Future<void> uploadFileAndSaveToField({
    required String localPath,
    required String storageReference,
    required Function(String) onUploaded,
  }) async {
    return;
  }
}
