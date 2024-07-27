import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/song_clip.dart';

class SunoApi {
  static const String defaultModel =
      "chirp-v3-5"; // Changed from private to public

  static const String _baseUrl = 'https://studio-api.suno.ai';
  static const String _clerkBaseUrl = 'https://clerk.suno.com';

  String? _currentToken;
  String? _sessionId;
  String? _cookie;
  Future<void> init(String cookie) async {
    await _getAuthToken(cookie);
    _cookie = cookie;
  }

  Future<void> _getAuthToken(String cookie) async {
    final response = await http.get(
      Uri.parse('$_clerkBaseUrl/v1/client?_clerk_js_version=4.73.2'),
      headers: {
        'User-Agent': 'Mozilla/5.0',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _sessionId = data['response']['last_active_session_id'];
      final String token = data['response']['sessions'].firstWhere(
          (session) => session['id'] == _sessionId)['last_active_token']['jwt'];
      _currentToken = token;
    } else {
      throw Exception('Failed to get session id');
    }
  }

  Future<List> generateSong(String prompt, String tags, String model) async {
    await _getAuthToken(_cookie!);

    final response = await http.post(
      Uri.parse('$_baseUrl/api/generate/v2/'),
      headers: {
        'Authorization': 'Bearer $_currentToken',
      },
      body: jsonEncode({
        "gpt_description_prompt": "$prompt with $tags",
        "prompt": "",
        "tags": tags,
        'mv': model,
        'make_instrumental': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<SongClip> clips = (data['clips'] as List)
          .map((clip) => SongClip.fromJson(clip))
          .toList();

      // Check if audio URL is available and return data
      List audioData = await _checkForAudioUrl(clips);
      return audioData;
    } else {
      throw Exception('Failed to generate song. Response: ${response.body}');
    }
  }

  Future<List> _checkForAudioUrl(List<SongClip> clips) async {
    List<String> ids = clips.map((clip) => clip.id).toList();
    String joinedIds = ids.join(',');

    while (true) {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/feed/?ids=$joinedIds'),
        headers: {
          'Authorization': 'Bearer $_currentToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        bool audioUrlFound = false;
        List<dynamic> autoData = [];
        for (var item in data) {
          if (item['audio_url'] != null &&
              item['audio_url'].isNotEmpty &&
              item['title'].isNotEmpty) {
            audioUrlFound = true;
            autoData.add(item);
          }
        }

        if (audioUrlFound) {
          print('song found : $data');
          return autoData;
        } else {
          print('Audio URL not found, retrying in 5 seconds...');
          await Future.delayed(Duration(seconds: 5));
        }
      } else {
        print('Failed to check audio URL. Response: ${response.body}');
        await Future.delayed(Duration(seconds: 5));
      }
    }
  }
}
