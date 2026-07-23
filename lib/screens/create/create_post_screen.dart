import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/firestore_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController textController = TextEditingController();
  final FirestoreService service = FirestoreService();

  File? selectedFile;
  String type = '';
  bool uploading = false;

  Future<void> pickMedia() async {
    final picker = ImagePicker();

    final file = await picker.pickMedia();

    if (file != null) {
      setState(() {
        selectedFile = File(file.path);

        if (file.path.endsWith('.mp4')) {
          type = 'mp4';
        } else {
          type = 'jpg';
        }
      });
    }
  }

  Future<void> uploadPost() async {
    if (selectedFile == null) return;

    setState(() {
      uploading = true;
    });

    String url = await service.uploadFile(
      selectedFile!,
      type,
    );

    await service.createPost(
      text: textController.text,
      imageUrl: type == 'jpg' ? url : '',
      videoUrl: type == 'mp4' ? url : '',
    );

    setState(() {
      uploading = false;
      selectedFile = null;
      textController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Post uploaded"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: "Write something...",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickMedia,
              child: const Text("Select Photo/Video"),
            ),

            if (selectedFile != null)
              Text(
                selectedFile!.path,
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: uploading ? null : uploadPost,
              child: uploading
                  ? const CircularProgressIndicator()
                  : const Text("Upload"),
            ),

          ],
        ),
      ),
    );
  }
}
