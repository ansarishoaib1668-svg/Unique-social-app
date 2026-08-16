import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/music_service.dart';

class StoryMusicSelectionScreen extends StatefulWidget {
  const StoryMusicSelectionScreen({super.key});

  @override
  State<StoryMusicSelectionScreen> createState() =>
      _StoryMusicSelectionScreenState();
}

class _StoryMusicSelectionScreenState extends State<StoryMusicSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _player = AudioPlayer();

  List<Map<String, String>> _music = [];
  Map<String, String>? _playing;

  bool _loading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _player.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() => _music = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), _searchMusic);
  }

  Future<void> _searchMusic() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) return;

    setState(() => _loading = true);

    try {
      final tracks = await MusicService.search(query);

      if (!mounted) return;

      setState(() {
        _music = tracks.map((track) => track.toMap()).toList();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not search music: $e')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _togglePreview(Map<String, String> music) async {
    try {
      if (_playing == music) {
        await _player.stop();

        if (mounted) {
          setState(() => _playing = null);
        }

        return;
      }

      await _player.setUrl(music['previewUrl']!);
      await _player.play();

      if (mounted) {
        setState(() => _playing = music);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preview unavailable')));
    }
  }

  Future<void> _selectMusic(Map<String, String> music) async {
    await _player.stop();

    if (!mounted) return;

    Navigator.pop(context, music);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F12),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Music',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _searchMusic(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search song or artist...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                ),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF9B5CFF),
                          ),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A1A22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          if (_music.isEmpty && !_loading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 55,
                      color: Color(0xFF7C3AED),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Search your favourite song',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Search by song name or artist',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _music.length,
              itemBuilder: (context, index) {
                final music = _music[index];
                final isPlaying = _playing == music;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? const Color(0xFF211A2C)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: music['artwork']!.isNotEmpty
                          ? Image.network(
                              music['artwork']!,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _musicIcon(),
                            )
                          : _musicIcon(),
                    ),
                    title: Text(
                      music['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      music['artist']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _togglePreview(music),
                          icon: Icon(
                            isPlaying
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _selectMusic(music),
                          icon: const Icon(
                            Icons.add_circle_rounded,
                            color: Color(0xFF9B5CFF),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _musicIcon() {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
        ),
      ),
      child: const Icon(Icons.music_note_rounded, color: Colors.white),
    );
  }
}
