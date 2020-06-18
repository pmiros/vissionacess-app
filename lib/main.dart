import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
// Ensure that plugin services are initialized so that `availableCameras()`
// can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

// Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
// Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  FlutterTts flutterTts = FlutterTts();
  bool state = false;

  @override
  void initState() {
    super.initState();
// To display the current output from the Camera,
// create a CameraController.
    _controller = CameraController(
// Get a specific camera from the list of available cameras.
      widget.camera,
// Define the resolution to use.
      ResolutionPreset.medium,
    );

// Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
// Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Take a picture')),
// Wait until the controller is initialized before displaying the
// camera preview. Use a FutureBuilder to display a loading spinner
// until the controller has finished initializing.
        body: Stack(children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
// If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
// Otherwise, display a loading indicator.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          GestureDetector(
              onTap: () async {
                if (state == true) {
                  state = false;
                } else {
                  state = true;
                }
                if (state == true) {
                  startTimeout(0);
                }
// try {

//  bool state = false;

//}
//on IntegerDivisionByZeroException{
// Exception code
//}
              },
              child: Opacity(child: Container(color: Colors.blue), opacity: 0))
        ]));
  }

  Future<http.Response> postRequest(String rawJson) async {
    var url = Uri.parse("https://pyth-acess.herokuapp.com/");
    print(url.port);
    var bodyJ = rawJson;

    print("Body: " + bodyJ);

    final response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyJ);
    if (response.statusCode == 200) {
// If the server did return a 200 OK response,
// then parse the JSON.

      Map<String, dynamic> json = jsonDecode(response.body);
      String myTextOLD = json['image'];
      var myText =
          myTextOLD.replaceAll("!-+.(@|%£^#&^)-%[]:;',/*`~^+=<>\\", "");
      if (myTextOLD == "") ;
      {
        bool state = true;
        startTimeout(5000);
      }
      print(myText);
      _speak(myText);
      startTimeout(5000);
    } else {
// If the server did not return a 200 OK response,
// then throw an exception.
      throw Exception('Failed to load');
    }
  }

  final timeout = const Duration(seconds: 3);
  final ms = const Duration(milliseconds: 1);

  startTimeout([int milliseconds]) {
    if (state == true) {
      var duration = milliseconds == null ? timeout : ms * milliseconds;
      return new Timer(duration, handleTimeout);
    }
  }

  Future<void> handleTimeout() async {
    // callback function
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    // Ensure that the camera is initialized.

    await _initializeControllerFuture;

    // Construct the path where the image should be saved using the
    // pattern package.
    final path = join(
      // Store the picture in the temp directory.
// Find the temp directory using the `path_provider` plugin.
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

// Attempt to take a picture and log where it's been saved.
    await _controller.takePicture(path);

    List<int> imageBytes = File(path).readAsBytesSync();
//print(imageBytes);
    String base64Image = base64Encode(imageBytes);
//print(base64Image);
//List<int> convertedByte = base64Decode(base64Image);

//await File(path).writeAsBytes(imageBytes);
    Map<String, dynamic> map = {'image': base64Image};
    String rawJson = jsonEncode(map);
    postRequest(rawJson);
  }

  Future _speak(String text) async {
    var result = await flutterTts.speak(text);
//if (result == 1) setState(() => ttsState = TtsState.playing);
  }
}
