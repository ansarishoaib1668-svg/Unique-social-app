import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';
import '../../services/firestore_service.dart';
import 'edit_photo_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const purple = Color(0xFF7C3AED);

  final captionController = TextEditingController();
  final service = FirestoreService();

  final List<File> selectedFiles = [];

  bool uploading = false;
  bool showAdvanced = false;
  bool allowComments = true;
  bool allowDownloads = true;
  bool showViewCount = true;

  String location = '';
  String music = '';
  String audience = 'Everyone';

  int currentStep = 0;

  Future<void> pickPhoto() async {
    final picker = ImagePicker();

    final files = await picker.pickMultiImage(imageQuality: 90);

    if (files.isEmpty || !mounted) return;

    for (final file in files.take(10)) {
      final edited = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (_) => EditPhotoScreen(imageFile: File(file.path)),
        ),
      );

      if (edited != null && mounted) {
        setState(() {
          selectedFiles.add(edited);
        });
      }
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (file == null || !mounted) return;

    final edited = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPhotoScreen(imageFile: File(file.path)),
      ),
    );

    if (edited != null && mounted) {
      setState(() {
        selectedFiles.add(edited);
      });
    }
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();

    final file = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );

    if (file == null || !mounted) return;

    setState(() {
      selectedFiles.add(File(file.path));
    });

    _message('Video added to your View.');
  }

  void removeMedia(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  Future<void> chooseLocation() async {
    final controller = TextEditingController(text: location);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Location'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Mumbai, India',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result != null && mounted) {
      setState(() {
        location = result;
      });
    }
  }

  Future<void> chooseMusic() async {
    final choices = [
      'No Music',
      'Original View',
      'Chill Vibes',
      'Trending Beat',
      'Creative Flow',
    ];

    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: choices
              .map(
                (item) => ListTile(
                  leading: Icon(
                    item == 'No Music'
                        ? Icons.music_off_rounded
                        : Icons.music_note_rounded,
                    color: purple,
                  ),
                  title: Text(item),
                  trailing: music == item
                      ? const Icon(Icons.check_rounded, color: purple)
                      : null,
                  onTap: () => Navigator.pop(context, item),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        music = result == 'No Music' ? '' : result;
      });
    }
  }

  Future<void> chooseAudience() async {
    final choices = ['Everyone', 'Followers', 'Close Friends'];

    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: choices
              .map(
                (item) => ListTile(
                  leading: Icon(
                    item == 'Everyone'
                        ? Icons.public_rounded
                        : item == 'Followers'
                        ? Icons.people_outline_rounded
                        : Icons.star_outline_rounded,
                    color: purple,
                  ),
                  title: Text(item),
                  trailing: audience == item
                      ? const Icon(Icons.check_rounded, color: purple)
                      : null,
                  onTap: () => Navigator.pop(context, item),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        audience = result;
      });
    }
  }

  Future<void> nextStep() async {
    if (selectedFiles.isEmpty) {
      _message('Add at least one photo or video first.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      currentStep = 1;
    });
  }

  Future<void> publish() async {
    if (selectedFiles.isEmpty) {
      _message('Add media first.');
      return;
    }

    setState(() {
      uploading = true;
    });

    try {
      final urls = <String>[];

      for (final file in selectedFiles) {
        final url = await CloudinaryService.uploadFile(file);
        urls.add(url);
      }

      final first = urls.first;

      final isVideo = _isVideoFile(selectedFiles.first);

      await service.createPost(
        text: captionController.text.trim(),
        imageUrl: isVideo ? '' : first,
        videoUrl: isVideo ? first : '',
        location: location,
        music: music,
        audience: audience,
        mediaUrls: urls,
        allowComments: allowComments,
        allowDownloads: allowDownloads,
        showViewCount: showViewCount,
      );

      if (!mounted) return;

      setState(() {
        uploading = false;
      });

      await _showSuccess();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        uploading = false;
      });

      _message('Could not publish your View.');
    }
  }

  Future<void> saveDraft() async {
    if (selectedFiles.isEmpty) {
      _message('Add media before saving a draft.');
      return;
    }

    _message('Draft saved on this device.');
  }

  Future<void> _showSuccess() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.check_circle_rounded, color: purple, size: 64),
        title: const Text(
          'Post Ready!',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your View has been published successfully.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: purple),
            child: const Text('Share Now'),
          ),
        ],
      ),
    );
  }

  bool _isVideoFile(File file) {
    final path = file.path.toLowerCase();

    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.avi') ||
        path.endsWith('.mkv') ||
        path.endsWith('.webm');
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: uploading
          ? const _UploadingView()
          : currentStep == 0
          ? _editor()
          : _preview(),
    );
  }

  Widget _editor() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 28,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: purple,
                            size: 25,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Create Post',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: saveDraft,
                        icon: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 17,
                        ),
                        label: const Text('Drafts'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: purple,
                          side: const BorderSide(color: Color(0xFFDCCBFF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    'Share your world, your view.',
                    style: TextStyle(color: Color(0xFF71717A), fontSize: 15),
                  ),

                  const SizedBox(height: 22),

                  _stepIndicator(),

                  const SizedBox(height: 24),

                  _mediaSection(),

                  const SizedBox(height: 18),

                  _captionBox(),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _smallChip(Icons.tag_rounded, 'Hashtags'),
                      const SizedBox(width: 8),
                      _smallChip(Icons.alternate_email_rounded, 'Mention'),
                      const SizedBox(width: 8),
                      _smallChip(
                        Icons.sentiment_satisfied_alt_rounded,
                        'Feeling',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _featureCard(
                          Icons.location_on_rounded,
                          'Location',
                          location.isEmpty ? 'Add place' : location,
                          purple,
                          chooseLocation,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _featureCard(
                          Icons.music_note_rounded,
                          'Music',
                          music.isEmpty ? 'Add song' : music,
                          const Color(0xFFE83E8C),
                          chooseMusic,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _featureCard(
                          Icons.groups_rounded,
                          'Audience',
                          audience,
                          const Color(0xFF2589D9),
                          chooseAudience,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _featureCard(
                          Icons.auto_awesome_rounded,
                          'View Enhance',
                          'AI powered',
                          const Color(0xFFF59E0B),
                          () {
                            if (selectedFiles.isEmpty) {
                              _message('Add a photo first.');
                              return;
                            }

                            Navigator.push<File>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditPhotoScreen(
                                  imageFile: selectedFiles.first,
                                ),
                              ),
                            ).then((edited) {
                              if (edited != null && mounted) {
                                setState(() {
                                  selectedFiles[0] = edited;
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _audienceSummary(),

                  const SizedBox(height: 14),

                  _advancedHeader(),

                  if (showAdvanced) _advancedOptions(),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator() {
    return Row(
      children: [
        _stepCircle('1', 'Create', true),
        Expanded(child: Container(height: 2, color: const Color(0xFFE5E7EB))),
        _stepCircle('2', 'Preview', false),
        Expanded(child: Container(height: 2, color: const Color(0xFFE5E7EB))),
        _stepCircle('3', 'Share', false),
      ],
    );
  }

  Widget _stepCircle(String number, String label, bool active) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? purple : const Color(0xFFD1D5DB),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? purple : const Color(0xFF71717A),
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F0FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: purple),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 118,
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: Column(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF71717A), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _audienceSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE7E7E7)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_alt_rounded, color: purple),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Audience', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text(
                  'Your post will be visible to everyone.',
                  style: TextStyle(color: Color(0xFF71717A), fontSize: 11),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: chooseAudience,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    audience,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _preview() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your View is ready',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Check everything before sharing.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 18),
            _previewMedia(),
            const SizedBox(height: 18),
            if (captionController.text.trim().isNotEmpty)
              _previewCard(
                Icons.edit_note_rounded,
                'Caption',
                captionController.text.trim(),
              ),
            if (location.isNotEmpty)
              _previewCard(Icons.location_on_outlined, 'Location', location),
            if (music.isNotEmpty)
              _previewCard(Icons.music_note_rounded, 'Music', music),
            _previewCard(Icons.people_outline_rounded, 'Audience', audience),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        currentStep = 0;
                      });
                    },
                    child: const Text('Back to Edit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: publish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Share Now',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: saveDraft,
                icon: const Icon(Icons.bookmark_border_rounded),
                label: const Text('Save Draft'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewMedia() {
    return SizedBox(
      height: 330,
      child: PageView.builder(
        itemCount: selectedFiles.length,
        itemBuilder: (context, index) {
          final file = selectedFiles[index];

          if (_isVideoFile(file)) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.file(file, fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _captionBox() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: TextField(
        controller: captionController,
        maxLines: 5,
        minLines: 4,
        maxLength: 2200,
        decoration: const InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12, top: 13),
            child: Icon(Icons.edit_rounded, color: purple, size: 20),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 48),
          hintText: 'Write a caption...',
          hintStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
          labelText: "What's on your mind?",
          labelStyle: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(8, 15, 14, 8),
          counterStyle: TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ),
    );
  }

  Widget _mediaSection() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.photo_library_outlined, color: purple, size: 22),
            const SizedBox(width: 8),
            Text(
              'Selected Media (${selectedFiles.length}/10)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: selectedFiles.length >= 10 ? null : pickPhoto,
              child: const Text('Select More'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...selectedFiles.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;

                return Container(
                  width: 145,
                  margin: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _isVideoFile(file)
                              ? Container(
                                  color: Colors.black,
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_fill_rounded,
                                      color: Colors.white,
                                      size: 42,
                                    ),
                                  ),
                                )
                              : Image.file(file, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 7,
                        right: 7,
                        child: GestureDetector(
                          onTap: () => removeMedia(index),
                          child: Container(
                            width: 27,
                            height: 27,
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              InkWell(
                onTap: selectedFiles.length >= 10 ? null : pickPhoto,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 135,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFB99AFF),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: purple, size: 38),
                      SizedBox(height: 5),
                      Text(
                        'Add Media',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (selectedFiles.length > 1)
          const Text(
            'Hold & drag to reorder',
            style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
          )
        else
          const Text(
            'Add photos or videos to your View',
            style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
          ),
      ],
    );
  }

  Widget _advancedHeader() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showAdvanced = !showAdvanced;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.settings_outlined, color: purple),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'More Options',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
            Icon(
              showAdvanced
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _advancedOptions() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _setting(
            Icons.comment_outlined,
            'Allow comments',
            allowComments,
            (value) => setState(() {
              allowComments = value;
            }),
          ),
          _setting(
            Icons.download_outlined,
            'Allow downloads',
            allowDownloads,
            (value) => setState(() {
              allowDownloads = value;
            }),
          ),
          _setting(
            Icons.visibility_outlined,
            'Show View count',
            showViewCount,
            (value) => setState(() {
              showViewCount = value;
            }),
          ),
        ],
      ),
    );
  }

  Widget _setting(
    IconData icon,
    String text,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, size: 19, color: purple),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Switch(value: value, activeThumbColor: purple, onChanged: onChanged),
      ],
    );
  }

  Widget _previewCard(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: purple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadingView extends StatelessWidget {
  const _UploadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Color(0xFF7C3AED),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Publishing your View...',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text('Uploading your media ✨', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
