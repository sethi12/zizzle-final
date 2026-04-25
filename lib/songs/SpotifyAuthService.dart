// import 'package:flutter_web_auth/flutter_web_auth.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SpotifyAuthService {
//   final String clientId = '079c1958d97b4d2cb0f880144339a9d2';
//   final String clientSecret = 'd55d226a4d914418a95f18262342d0d3';
//   final String redirectUri = 'zizzle://callback';
//
//   // Initiate Spotify OAuth2 login flow
//   Future<String> authenticateUser() async {
//     final String authUrl = 'https://accounts.spotify.com/authorize'
//         '?client_id=$clientId'
//         '&response_type=code'
//         '&redirect_uri=$redirectUri'
//         '&scope=user-read-private%20user-read-email%20user-library-read';
//
//     // Open the authorization URL
//     final result = await FlutterWebAuth.authenticate(
//       url: authUrl,
//       callbackUrlScheme: 'zizzle',
//     );
//
//     // Extract the authorization code
//     final code = Uri.parse(result).queryParameters['code'];
//
//     // Request access token
//     final accessToken = await _getAccessTokenFromAuthCode(code);
//     await _saveAccessToken(accessToken); // Save access token for persistence
//     return accessToken;
//   }
//
//   // Exchange authorization code for access token
//   Future<String> _getAccessTokenFromAuthCode(String? code) async {
//     final response = await http.post(
//       Uri.parse('https://accounts.spotify.com/api/token'),
//       headers: {
//         'Authorization':
//             'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//       body: {
//         'grant_type': 'authorization_code',
//         'code': code!,
//         'redirect_uri': redirectUri,
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final tokenData = jsonDecode(response.body);
//       return tokenData['access_token'];
//     } else {
//       throw Exception('Failed to retrieve access token');
//     }
//   }
//
//   // Save access token in SharedPreferences
//   Future<void> _saveAccessToken(String accessToken) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('spotify_access_token', accessToken);
//   }
//
//   // Retrieve access token from SharedPreferences
//   Future<String?> getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('spotify_access_token');
//   }
//
//   // Check if user is already logged in
//   Future<bool> isUserLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.containsKey('spotify_access_token');
//   }
//
//   // Clear access token (logout)
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('spotify_access_token');
//   }
// }
