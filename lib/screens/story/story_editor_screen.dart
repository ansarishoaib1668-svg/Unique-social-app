import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../services/cloudinary_service.dart';
import '../../services/story_service.dart';

class StoryEditorScreen extends StatefulWidget {
  final File file;
  final bool isVideo;

  const StoryEditorScreen({
    super.key,
    required this.file,
    required this.isVideo,
  });

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryTextItem {
  String text;
  Offset position;

  _StoryTextItem({
    required this.text,
    required this.position,
  });
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  VideoPlayerController? _video;

  bool _uploading = false;
  bool _drawing = false;
  String _mood = 'Chill Vibes';

  final List<Offset> _currentStroke = [];
  final List<List<Offset>> _strokes = [];
  final List<_StoryTextItem> _texts = [];

  @override
  void initState() {
    super.initState();

    if (widget.isVideo) {
      _video = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _video!.setLooping(true);
          _video!.play();
        });
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  Future<void> _addText() async {
    final controller = TextEditingController();

    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1821),
          title: const Text(
            'Add Text',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Write something...',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9B5CFF)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (text == null || text.isEmpty || !mounted) return;

    setState(() {
      _texts.add(
        _StoryTextItem(
          text: text,
          position: const Offset(80, 220),
        ),
      );
      _drawing = false;
    });
  }

  void _startDrawing(DragStartDetails details) {
    if (!_drawing) return;

    setState(() {
      _currentStroke
        ..clear()
        ..add(details.localPosition);
    });
  }

  void _updateDrawing(DragUpdateDetails details) {
    if (!_drawing) return;

    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _endDrawing(DragEndDetails details) {
    if (!_drawing || _currentStroke.isEmpty) return;

    setState(() {
      _strokes.add(List<Offset>.from(_currentStroke));
      _currentStroke.clear();
    });
  }

  void _clearDrawing() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
    });
  }

  Future<void> _shareMoment() async {
    if (_uploading) return;

    setState(() => _uploading = true);

    try {
      final url = await CloudinaryService.uploadFile(widget.file);

      await StoryService.createStory(
        mediaUrl: url,
        mediaType: widget.isVideo ? 'video' : 'image',
        mood: _mood,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your Moment is live for 24 hours'),
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not share Moment: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: widget.isVideo
                  ? (_video?.value.isInitialized == true
                      ? AspectRatio(
                          aspectRatio: _video!.value.aspectRatio,
                          child: VideoPlayer(_video!),
                        )
                      : const CircularProgressIndicator(
                          color: Colors.white,
                        ))
                  : Image.file(
                      widget.file,
                      fit: BoxFit.contain,
                    ),
            ),

            Positioned.fill(
              child: CustomPaint(
                painter: _StoryDrawingPainter(
                  strokes: [
                    ..._strokes,
                    if (_currentStroke.isNotEmpty)
                      List<Offset>.from(_currentStroke),
                  ],
                ),
              ),
            ),

            ..._texts.map(
              (item) => Positioned(
                left: item.position.dx,
                top: item.position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      item.position += details.delta;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Colors.transparent,
                    Color(0xE6000000),
                  ],
                  stops: [0, .45, 1],
                ),
              ),
            ),

            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),

                    IconButton(
                      tooltip: 'Draw',
                      onPressed: () {
                        setState(() {
                          _drawing = !_drawing;
                        });
                      },
                      icon: Icon(
                        Icons.brush_rounded,
                        color: _drawing
                            ? const Color(0xFFB26BFF)
                            : Colors.white,
                      ),
                    ),

                    if (_strokes.isNotEmpty)
                      IconButton(
                        tooltip: 'Clear Drawing',
                        onPressed: _clearDrawing,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),

                    IconButton(
                      tooltip: 'Text',
                      onPressed: _addText,
                      icon: const Icon(
                        Icons.text_fields_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                if (_drawing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Draw on your Moment',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                SizedBox(
                  height: 54,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _chip('Location', Icons.location_on_outlined),
                      _chip('Mention', Icons.alternate_email_rounded),
                      _chip('Poll', Icons.poll_outlined),
                      _chip('Questions', Icons.help_outline_rounded),
                      _chip('GIF', Icons.gif_box_outlined),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const SizedBox(width: 12),
                    const Text(
                      'Vibe',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _mood,
                          dropdownColor: const Color(0xFF1A1821),
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Chill Vibes',
                              child: Text('Chill Vibes'),
                            ),
                            DropdownMenuItem(
                              value: 'Trending',
                              child: Text('Trending'),
                            ),
                            DropdownMenuItem(
                              value: 'Creative',
                              child: Text('Creative'),
                            ),
                            DropdownMenuItem(
                              value: 'Fun',
                              child: Text('Fun'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _mood = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const SizedBox(width: 12),
                    _audience(
                      Icons.public,
                      'Your Moment',
                      true,
                    ),
                    _audience(
                      Icons.star_rounded,
                      'View Circle',
                      false,
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilledButton.icon(
                        onPressed:
                            _uploading ? null : _shareMoment,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF7C3AED),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        icon: _uploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_rounded,
                              ),
                        label: Text(
                          _uploading
                              ? 'Uploading'
                              : 'Share Moment',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),

            if (_drawing)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: _startDrawing,
                  onPanUpdate: _updateDrawing,
                  onPanEnd: _endDrawing,
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: () {},
        backgroundColor: const Color(0xAA211A2C),
        side: const BorderSide(
          color: Color(0xFF7C3AED),
        ),
        avatar: Icon(
          icon,
          color: const Color(0xFFB26BFF),
          size: 17,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _audience(
    IconData icon,
    String label,
    bool selected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7C3AED)
              : const Color(0x551A1821),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryDrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  const _StoryDrawingPainter({
    required this.strokes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB26BFF)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      if (stroke.length == 1) {
        canvas.drawCircle(
          stroke.first,
          2.5,
          paint,
        );
        continue;
      }

      final path = Path()
        ..moveTo(
          stroke.first.dx,
          stroke.first.dy,
        );

      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(
          stroke[i].dx,
          stroke[i].dy,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(
    covariant _StoryDrawingPainter oldDelegate,
  ) {
    return true;
  }
}
