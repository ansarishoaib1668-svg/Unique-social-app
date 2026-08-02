import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late int currentIndex;
  VideoPlayerController? videoController;
  bool paused = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    loadStory();
  }

  Future<void> loadStory() async {
    videoController?.dispose();

    final story = widget.stories[currentIndex];

    if (story['mediaType'] == 'video') {
      videoController =
          VideoPlayerController.networkUrl(Uri.parse(story['mediaUrl']));

      await videoController!.initialize();
      videoController!.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void nextStory() {
    if (currentIndex < widget.stories.length - 1) {
      currentIndex++;
      loadStory();
    } else {
      Navigator.pop(context);
    }
  }

  void previousStory() {
    if (currentIndex > 0) {
      currentIndex--;
      loadStory();
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPress: () {
          setState(() {
            paused = true;
            videoController?.pause();
          });
        },
        onLongPressUp: () {
          setState(() {
            paused = false;
            videoController?.play();
          });
        },
        onTapUp: (details) {
          if (details.localPosition.dx <
              MediaQuery.of(context).size.width / 2) {
            previousStory();
          } else {
            nextStory();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (story['mediaType'] == 'image')
              Image.network(
                story['mediaUrl'],
                fit: BoxFit.cover,
              )
            else if (videoController != null &&
                videoController!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoController!.value.size.width,
                  height: videoController!.value.size.height,
                  child: VideoPlayer(videoController!),
                ),
              ),

            SafeArea(
              child: LinearProgressIndicator(
                value: null,
                backgroundColor: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
