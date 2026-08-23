import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class EditPhotoScreen extends StatefulWidget {
  final File imageFile;

  const EditPhotoScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  late Uint8List _originalBytes;
  Uint8List? _editedBytes;

  int _rotation = 0;
  bool _filterEnabled = false;
  bool _cropped = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();

    if (!mounted) return;

    setState(() {
      _originalBytes = bytes;
      _editedBytes = bytes;
    });
  }

  Future<void> _rotate() async {
    final bytes = _editedBytes ?? _originalBytes;
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return;

    final rotated = img.copyRotate(
      decoded,
      angle: 90,
    );

    final result = Uint8List.fromList(
      img.encodeJpg(rotated, quality: 95),
    );

    if (!mounted) return;

    setState(() {
      _editedBytes = result;
      _rotation = (_rotation + 90) % 360;
    });
  }

  Future<void> _cropSquare() async {
    final bytes = _editedBytes ?? _originalBytes;
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return;

    final size = decoded.width < decoded.height
        ? decoded.width
        : decoded.height;

    final x = (decoded.width - size) ~/ 2;
    final y = (decoded.height - size) ~/ 2;

    final cropped = img.copyCrop(
      decoded,
      x: x,
      y: y,
      width: size,
      height: size,
    );

    final result = Uint8List.fromList(
      img.encodeJpg(cropped, quality: 95),
    );

    if (!mounted) return;

    setState(() {
      _editedBytes = result;
      _cropped = true;
    });
  }

  Future<void> _toggleFilter() async {
    final bytes = _editedBytes ?? _originalBytes;
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return;

    final filtered = _filterEnabled
        ? img.decodeImage(_originalBytes)
        : img.grayscale(decoded);

    if (filtered == null) return;

    final result = Uint8List.fromList(
      img.encodeJpg(filtered, quality: 95),
    );

    if (!mounted) return;

    setState(() {
      _editedBytes = result;
      _filterEnabled = !_filterEnabled;
    });
  }

  Future<void> _done() async {
    final bytes = _editedBytes ?? _originalBytes;

    final tempDir = Directory.systemTemp;
    final file = File(
      '${tempDir.path}/viewsta_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await file.writeAsBytes(bytes);

    if (!mounted) return;

    Navigator.pop(context, file);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _editedBytes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Edit Photo',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: bytes == null ? null : _done,
            child: const Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: bytes == null
                  ? const CircularProgressIndicator(
                      color: Color(0xFF7C3AED),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(18),
                      child: InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 4,
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE4E4E7),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Tool(
                  icon: Icons.crop,
                  label: _cropped ? 'Cropped' : 'Crop',
                  onTap: _cropSquare,
                ),
                _Tool(
                  icon: Icons.rotate_right,
                  label: 'Rotate',
                  onTap: _rotate,
                ),
                _Tool(
                  icon: Icons.auto_awesome,
                  label: _filterEnabled ? 'Original' : 'Filter',
                  onTap: _toggleFilter,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Tool({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF7C3AED),
              size: 28,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
