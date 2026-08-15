import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'story_editor_screen.dart';
import 'story_media_picker_screen.dart';

class StoryCameraScreen extends StatefulWidget {
  const StoryCameraScreen({super.key});

  @override
  State<StoryCameraScreen> createState() => _StoryCameraScreenState();
}

class _StoryCameraScreenState extends State<StoryCameraScreen> {
  CameraController? _controller;
  bool _loading = true;
  bool _recording = false;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      _cameraIndex = cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_cameraIndex < 0) _cameraIndex = 0;
      final controller = CameraController(
        cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _recording) return;
    try {
      final file = await c.takePicture();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoryEditorScreen(file: File(file.path), isVideo: false),
        ),
      );
    } catch (_) {}
  }

  Future<void> _toggleVideo() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      if (_recording) {
        final file = await c.stopVideoRecording();
        if (!mounted) return;
        setState(() => _recording = false);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryEditorScreen(file: File(file.path), isVideo: true),
          ),
        );
      } else {
        await c.startVideoRecording();
        if (mounted) setState(() => _recording = true);
      }
    } catch (_) {
      if (mounted) setState(() => _recording = false);
    }
  }

  Future<void> _switchCamera() async {
    final cameras = await availableCameras();
    if (cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    final next = CameraController(
      cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller?.dispose();
    try {
      await next.initialize();
      if (!mounted) {
        await next.dispose();
        return;
      }
      setState(() => _controller = next);
    } catch (_) {
      await next.dispose();
    }
  }

  Future<void> _openMediaPicker() async {
    final file = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StoryMediaPickerScreen()),
    );
    if (!mounted || file == null) return;
    final result = file as StoryPickedMedia;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryEditorScreen(
          file: result.file,
          isVideo: result.isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -350) {
            _openMediaPicker();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              CameraPreview(_controller!)
            else
              const ColoredBox(color: Colors.black),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x88000000), Colors.transparent, Color(0xDD000000)],
                  stops: [0, .45, 1],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      ),
                      const Spacer(),
                      const Text(
                        'Create Moment',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _switchCamera,
                        icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_loading)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    Column(
                      children: [
                        const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 34),
                        const Text(
                          'SWIPE UP FOR PHOTOS & VIDEOS',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .7),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _modeButton('POST'),
                            _modeButton('REEL'),
                            _modeButton(_recording ? 'STOP' : 'MOMENT', active: true),
                            _modeButton('LIVE'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: _capturePhoto,
                          onLongPress: _toggleVideo,
                          onLongPressUp: _toggleVideo,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: _recording ? 76 : 68,
                            height: _recording ? 76 : 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _recording ? const Color(0xFFEF4444) : Colors.white,
                              border: Border.all(color: Colors.white70, width: 4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String label, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFFB26BFF) : Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
