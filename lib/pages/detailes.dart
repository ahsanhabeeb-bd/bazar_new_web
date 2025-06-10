import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late VideoPlayerController _videoController1;
  late VideoPlayerController _videoController2;
  bool _isVideo1Initialized = false;
  bool _isVideo2Initialized = false;

  @override
  void initState() {
    super.initState();

    _videoController1 =
        VideoPlayerController.asset('assets/audio/video1.mp4')
          ..setLooping(true)
          ..initialize().then((_) {
            setState(() {
              _isVideo1Initialized = true;
            });
          });

    _videoController2 =
        VideoPlayerController.asset('assets/audio/video2.mp4')
          ..setLooping(true)
          ..initialize().then((_) {
            setState(() {
              _isVideo2Initialized = true;
            });
          });
  }

  @override
  void dispose() {
    _videoController1.dispose();
    _videoController2.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer(
    VideoPlayerController controller,
    bool isInitialized,
  ) {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 First Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/siddikpic2.jpg',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 First Profile Text
            const Text(
              'Md Abu Bakkar Siddik\nBusiness Consultant\n\nManaging Director And\nFounder & CEO,\nExsef International Company Limited',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // 🔹 First Video
            _buildVideoPlayer(_videoController1, _isVideo1Initialized),
            const SizedBox(height: 40),

            // 🔹 Second Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/Untitled-1.JPG',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Second Profile Text
            const Text(
              'MD ABU AL SIFAT KHAN\nBusiness Consultant\n\nManaging Director And\nFounder & CEO,\nOBOEF BAZAR',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // 🔹 Second Video
            _buildVideoPlayer(_videoController2, _isVideo2Initialized),
          ],
        ),
      ),
    );
  }
}
