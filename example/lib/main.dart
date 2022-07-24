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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
        var compressedFile = await ImageService.getCompressedImage(
          _file!,
          withIsolates: true,
        );
        var thumbnailFile = await ImageService.getCompressedImage(
          _file!,
          quality: 1,
          withIsolates: true,
        );
        setState(() {
          _compressedFile = compressedFile;
          _thumbnailFile = thumbnailFile;
        });
      }
    } on Exception catch (e, s) {
      print(e);
      print(s);
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
        controller: PageController(viewportFraction: 0.9),
        children: <Widget>[
          _buildFileWidget(_file, 'Original'),
          _buildFileWidget(_compressedFile, 'Compressed'),
          _buildFileWidget(_thumbnailFile, 'Thumbnail'),
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
        color: Colors.black.withOpacity(0.1),
        child: Column(
          children: [
            _buildLabelWidget(label),
            Flexible(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(file),
                  _buildLabelWidget(filesize(file.lengthSync())),
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
