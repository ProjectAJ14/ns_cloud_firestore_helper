import 'dart:developer' as developer;
import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ns_cloud_firestore_helper/ns_cloud_firestore_helper.dart';

void main() {
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
  File? _compressedFile;
  File? _thumbnailFile;
  File? _thumbnailC1File;
  File? _thumbnailC2File;
  File? _thumbnailC3File;

  void _pickImage() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    _processImage(pickedFile);
  }

  void _clickImage() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    _processImage(pickedFile);
  }

  _processImage(pickedFile) async {
    EasyLoading.show(status: 'Loading...');
    try {
      setState(() {
        if (pickedFile != null) {
          _file = File(pickedFile.path);
        }
      });
      if (_file != null) {
        var compressedFile = await ImageService.compressImage(
          _file!.path,
          quality: 100,
          compressWith: CompressWith.compute,
        );
        var thumbnailFile = await ImageService.compressImage(
          _file!.path,
          quality: 1,
          compressWith: CompressWith.compute,
        );
        var thumbnailC1File = await ImageService.compressImage(
          thumbnailFile.path,
          quality: 1,
          compressWith: CompressWith.compute,
        );
        var thumbnailC2File = await ImageService.compressImage(
          thumbnailC1File.path,
          quality: 1,
          compressWith: CompressWith.compute,
        );
        var thumbnailC3File = await ImageService.compressImage(
          thumbnailC2File.path,
          quality: 1,
          compressWith: CompressWith.compute,
        );
        setState(() {
          _compressedFile = compressedFile;
          _thumbnailFile = thumbnailFile;
          _thumbnailC1File = thumbnailC1File;
          _thumbnailC2File = thumbnailC2File;
          _thumbnailC3File = thumbnailC3File;
        });
      }
    } on Exception catch (e, s) {
      developer.log(
        '_processImage',
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
          _buildFileWidget(_file, 'Original'),
          _buildFileWidget(_compressedFile, 'Compressed'),
          _buildFileWidget(_thumbnailFile, 'Thumbnail'),
          _buildFileWidget(_thumbnailC1File, 'C-1 Thumbnail'),
          _buildFileWidget(_thumbnailC2File, 'C-2 Thumbnail'),
          _buildFileWidget(_thumbnailC3File, 'C-3 Thumbnail'),
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

  _buildFileWidget(File? file, String label) {
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
