import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_test/video_play_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with WidgetsBindingObserver{

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  bool isStreaming = false;
  int homeScore = 0;
  int awayScore = 0;

  String saveTextFilePath = "";
  String? _localFilePath, _fontPath;


  @override
  void initState() {
    super.initState();
    createTextFile();
    _loadAssetVideo();
    getPermission();
    WidgetsBinding.instance.addObserver(this);
  //  _initializeCamera();
  }

  void getPermission()async{
    Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
        Permission.storage,
    ].request();
  }

  void createTextFile() async {
    final directory = await Directory.systemTemp.createTemp();
    final file = File('${directory.path}/foot_score.txt');
    saveTextFilePath = directory.path;

    // Write text to the file
    await file.writeAsString('Score: 0 - 0');

    print('File created at: ${file.path}');
  }

  Future<void> _loadAssetVideo() async {
    final ByteData data = await rootBundle.load('assets/test.mp4');
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/sample_video.mp4');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    var fontData = await getFontFilePath();
    setState(() {
      _localFilePath = tempFile.path;
      _fontPath = fontData;
    });
  }

  Future<void> _assetFileStreaming()async{
    print("work $_localFilePath");
    if (_localFilePath == null) return;
    String ffmpegCommand = '-re -i $_localFilePath -f flv $streamUrl';
    await FFmpegKit.execute(ffmpegCommand).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogs();
      for (var log in logs) {
        if (kDebugMode) {
          print(log.getMessage());
        }
      }
      if (ReturnCode.isSuccess(returnCode)) {
        if (kDebugMode) {
          print('Stream started successfully');
        }
        isStreaming= true;
        setState(() {

        });
        //_controller.play();
      } else {
        if (kDebugMode) {
          print('Failed to start stream');
        }
      }
    });
  }


  Future<String> getFontFilePath() async {
    final byteData = await rootBundle.load('assets/fonts/fontt.ttf');
    final file = File('${(await getTemporaryDirectory()).path}/my_custom_font.ttf');
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return file.path;
  }


  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.length > 1?cameras[1]:cameras[0];
      print("camera length ${cameras.length}");

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      _initializeControllerFuture = _controller.initialize();

    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _stopRecording() {
    // Stop the recording by cancelling the FFmpeg session
    FFmpegKit.cancel();
    isStreaming= false;
    setState(() {

    });
    print("stopped");
  }

  Future _debugLocally()async{
    print("work");
    final file = '${(await getDownloadsDirectory())?.path}/output.mp4';
    print(file);

     // var command = "-f android_camera -video_size 1280x720 -i 0 -c:a aac -strict experimental -y $file";
    var command = "-re -i $_localFilePath -y $file";

     FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogs();
      logs.forEach((log) => print(log.getMessage()));
      if (ReturnCode.isSuccess(returnCode)) {
        print('Stream started successfully');
        isStreaming= true;
        setState(() {

        });
        //_controller.play();
      } else {
        print('Failed to start stream');
      }
    });
  }

  Future checkFileExit()async{

    if( File(path).existsSync()){
      print("exit");
    }
  }

  Future<void> _checkInputCount()async{
    var command = "-hide_banner -f dshow true -i """;

    FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogs();
      for (var log in logs) {
        if (kDebugMode) {
          print(log.getMessage());
        }
      }

      if (ReturnCode.isSuccess(returnCode)) {

        // SUCCESS

      } else if (ReturnCode.isCancel(returnCode)) {

        // CANCEL

      } else {

        // ERROR

      }
    });
  }

  String streamUrl = "rtmp://a.rtmp.youtube.com/live2/6yk2-4yr4-j0j9-kjcg-93da";
  var path = "/storage/emulated/0/Android/data/com.example.live_test/files/downloads/output.mp4";

  Future _startCameraStream() async{
    isStreaming = true;
    setState(() {

    });
    final command = '-f android_camera -i 0:1 -f flv $streamUrl';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogs();
      logs.forEach((log) => print(log.getMessage()));
      if (ReturnCode.isSuccess(returnCode)) {
        print('Stream started successfully');
        isStreaming= true;
        setState(() {

        });
        //_controller.play();
      } else {
        print('Failed to start stream');
      }
    });
  }

   Future<void> _startStreaming() async {


    if (_localFilePath == null) return;

    var scorePath = "$saveTextFilePath/foot_score.txt";


    // Replace YOUR_STREAM_URL with the actual stream URL
    String streamUrl = "rtmp://a.rtmp.youtube.com/live2/6yk2-4yr4-j0j9-kjcg-93da";
     //var ffmpegCommand = "-re -i $_localFilePath -vf 'drawtext=textfile=$scorePath:fontcolor=white:reload=1:fontfile=$_fontPath:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2' -b:a 128k -f flv $streamUrl";
    var ffmpegCommand = "-re -i $_localFilePath -t 10 -y $path";

    //String ffmpegCommand = '-re -i $_localFilePath -c:v libx264 -preset veryfast -maxrate 3000k -bufsize 6000k -c:a aac -ar 44100 -b:a 128k -f flv $streamUrl';


   await FFmpegKit.execute(ffmpegCommand).then((session) async {
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogs();
      logs.forEach((log) => print(log.getMessage()));
      if (ReturnCode.isSuccess(returnCode)) {
        print('Stream started successfully');
        isStreaming= true;
        setState(() {

        });
        //_controller.play();
      } else {
        print('Failed to start stream');
      }
    });


  }

  Future<void> readTextFile() async {
    final file = File('$saveTextFilePath/foot_score.txt');

    // Read the file
    String contents = await file.readAsString();
    print('File contents: $contents');
  }

  Future<void> updateTextFile(int hScore, int aSore)async{
    print("weork");

    final file = File('$saveTextFilePath/foot_score.txt');
    await file.writeAsString('Score: $hScore - $aSore');
    homeScore = hScore;
    awayScore = aSore;
    setState(() {

    });


    print("working");
    readTextFile();
  }

  var isLoading = false;
  Future _recordFromCamera()async{
    var path = await getApplicationDocumentsDirectory();
    var finalPath = "${path.path}/test.mp4";
    print(finalPath);
    isLoading = true;
    setState(() {

    });
    //var command = "-y -f android_camera -camera_index 1 -video_size 1280x720 -i discarded -r 30 -c:v mpeg4 $finalPath";
     var command = "-loglevel debug -f android_camera -camera_index 1 -video_size 640x480 -i 0 -r 15 -f flv $streamUrl";
    print("dsfajkfhjk");

   await FFmpegKit.executeAsync(command).then((session)async{
      print("woking");
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogs();
      for (var log in logs) {
        if (kDebugMode) {
          print(log.getMessage());
        }
      }
      isLoading = false;
      setState(() {

      });
      print("woking 2");
      if (ReturnCode.isSuccess(returnCode)) {
        if (kDebugMode) {
          print('Record started successfully');
        }
        isStreaming= true;
        setState(() {

        });
        //_controller.play();
      } else {
        if (kDebugMode) {
          print('Failed to start record');
        }
      }
    });

  }

  Future _playRecordVideo()async{
    var path = "/data/user/0/com.example.live_test/app_flutter/test.raw";
    debugPrint("worked");
 await   FFprobeKit.getMediaInformation('https://www.youtube.com/watch?v=jnMFWtCHPY8').then((session) async {
      final information = await session.getMediaInformation();
      debugPrint("worked 2");
      if (information == null) {
        debugPrint("worked 3");

        // CHECK THE FOLLOWING ATTRIBUTES ON ERROR
        final state = FFmpegKitConfig.sessionStateToString(await session.getState());
        final returnCode = await session.getReturnCode();
        final failStackTrace = await session.getFailStackTrace();
        final duration = await session.getDuration();
        print(duration);
        final output = await session.getOutput();
        print(output);
      }
    });
    }

  ///commands
  /// ffmpeg -hide_banner -f dshow -list_devices true -i "" check device
  ///

  Future<String> _createCameraFilePath()async{
    var path = await getApplicationDocumentsDirectory();
    return "${path.path}/camerafile.raw";
  }

  Future<void> _streamUpload() async {



  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            //_playRecordVideo();
            Navigator.push(context, MaterialPageRoute(builder: (_)=> VideoPlayPage(path: '/data/user/0/com.example.live_test/app_flutter/test.mp4')));
          }, icon: Icon(Icons.play_arrow)),
          IconButton(onPressed: (){
            checkFileExit();
          }, icon: Icon(Icons.check))
        ],
      ),
      body: Row(
        children: <Widget>[
          // Expanded(child:
          //   FutureBuilder<void>(
          //     future: _initializeControllerFuture,
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.done) {
          //         return CameraPreview(_controller);
          //       } else {
          //         return Center(child: CircularProgressIndicator());
          //       }
          //     },
          //   ),
          // ),
          const  SizedBox(width: 10,),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text("Home $homeScore - $awayScore Away",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircleAvatar(
                    child: IconButton(onPressed: (){

                      updateTextFile(++homeScore, awayScore);

                    }, icon:const Icon(Icons.add)),
                  ),
                  const  Text("Home",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                  CircleAvatar(
                    child: IconButton(onPressed: (){
                      updateTextFile(--homeScore, awayScore);
                    }, icon:const Icon(Icons.remove)),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircleAvatar(
                    child: IconButton(onPressed: (){
                      updateTextFile(homeScore, ++awayScore);
                    }, icon:const Icon(Icons.add)),
                  ),
                  const   Text("Away",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                  CircleAvatar(
                    child: IconButton(onPressed: (){
                      updateTextFile(homeScore, --awayScore);
                    }, icon:const Icon(Icons.remove)),
                  ),
                ],
              ),
             isLoading?CircularProgressIndicator(): ElevatedButton(onPressed: ()async{
               //await _checkInputCount();
                if(isStreaming){
                  _stopRecording();
                }else{
                  // _startCameraStream();
                  _recordFromCamera();
              }
              }, style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((_)=> Colors.deepPurple)
              ),child: Text(isStreaming?"Stop Streaming":"Start Streaming",style: TextStyle(color: Colors.white),)),

            ],
          )),

        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }


  void stopStreaming() {
    FFmpegKit.cancel();
    isStreaming= false;
    setState(() {

    });
  }
}
