import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class StoryPickedMedia {
  final File file;
  final bool isVideo;
  const StoryPickedMedia({required this.file, required this.isVideo});
}

class StoryMediaPickerScreen extends StatefulWidget {
  const StoryMediaPickerScreen({super.key});

  @override
  State<StoryMediaPickerScreen> createState() => _StoryMediaPickerScreenState();
}

class _StoryMediaPickerScreenState extends State<StoryMediaPickerScreen> {
  final List<AssetEntity> _assets = [];
  AssetPathEntity? _album;
  String _filter = 'Photos';
  bool _loading = true;
  String _albumName = 'Recents';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
    );
    if (paths.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    _album = paths.first;
    _albumName = _album!.name;
    await _refresh();
  }

  Future<void> _refresh() async {
    if (_album == null) return;
    final type = _filter == 'Photos'
        ? RequestType.image
        : _filter == 'Videos'
            ? RequestType.video
            : RequestType.common;
    final paths = await PhotoManager.getAssetPathList(type: type, onlyAll: true);
    if (paths.isNotEmpty) _album = paths.first;
    final items = await _album!.getAssetListPaged(page: 0, size: 120);
    if (!mounted) return;
    setState(() {
      _assets
        ..clear()
        ..addAll(items);
      _loading = false;
    });
  }

  Future<void> _select(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null || !mounted) return;
    Navigator.pop(
      context,
      StoryPickedMedia(file: file, isVideo: asset.type == AssetType.video),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0A10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0A10),
        foregroundColor: Colors.white,
        title: Text(_albumName, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
            child: Row(
              children: [
                _filterButton('Photos'),
                _filterButton('Videos'),
                _filterButton('Albums'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF9B5CFF)))
                : _assets.isEmpty
                    ? const Center(
                        child: Text('No media found', style: TextStyle(color: Colors.white54)),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(3),
                        itemCount: _assets.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                        ),
                        itemBuilder: (_, index) => _tile(_assets[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String title) {
    final active = _filter == title;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (title == 'Albums') return;
          setState(() {
            _filter = title;
            _loading = true;
          });
          await _refresh();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF7C3AED) : const Color(0xFF1A1821),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _tile(AssetEntity asset) {
    return GestureDetector(
      onTap: () => _select(asset),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetEntityImage(
            asset,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(400),
            fit: BoxFit.cover,
          ),
          if (asset.type == AssetType.video)
            Positioned(
              right: 6,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  child: Text(
                    '${asset.videoDuration.inMinutes}:${(asset.videoDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
