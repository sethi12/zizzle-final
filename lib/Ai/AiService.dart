import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ZizzleAIService {
  final String apiKey =
      "AIzaSyBV4_6rbpUVx90uYm6gdY0GNzM4nsNOJh8"; // Replace later with secure storage

  Future<String> chatWithAI(String message) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"] ??
          "No response";
    } else {
      throw Exception("Failed to chat with AI: ${response.body}");
    }
  }

  Future<List<String>> suggestCaptionsFromImage(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Suggest 5 catchy Instagram-style captions for this post."
                },
                {
                  "image": {"url": imageUrl}
                }
              ]
            }
          ]
        }),
      );

      debugPrint("📩 Caption API response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;

        if (candidates == null || candidates.isEmpty) return [];

        // ✅ Extract text safely
        return candidates
            .map((c) => c['content']?['parts']?[0]?['text']?.toString() ?? "")
            .where((text) => text.isNotEmpty) // ✅ this returns bool
            .toList();
      } else {
        debugPrint(
            "❌ Caption fetch failed: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e, st) {
      debugPrint("❌ Caption fetch failed: $e\n$st");
      return [];
    }
  }

  Future<String> generateImage(String prompt) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/imagegeneration:generate?key=$apiKey");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"prompt": prompt}),
    );

    print(
        "🔍 generateImage Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey("images") && data["images"].isNotEmpty) {
        final base64Str = data["images"][0]["data"];
        return base64Str;
      } else {
        throw Exception("No image field found in response");
      }
    } else {
      throw Exception(
          "Failed to generate image: ${response.statusCode} - ${response.body}");
    }
  }
}
