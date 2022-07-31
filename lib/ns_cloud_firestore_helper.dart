library ns_cloud_firestore_helper;

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'ns_cloud_firestore_helper.dart';

export 'src/image_service.dart';

/// A helper class for working with Cloud Firestore.
class CloudFirestoreHelper {
  ///Upload a file to Firestore and return the download URL.
  static Future<String> uploadFile(
    File file,
    String path, {
    Map<String, String> customMetadata = const {},
  }) async {
    debugPrint("uploadFile start");
    var stopwatch = Stopwatch()..start();

    Reference storageReference = FirebaseStorage.instance.ref().child(path);

    final UploadTask uploadTask = storageReference.putFile(
      file,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: customMetadata,
      ),
    );

    TaskSnapshot snapshot = await uploadTask.whenComplete(() {
      debugPrint("uploadFile whenComplete");
    });

    debugPrint("uploadFile whenComplete[${snapshot.state.index}]");

    String fileUrl = await storageReference.getDownloadURL();
    debugPrint("uploadFile fileURL: $fileUrl");
    stopwatch.stop();
    debugPrint(
        "uploadFile time[${stopwatch.elapsedMilliseconds}] in Milliseconds");

    return fileUrl;
  }

  ///Compress file before Upload file to Firestore and return the download URL.
  static Future<String> compressAndUploadFile(
    File file,
    String path, {
    Map<String, String> customMetadata = const {},
    int quality = 85,
  }) async {
    debugPrint("compressAndUploadFile start");
    var stopwatch = Stopwatch()..start();
    final fileCompressed = await ImageService.compressImage(
      file.path,
      quality: quality,
    );

    final fileUrl = await uploadFile(
      fileCompressed,
      path,
      customMetadata: customMetadata,
    );

    debugPrint("uploadFile fileURL: $fileUrl");
    stopwatch.stop();
    debugPrint(
        "compressAndUploadFile time[${stopwatch.elapsedMilliseconds}] in Milliseconds");

    return fileUrl;
  }

  ///Compress file before Upload file to Firestore
  ///Upload a file to Firestore and
  ///run Callback when upload is complete.
  static Future<void> compressedUploadWithCallback(
    File file,
    String path, {
    Map<String, String> customMetadata = const {},
    required Function(String) onUploaded,
    int quality = 85,
  }) async {
    debugPrint("compressedUploadWithCallback start");
    var stopwatch = Stopwatch()..start();
    final fileUrl = await compressAndUploadFile(
      file,
      path,
      customMetadata: customMetadata,
      quality: quality,
    );
    debugPrint("compressedUploadWithCallback onUploaded callback started");
    await onUploaded(fileUrl);
    debugPrint("uploadFile fileURL: $fileUrl");
    stopwatch.stop();
    debugPrint(
      "compressedUploadWithCallback time[${stopwatch.elapsedMilliseconds}] in Milliseconds",
    );
  }
}
