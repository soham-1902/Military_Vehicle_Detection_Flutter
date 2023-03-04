import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:tflite/tflite.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  bool _loading = true;
  late File _image;
  final imagePicker = ImagePicker();
  List predictions = [];

  _getFromGallery() async {
    var image = await imagePicker.getImage(source: ImageSource.gallery);
    if(image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    
    detectImage(_image);
  }

  _getFromCamera() async {
    var image = await imagePicker.getImage(source: ImageSource.camera);
    if(image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectImage(_image);
  }

  loadModel() async {
    await Tflite.loadModel(model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt',);
  }

  detectImage(File img) async {
    var prediction = await Tflite.runModelOnImage(path: img.path, numResults: 2,
      threshold: 0.6, imageMean: 127.5, imageStd: 127.5);

    setState(() {
      _loading = false;
      predictions = prediction!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(
            'Millitary Vehicle Detector',
            style: TextStyle(
              color: Colors.yellowAccent
          ),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(child: LottieBuilder.asset('assets/lottie/soldier.json', height: 250, width: 250,)),
            Row(
              children: [
                SizedBox(width: 10,),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        _getFromCamera();
                      },
                      child: Text(
                        'Capture'
                      ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _getFromGallery();
                    },
                    child: Text(
                      'From Gallery',
                    ),
                  ),
                ),
                SizedBox(width: 10,),
              ],
            ),

            _loading == false?
                Column(
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      child: Image.file(_image),
                    ),
                    Text(
                      'Looks like it\'s a ' + predictions[0]['label'].toString().substring(2) + '.',
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                    Text(
                      'Saying that with a confidence of ' + (predictions[0]['confidence'] * 100).toString().substring(0, 5) + '%',
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ],
                ):Container()
          ],
        ),
      ),
    );
  }
}
