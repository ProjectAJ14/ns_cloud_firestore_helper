import 'dart:developer' as developer;
import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final cred = await FirebaseAuth.instance.signInAnonymously();
  debugPrint("usr.uid: ${cred.user?.uid}");
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: PageController(),
        children: const [
          ImageUploadWidget(
            label: 'Compressed',
            compress: true,
          ),
          ImageUploadWidget(
            label: 'Original',
            compress: false,
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ImageUploadWidget extends StatefulWidget {
  const ImageUploadWidget({
    Key? key,
    required this.label,
    required this.compress,
  }) : super(key: key);

  final String label;
  final bool compress;

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  FileStats? fileStatsOG;

  String get label => widget.label;

  bool get compress => widget.compress;

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
      if (pickedFile != null) {
        fileStatsOG = FileStats(File(pickedFile.path));
        fileStatsOG!.size = await fileStatsOG!.file.length();
        setState(() {});
      }
      if (compress) {
        var compressedFile = await ImageService.compressImage(
          fileStatsOG!.file.path,
        );
        fileStatsOG!.compressedSize = await compressedFile.length();
        fileStatsOG!.url = await CloudFirestoreHelper.uploadImageFile(
          compressedFile,
          'images/',
          onProgress: (data) {
            debugPrint('progress: $data');
            EasyLoading.showProgress(
              double.parse(data) / 100,
              status: 'Uploading...',
            );
          },
        );
      } else {
        fileStatsOG!.url = await CloudFirestoreHelper.uploadFile(
          fileStatsOG!.file,
          'images/',
          onProgress: (String data) {
            debugPrint('progress: $data');
            EasyLoading.showProgress(
              double.parse(data) / 100,
              status: 'Uploading...',
            );
          },
        );
      }

      stopwatch.stop();
      fileStatsOG!.timeTaken = stopwatch.elapsed;
      setState(() {});
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

  _buildFileWidget(
    String label,
    FileStats? fileStats,
  ) {
    if (fileStatsOG == null) {
      return Column(
        children: [
          _buildLabelWidget(
            '$label : Select File',
            fontSize: 30,
          ),
          const Spacer(),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
            ),
          ),
        ],
      );
    } else {
      return Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabelWidget(
              label,
              fontSize: 16,
            ),
            if (fileStats!.size != 0)
              _buildLabelWidget(filesize(fileStatsOG!.size)),
            Flexible(
              child: fileStatsOG!.url.isNotEmpty
                  ? Image.network(
                      fileStatsOG!.url,
                      fit: BoxFit.fitWidth,
                    )
                  : Image.file(
                      fileStatsOG!.file,
                      fit: BoxFit.fitWidth,
                    ),
            ),
            _buildLabelWidget(
              'Time taken: ${fileStatsOG!.timeTaken.inSeconds}Seconds',
              fontSize: 12,
            ),
            _buildLabelWidget(
              'url : ${fileStatsOG!.url}',
              fontSize: 10,
            ),
            if (compress)
              _buildLabelWidget(
                'Compressed Size: ${filesize(fileStatsOG!.compressedSize)}',
                fontSize: 10,
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
              ),
            )
          ],
        ),
      );
    }
  }

  _buildLabelWidget(
    String label, {
    double fontSize = 12,
  }) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: Theme.of(context).textTheme.headline3!.copyWith(
                color: Colors.white,
                fontSize: fontSize,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildFileWidget(label, fileStatsOG);
  }
}

class FileStats {
  File file;

  String url = '';
  int size = 0;
  int compressedSize = 0;
  Duration timeTaken = const Duration(seconds: 0);

  FileStats(this.file);
}
