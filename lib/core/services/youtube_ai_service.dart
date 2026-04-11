import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class YoutubeAiService {
  static const String _groqApiKeyFromDefine =
      String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  static const String _youtubeApiKeyFromDefine =
      String.fromEnvironment('YOUTUBE_API_KEY', defaultValue: '');

  static String get _groqApiKey =>
      (dotenv.env['GROQ_API_KEY'] ?? _groqApiKeyFromDefine).trim();
  static String get _youtubeApiKey =>
      (dotenv.env['YOUTUBE_API_KEY'] ?? _youtubeApiKeyFromDefine).trim();

  static Future<List<Map<String, dynamic>>> searchVideoWithAi(String userInput) async {
    // 1. Lempar input suara user ke LLM (Mistral via Groq) untuk NLU (Natural Language Understanding)
    String searchKeyword = userInput.trim();
    try {
      final extracted = await _extractKeywordWithMistral(userInput);
      if (extracted.trim().isNotEmpty) {
        searchKeyword = extracted.trim();
      }
      debugPrint('[YoutubeAiService] Keyword dari Mistral: $searchKeyword');
    } catch (e) {
      debugPrint('[YoutubeAiService] Mistral gagal, fallback ke input asli: $e');
    }

    if (searchKeyword.isEmpty) return [];

    // 2. Gunakan keyword dari LLM untuk mencari video di YouTube
    return await _fetchYoutubeVideos(searchKeyword);
  }

  static Future<String> _extractKeywordWithMistral(String input) async {
    if (_groqApiKey.isEmpty) {
      throw Exception('GROQ_API_KEY belum di-set');
    }
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_groqApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "mixtral-8x7b-32768", // Model Mistral di Groq
        "messages": [
          {
            "role": "system",
            "content": "Kamu adalah asisten pencari materi edukasi. Tugasmu HANYA mengekstrak kata kunci pencarian YouTube yang paling optimal dari ucapan pengguna. Jangan berikan penjelasan, salam, atau tanda kutip. Berikan kata kuncinya saja."
          },
          {
            "role": "user",
            "content": input
          }
        ],
        "temperature": 0.3, // Dibuat rendah agar hasilnya presisi & tidak halusinasi
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else {
      throw Exception('Gagal menghubungi Mistral API');
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchYoutubeVideos(String keyword) async {
    if (_youtubeApiKey.isEmpty) {
      throw Exception('YOUTUBE_API_KEY belum di-set');
    }
    final url = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'maxResults': '5',
      'q': keyword,
      'type': 'video',
      'key': _youtubeApiKey,
    });
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'] ?? [];
      
      return items.map((video) {
        final snippet = (video['snippet'] as Map?) ?? const {};
        final thumbnails = (snippet['thumbnails'] as Map?) ?? const {};
        String readThumb(String key) {
          final value = thumbnails[key];
          if (value is Map) {
            final url = value['url'];
            if (url is String) return url;
          }
          return '';
        }
        final thumbUrl = readThumb('high');
        final fallbackUrl =
            thumbUrl.isNotEmpty ? thumbUrl : (readThumb('medium'));
        final finalUrl =
            fallbackUrl.isNotEmpty ? fallbackUrl : readThumb('default');
        return {
          'videoId': video['id']['videoId'],
          'title': snippet['title'],
          'channelTitle': snippet['channelTitle'],
          'thumbnailUrl': finalUrl,
        };
      }).toList();
    } else {
      debugPrint('[YoutubeAiService] YouTube API error '
          'status=${response.statusCode} body=${response.body}');
      throw Exception('Gagal menghubungi YouTube API');
    }
  }
}
