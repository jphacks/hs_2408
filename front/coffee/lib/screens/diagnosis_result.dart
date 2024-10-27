import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DiagnosisResult extends StatelessWidget {
  final List<Map<String, String>> coffeeResults;
  const DiagnosisResult({super.key, required this.coffeeResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('診断結果'),
      ),
      body: Center(
        child: coffeeResults.length >= 3
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('1位'),
                  // 一番上の画像
                  Image.network(
                    coffeeResults[0]["url"]!,
                    width: 200,
                    height: 200,
                  ),
                  const VideoApp(),
                  const SizedBox(height: 16), // 上下の間隔
                  // 二番目と三番目の画像を横に並べる
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2位
                      Column(
                        children: [
                          const Text('2位', textAlign: TextAlign.center),
                          const SizedBox(height: 8), // テキストと画像の間の間隔
                          Image.network(
                            coffeeResults[1]["url"]!,
                            width: 150,
                            height: 150,
                          ),
                        ],
                      ),
                      const SizedBox(width: 32), // 左右の間隔
                      // 3位
                      Column(
                        children: [
                          const Text('3位', textAlign: TextAlign.center),
                          const SizedBox(height: 8), // テキストと画像の間の間隔
                          Image.network(
                            coffeeResults[2]["url"]!,
                            width: 150,
                            height: 150,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : const Text('画像が3枚必要です'),
      ),
    );
  }
}

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
