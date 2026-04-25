import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';

class SpotifyService {
  final String baseUrl = 'https://api.spotify.com/v1';
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Search for tracks on Spotify
  Future<List<dynamic>> searchTracks(String accessToken, String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query&type=track'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['tracks']['items'];
    } else {
      throw Exception('Failed to fetch tracks');
    }
  }

  Future<void> playPreview(String previewUrl) async {
    try {
      await _audioPlayer.setUrl(previewUrl);
      await _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.play();
    } catch (e) {
      print('Error playing preview: $e');
    }
  }

  void stopPreview() {
    _audioPlayer.stop();
  }
}
