library ns_cloud_firestore_helper;

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

export 'src/image_service.dart';

/// A helper class for working with Cloud Firestore.
class CloudFirestoreHelper {
  ///Compress file before Upload file to Firestore and return the download URL.
  static Future<String> uploadImageFile(
    File file,
    String storageLocation, {
    int quality = 85,
    Function(String)? onProgress,
    SettableMetadata? settableMetadata,
  }) async {
    debugPrint("uploadFile start");
    var stopwatch = Stopwatch()..start();

    Reference storageReference =
        FirebaseStorage.instance.ref().child(storageLocation);

    final UploadTask uploadTask = storageReference.putFile(
      file,
      settableMetadata,
    );

    uploadTask.snapshotEvents.listen((event) {
      final double progress = (event.bytesTransferred / event.totalBytes) * 100;
      if (onProgress != null) {
        onProgress(progress.toStringAsFixed(2));
      }
    });

    TaskSnapshot snapshot = await uploadTask.whenComplete(() {
      debugPrint("UploadFile whenComplete");
    });

    debugPrint("UploadFile whenComplete[${snapshot.state.index}]");

    String fileUrl = await storageReference.getDownloadURL();
    debugPrint("UploadFile fileURL: $fileUrl");
    stopwatch.stop();
    debugPrint(
      "UploadFile time[${stopwatch.elapsedMilliseconds}] in Milliseconds",
    );
    return fileUrl;
  }
}
