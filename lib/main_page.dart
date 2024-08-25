import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LiveStreamScreen extends StatefulWidget {
  @override
  _LiveStreamScreenState createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  bool isStreaming = false;
  int homeScore = 0;
  int awayScore = 0;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  String saveFilePath = "";

  @override
  void initState() {
    super.initState();
    initCamera();
    createTextFile();
  }

  void createTextFile() async {
    final directory = await Directory.systemTemp.createTemp();
    final file = File('${directory.path}/foot_score.txt');
    saveFilePath = directory.path;

    // Write text to the file
    await file.writeAsString('Score: 0 - 0');

    print('File created at: ${file.path}');
  }

  Future<void> readTextFile() async {
    final file = File('$saveFilePath/foot_score.txt');

    print(saveFilePath);

    // Read the file
    String contents = await file.readAsString();
    print('File contents: $contents');
  }

  Future<void> updateTextFile(int homeScore, int awayScore)async{

    final file = File('$saveFilePath/foot_score.txt');
    await file.writeAsString('Score: $homeScore - $awayScore');

    readTextFile();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras![0],
      ResolutionPreset.high,
    );
    await _cameraController?.initialize();
    setState(() {});
  }

  void startFFmpegStreaming() async{
    try {
      String command = buildFFmpegCommand();
      await FFmpegKit.execute(command).then((session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          debugPrint('Video compression completed successfully: ');
        } else {
          debugPrint('*********Video compression failed.af------');
        }
      });
    } on Exception catch (e) {
      print("------********************----------------------");
      print("Exception is ${e.toString()}");
    }
  }

  String buildFFmpegCommand() {
    var scorePath = saveFilePath+"/foot_score.txt";
    return "-f android_camera -i 0 "
        "-vf \"drawtext=textfile='$scorePath':reload=1:fontcolor=white:fontsize=24:x=10:y=10\" "
        "-f flv rtmp://stream.dlive.tv/live";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Camera Stream with Score Overlay'),
      ),
      body: Column(
        children: [
          cameras != null && cameras!.isNotEmpty? AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ):const SizedBox(),
          Text(
            'Home: $homeScore - Away: $awayScore',
            style: TextStyle(fontSize: 24),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {

                  setState(() {
                    homeScore++;
                  });
                  updateScoreFile(homeScore, awayScore);
                  updateTextFile(homeScore, awayScore);
                },
                child: Text('Home +1'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    awayScore++;
                  });
                  updateScoreFile(homeScore, awayScore);
                  updateTextFile(homeScore, awayScore);
                },
                child: Text('Away +1'),
              ),
            ],
          ),
          SizedBox(height: 50,),
          ElevatedButton(onPressed: (){
            //readTextFile();
            startFFmpegStreaming();
          }, child: Text("Start Live"))
        ],
      ),
    );
  }


  void updateScoreFile(int homeScore, int awayScore) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/score.txt';
    final file = File(path);

    // Write the updated score to the file
    await file.writeAsString('Home: $homeScore Away: $awayScore');
  }

  @override
  void dispose() {
    FFmpegKit.cancel();
    super.dispose();
  }
}
