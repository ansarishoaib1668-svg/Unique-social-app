import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String artworkUrl;
  final String previewUrl;
  final String provider;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.previewUrl,
    required this.provider,
  });

  factory MusicTrack.fromJamendo(Map<String, dynamic> data) {
    return MusicTrack(
      id: '${data['id'] ?? ''}',
      title: '${data['name'] ?? 'Unknown Song'}',
      artist: '${data['artist_name'] ?? 'Unknown Artist'}',
      artworkUrl: '${data['album_image'] ?? data['image'] ?? ''}',
      previewUrl: '${data['audio'] ?? ''}',
      provider: 'jamendo',
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artwork': artworkUrl,
      'previewUrl': previewUrl,
      'provider': provider,
    };
  }
}

class MusicService {
  static const String _clientId = 'ceaed7cd';

  static Future<List<MusicTrack>> search(String query) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return [];
    }

    final uri = Uri.https('api.jamendo.com', '/v3.0/tracks/', {
      'client_id': _clientId,
      'format': 'json',
      'limit': '30',
      'search': cleanQuery,
      'audioformat': 'mp32',
      'imagesize': '300',
    });

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Jamendo music search failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(MusicTrack.fromJamendo)
        .where((track) => track.previewUrl.isNotEmpty)
        .toList();
  }
}
