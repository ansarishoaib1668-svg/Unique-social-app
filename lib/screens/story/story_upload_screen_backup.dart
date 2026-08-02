import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';
import '../../services/story_service.dart';

class StoryUploadScreen extends StatefulWidget {
  const StoryUploadScreen({super.key});

  @override
  State<StoryUploadScreen> createState() => _StoryUploadScreenState();
}

class _StoryUploadScreenState extends State<StoryUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _uploading = false;


  Future<void> _pickMedia(ImageSource source) async {
    final XFile? file = await _picker.pickMedia();

    if (file == null) return;

    setState(() {
      _uploading = true;
    });

    try {
      final mediaFile = File(file.path);

      final url = await CloudinaryService.uploadFile(mediaFile);

      final mediaType = file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov')
          ? 'video'
          : 'image';

      await StoryService.createStory(
        mediaUrl: url,
        mediaType: mediaType,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story uploaded successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Story'),
      ),
      body: Center(
        child: _uploading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 90,
                      color: Colors.deepPurple,
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Create Your Story',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _pickMedia(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _pickMedia(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
