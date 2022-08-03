import 'dart:developer' as developer;
import 'dart:io';

import 'package:filesize/filesize.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ns_cloud_firestore_helper/ns_cloud_firestore_helper.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ns_cloud_firestore_helper'),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _file;
  UploadStats? uploadStats;

  void _pickImage() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    _uploadImage(pickedFile);
  }

  void _clickImage() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    _uploadImage(pickedFile);
  }

  _uploadImage(pickedFile) async {
    Stopwatch stopwatch = Stopwatch()..start();
    EasyLoading.show(status: 'Loading...');
    try {
      setState(() {
        if (pickedFile != null) {
          _file = File(pickedFile.path);
        }
      });
      var downloadUrl = await CloudFirestoreHelper.uploadFile(
        _file!,
        'images/',
        onProgress: (data) {
          EasyLoading.show(status: '$data% uploaded');
        },
      );
      stopwatch.stop();

      setState(() {
        uploadStats = UploadStats(
          size: _file!.lengthSync(),
          timeTakenToUpload: stopwatch.elapsed.inMilliseconds,
          url: downloadUrl,
          compressedSize: 0,
          timeTakenToCompressed: 0,
          totalTimeTaken: stopwatch.elapsed.inMilliseconds,
        );
      });
    } on Exception catch (e, s) {
      developer.log(
        '_uploadImage',
        error: e,
        stackTrace: s,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: PageController(),
        children: <Widget>[
          _buildFileWidget(_file, 'Original', uploadStats),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            onPressed: _pickImage,
            tooltip: 'Pick Image',
            child: const Icon(Icons.image_search),
          ),
          FloatingActionButton(
            onPressed: _clickImage,
            tooltip: 'Click Image',
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _buildFileWidget(
    File? file,
    String label,
    UploadStats? uploadStats,
  ) {
    if (file != null) {
      return Container(
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabelWidget(label),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabelWidget(filesize(file.lengthSync())),
                  Flexible(
                    child: Image.file(
                      file,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
            ),
            _buildLabelWidget(
              'Upload Stats',
            ),
          ],
        ),
      );
    }

    return _buildLabelWidget('No Image Selected');
  }

  _buildLabelWidget(String label) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: Theme.of(context).textTheme.headline3!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}

class UploadStats {
  String url;
  int size;
  int timeTakenToCompressed;
  int compressedSize;
  int timeTakenToUpload;
  int totalTimeTaken;

  UploadStats({
    required this.url,
    required this.size,
    required this.timeTakenToCompressed,
    required this.compressedSize,
    required this.timeTakenToUpload,
    required this.totalTimeTaken,
  });
}
