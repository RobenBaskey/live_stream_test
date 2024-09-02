import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_test/video_play_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class LiveStreamScreen extends StatefulWidget {
  @override
  _LiveStreamScreenState createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {

  void startStreaming() {
//     String streamKey = "uv2s-seh8-t02x-ys3j-47xu";
//     String inputSource = "E:\Project\live_test\assets\test.mp4";
// String ffmpegCommand = "ffplay $inputSource";
//     //String ffmpegCommand = "-f avfoundation -i $inputSource -c:v libx264 -preset veryfast -maxrate 3000k -bufsize 6000k -vf \"scale=1280:720\" -g 50 -c:a aac -b:a 128k -f flv rtmp://a.rtmp.youtube.com/live2/$streamKey";
//
//     FFmpegKit.execute(ffmpegCommand).then((session) async {
//       final returnCode = await session.getReturnCode();
//       if (ReturnCode.isSuccess(returnCode)) {
//         print("Streaming started successfully!");
//       } else {
//         print("Failed to start streaming. Return code: $returnCode");
//       }
//     });
  }

  void stopStreaming() {
    FFmpegKit.cancel();
    isStreaming= false;
    setState(() {

    });
  }

  void createTextFile() async {
    final directory = await Directory.systemTemp.createTemp();
    final file = File('${directory.path}/foot_score.txt');
    saveFilePath = directory.path;

    // Write text to the file
    await file.writeAsString('Score: 0 - 0');

    print('File created at: ${file.path}');
  }



  Future<void> initCamera() async {
    cameras = await availableCameras();
    if(cameras!= null && cameras!.isNotEmpty){
      _cameraController = CameraController(
        cameras!.first,
        ResolutionPreset.high,
      );
      await _cameraController?.initialize();
      setState(() {});
    }

  }

  void setTextOverlay()async{
    // if (_localFilePath == null) return;
    // final Directory tempDir = await getTemporaryDirectory();
    // var path ="${tempDir.path}/ot.mp4";
    // String command ="ffmpeg -i $_localFilePath -vf \"drawtext=text='Hello, this is for test.'\" -c:a copy $path";
    // FFmpegKit.execute(command).then((session) async {
    //   final returnCode = await session.getReturnCode();
    //   final logs = await session.getAllLogs();
    //   logs.forEach((log) => print(log.getMessage()));
    //   if (ReturnCode.isSuccess(returnCode)) {
    //     print('Stream started successfully');
    //   } else {
    //     print('Failed to start stream');
    //   }
    // });

  }

  void startFFmpegStreaming() async{
    // try {
    //   String command =await buildFFmpegCommand();
    //   await FFmpegKit.execute(command).then((session) async {
    //     final returnCode = await session.getReturnCode();
    //     if (ReturnCode.isSuccess(returnCode)) {
    //       debugPrint('Video compression completed successfully: ');
    //     } else {
    //
    //       debugPrint('*********Video compression failed.af------');
    //     }
    //   });
    // } on Exception catch (e) {
    //   print("------********************----------------------");
    //   print("Exception is ${e.toString()}");
    // }
  }

   Future<bool> encodeVideo(String inputPath, String outputPath) async {
    // //String command = '-i $inputPath -vcodec libx264 -crf 28 $outputPath';
    // bool result = false;
    //
    // String command = '-i $inputPath -vcodec h264 -b:v 1M $outputPath';
    // await FFmpegKit.execute(command).then((session) async {
    //   final returnCode = await session.getReturnCode();
    //   if (ReturnCode.isSuccess(returnCode)) {
    //     debugPrint('Video compression completed successfully: $outputPath');
    //     result = true;
    //   } else {
    //     debugPrint('Video compression failed.');
    //   }
    // });
    //
    // return result;
     return false;
  }

  void getFilter(){
    FFmpegKit.executeAsync(
      'codecs',
          (session) async {
        final output = await session.getOutput();
        print('Available filters: $output');
      },
    );
  }

  String? _localFilePath, _fontPath;
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

  Future<String> getFontFilePath() async {
    final byteData = await rootBundle.load('assets/fonts/fontt.ttf');
    final file = File('${(await getTemporaryDirectory()).path}/my_custom_font.ttf');
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return file.path;
  }



  Future<String> buildFFmpegCommand() async{
    var scorePath = saveFilePath+"/foot_score.txt";


   // await encodeVideo(tempPath, dd.path);

   // return "";

      var youtubeStreamCommand = "ffmpeg -re -i $_localFilePath -c:a aac -s 2560x1440 -ab 128k -vcodec libx264 -pix_fmt yuv420p -maxrate 2048k -bufsize 2048k -framerate 30 -g 2 -strict experimental -f flv rtmp://a.rtmp.youtube.com/live2/6yk2-4yr4-j0j9-kjcg-93da";
    return youtubeStreamCommand;
    // var cmd = "ffmpeg -re -loop 1 -framerate 2 -i E:\Project\live_test\assets\test.mp4  -c:a aac -s 2560x1440 -ab 128k -vcodec libx264 -pix_fmt yuv420p -maxrate 2048k -bufsize 2048k -framerate 30 -g 2 -strict experimental -f flv rtmp://a.rtmp.youtube.com/live2/xxxxxxxxxxxxx";
    // return "-f android_camera -i 0 "
    //     "-vf \"drawtext=textfile='$scorePath':reload=1:fontcolor=white:fontsize=24:x=10:y=10\" "
    //     "-f flv rtmp://stream.dlive.tv/live";
  }

  void openVidoPage()async{
    // ByteData data = await rootBundle.load('assets/test.mp4');
    // List<int> bytes = data.buffer.asUint8List();
    //
    // // Save video to a temporary file
    // final directory = await Directory.systemTemp.createTemp();
    // String tempPath = '${directory.path}/temp_video.mp4';
    Navigator.push(context, MaterialPageRoute(builder: (_)=> VideoPlayPage(path: "E:\Project\live_test\assets\test.mp4")));
  }


  late VideoPlayerController _controller;
  bool isStreaming = false;
  int homeScore = 0;
  int awayScore = 0;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  String saveFilePath = "";

  // final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  //


  @override
  void initState() {
    super.initState();
    createTextFile();
    _loadAssetVideo();
    initCamera();
    _controller = VideoPlayerController.asset("assets/test.mp4");
    _controller.initialize().then((_){
      setState(() {});
    });
  }

  Future<void> _startStreaming() async {
    if (_localFilePath == null) return;

    var scorePath = "$saveFilePath/foot_score.txt";

    // Replace YOUR_STREAM_URL with the actual stream URL
    String streamUrl = "rtmp://a.rtmp.youtube.com/live2/6yk2-4yr4-j0j9-kjcg-93da";
    // var ffmpegCommand = "-re -i $_localFilePath -vf 'drawtext=textfile=$scorePath:fontcolor=white:reload=1:fontfile=$_fontPath:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2' -b:a 128k -f flv $streamUrl";
    var ffmpegCommand = "-f android_camera -i 0:1 -f flv $streamUrl";

    //String ffmpegCommand = '-re -i $_localFilePath -c:v libx264 -preset veryfast -maxrate 3000k -bufsize 6000k -c:a aac -ar 44100 -b:a 128k -f flv $streamUrl';

    FFmpegKit.execute(ffmpegCommand).then((session) async {
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
    final file = File('$saveFilePath/foot_score.txt');

    // Read the file
    String contents = await file.readAsString();
    print('File contents: $contents');
  }

  Future<void> updateTextFile(int hScore, int aSore)async{

    final file = File('$saveFilePath/foot_score.txt');
    await file.writeAsString('Score: $hScore - $aSore');
    homeScore = hScore;
    awayScore = aSore;
    setState(() {

    });


print("working");
    readTextFile();
  }





  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Camera Stream with Score Overlay'),
        actions: [IconButton(onPressed: (){
          getFilter();
        }, icon: Icon(Icons.abc))],
      ),
body: Row(
  children: <Widget>[
    Expanded(child:  _cameraController != null
? Padding(
  padding: const EdgeInsets.all(8.0),
  child: Stack(
    children: [
     // VideoPlayer(_controller),
    CameraPreview(_cameraController!),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
        child: Text("Home $homeScore - $awayScore Away",style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
      )
    ],
  ),
):const SizedBox()),
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
        ElevatedButton(onPressed: (){
          if(isStreaming){
            stopStreaming();
          }else{
          _startStreaming();}
        }, style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((_)=> Colors.deepPurple)
        ),child: Text(isStreaming?"Stop Streaming":"Start Streaming",style: TextStyle(color: Colors.white),)),

      ],
    )),

  ],
),
//       body: Center(child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           TextButton(onPressed: (){
//             _startStreaming();
//           }, child: Text("Start Streaming")),
//           TextButton(onPressed: (){
//             setTextOverlay();
//           }, child: Text("Open Video Page")),
//
//           CircleAvatar(child: IconButton(onPressed: (){
//             updateTextFile(homeScore++, awayScore);
//           }, icon: Icon(Icons.plus_one))),
// SizedBox(height: 14,),
//           CircleAvatar(child: IconButton(onPressed: (){
//             updateTextFile(homeScore, awayScore++);
//           }, icon: Icon(Icons.exposure_minus_1)))
//         ],
//       ),),
//
    );
  }


  void updateScoreFile(int homeScore, int awayScore) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/score.txt';
    final file = File(path);

    // Write the updated score to the file
    await file.writeAsString('Home: $homeScore Away: $awayScore');
    setState(() {

    });
  }

  @override
  void dispose() {
   // FFmpegKit.cancel();
    super.dispose();
  }
}
