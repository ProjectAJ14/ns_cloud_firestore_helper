library ns_cloud_firestore_helper;

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ns_cloud_firestore_helper/utils/constants.dart';

import 'ns_cloud_firestore_helper.dart';

export 'src/image_service.dart';

/// A helper class for working with Cloud Firestore.
class CloudFirestoreHelper {
  ///Compress file before Upload file to Firestore and return the download URL.
  static Future<String> uploadImageFile(
    File file,
    String storageLocation, {
    int quality = defaultQuality,
    Function(String)? onProgress,
    Map<String, String> customMetadata = const {},
  }) async {
    debugPrint("uploadFile start");
    var stopwatch = Stopwatch()..start();

    var compressedFile = await ImageService.compressImage(
      file.path,
      quality: quality,
    );

    Reference storageReference =
        FirebaseStorage.instance.ref().child(storageLocation);

    final UploadTask uploadTask = storageReference.putFile(
      compressedFile,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: customMetadata,
      ),
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
