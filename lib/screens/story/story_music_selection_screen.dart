import 'package:flutter/material.dart';

class StoryMusicSelectionScreen extends StatefulWidget {
  const StoryMusicSelectionScreen({super.key});

  @override
  State<StoryMusicSelectionScreen> createState() =>
      _StoryMusicSelectionScreenState();
}

class _StoryMusicSelectionScreenState
    extends State<StoryMusicSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _music = [
    {'title': 'Golden Hour', 'artist': 'Viewsta Sounds'},
    {'title': 'Midnight Drive', 'artist': 'Viewsta Sounds'},
    {'title': 'Chill Waves', 'artist': 'Viewsta Sounds'},
    {'title': 'Dreamscape', 'artist': 'Viewsta Sounds'},
    {'title': 'Summer Vibe', 'artist': 'Viewsta Sounds'},
  ];

  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _music.where((music) {
      final query = _search.toLowerCase();
      return music['title']!.toLowerCase().contains(query) ||
          music['artist']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F12),
        foregroundColor: Colors.white,
        title: const Text(
          'Add Music',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _search = value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search music...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final music = filtered[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7C3AED),
                          Color(0xFF38BDF8),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    music['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    music['artist']!,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    Navigator.pop(context, music);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
