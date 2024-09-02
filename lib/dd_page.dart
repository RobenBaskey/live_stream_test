import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DDPage extends StatefulWidget {
  const DDPage({super.key});

  @override
  State<DDPage> createState() => _DDPageState();
}

class _DDPageState extends State<DDPage> {

  late CameraController _cameraController;
  late StreamController<List<int>> _streamController;
  late File _tempFile;
  late String _outputPath;
  late String _streamUrl;
  var isLoading = true;

  @override
  void initState() {
    super.initState();

    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _streamController.close();
    super.dispose();
  }

  Future _initializeCamera() async{
    isLoading = true;
    setState(() {

    });
    var cameras = await availableCameras();
    if(cameras.isNotEmpty){
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _cameraController.initialize();
    isLoading = false;
    setState(() {});

    final directory = await getTemporaryDirectory();
    _tempFile = File('${directory.path}/temp_video.yuv');

    _streamController = StreamController<List<int>>();

    // Example output path and stream URL
    var path = await getApplicationDocumentsDirectory();
    _outputPath = '${path.path}/output.mp4';
    _streamUrl = 'rtmp://a.rtmp.youtube.com/live2/6yk2-4yr4-j0j9-kjcg-93da';

    // Start streaming and recording
    startStreamingAndRecording(_streamUrl, _outputPath);}
  }

  Future<void> startStreamingAndRecording(String streamUrl, String outputPath) async {
    // Open the temporary file in write mode
    final fileStream = _tempFile.openWrite();

    _cameraController.startImageStream((CameraImage image) async {
      // Convert CameraImage to raw bytes
      final List<int> bytes = _convertImageToBytes(image);

      // Write raw bytes to the file
      fileStream.add(bytes);
    });

    // Start FFmpeg process to read from the temporary file
    String ffmpegCommand =
        '-f rawvideo '
        '-i ${_tempFile.path} '
        '-f flv $streamUrl $outputPath';

    FFmpegKit.executeAsync(ffmpegCommand, (session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print("FFmpeg command executed successfully.");
      } else if (ReturnCode.isCancel(returnCode)) {
        print("FFmpeg command execution was canceled.");
      } else {
        print("FFmpeg command failed with return code $returnCode.");
      }
    });
  }

  List<int> _convertImageToBytes(CameraImage image) {
    final List<int> bytes = [];
    final int width = image.width;
    final int height = image.height;

    // Add Y component
    for (int i = 0; i < height; i++) {
      bytes.addAll(image.planes[0].bytes.sublist(i * width, (i + 1) * width));
    }

    // Add U and V components (assuming YUV420)
    for (int i = 0; i < height ~/ 2; i++) {
      bytes.addAll(image.planes[1].bytes.sublist(i * width ~/ 2, (i + 1) * width ~/ 2));
      bytes.addAll(image.planes[2].bytes.sublist(i * width ~/ 2, (i + 1) * width ~/ 2));
    }

    return bytes;
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading || !_cameraController.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Camera Stream and Record')),
      body: CameraPreview(_cameraController),
    );
  }
}

