// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:zizzle/Screens/Add_post_screen_details.dart';
// import 'package:zizzle/Screens/add_reel_details.dart';
// import 'package:zizzle/utils/utils.dart';
// import 'SpotifyAuthService.dart';
// import 'SpotifyService.dart';
//
// class SpotifyApp extends StatefulWidget {
//   Uint8List? selectedimage;
//   final String caller;
//   final File? videofile;
//   final String? videopath;
//   SpotifyApp(
//       {required this.caller,
//       this.selectedimage,
//       this.videofile,
//       this.videopath});
//   @override
//   _SpotifyAppState createState() => _SpotifyAppState();
// }
//
// class _SpotifyAppState extends State<SpotifyApp> {
//   // final SpotifyAuthService authService = SpotifyAuthService();
//   final SpotifyService spotifyService = SpotifyService();
//   String? accessToken;
//   List<dynamic> searchResults = [];
//   String? currentlyPlayingTrack; // Track the ID of the currently playing song
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfUserIsLoggedIn();
//   }
//
//   // Check if user is already logged in and retrieve the access token
//   Future<void> _checkIfUserIsLoggedIn() async {
//     final isLoggedIn = await authService.isUserLoggedIn();
//     if (isLoggedIn) {
//       final storedAccessToken = await authService.getAccessToken();
//       setState(() {
//         accessToken = storedAccessToken;
//       });
//     }
//   }
//
//   Future<void> loginAndFetchData() async {
//     try {
//       accessToken = await authService.authenticateUser();
//       setState(() {});
//     } catch (error) {
//       print("Error during authentication: $error");
//     }
//   }
//
//   Future<void> search(String query) async {
//     if (accessToken != null) {
//       final results = await spotifyService.searchTracks(accessToken!, query);
//       setState(() {
//         searchResults = results;
//       });
//     }
//   }
//
//   void togglePlayPause(String trackId, String previewUrl) async {
//     if (currentlyPlayingTrack == trackId) {
//       spotifyService.stopPreview();
//       setState(() {
//         currentlyPlayingTrack = null;
//       });
//     } else {
//       await spotifyService.playPreview(previewUrl);
//       setState(() {
//         currentlyPlayingTrack = trackId;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Music Search')),
//       body: Column(
//         children: [
//           // if (accessToken ==
//           //     null) // Show login button only if user is not logged in
//           ElevatedButton(
//             onPressed: loginAndFetchData,
//             child: Text('Login for music'),
//           ),
//           TextField(
//             onSubmitted: search,
//             decoration: InputDecoration(
//               hintText: 'Search for a song...',
//             ),
//           ),
//           Expanded(
//             child: searchResults.isEmpty
//                 ? Center(child: Text('No results found'))
//                 : ListView.builder(
//                     itemCount: searchResults.length,
//                     itemBuilder: (context, index) {
//                       final track = searchResults[index];
//                       final trackId = track['id'];
//                       final previewUrl = track['preview_url'];
//                       final name = track['name'];
//                       return ListTile(
//                         onTap: () {
//                           if (previewUrl != null) {
//                             if (widget.caller == "AddPostScreen") {
//                               Navigator.of(context).push(MaterialPageRoute(
//                                   builder: (context) => AddpostScreenDetails(
//                                         trackid: trackId,
//                                         previewUrl: previewUrl,
//                                         songname: name,
//                                         selectedimage: widget.selectedimage,
//                                       )));
//                             } else if (widget.caller == "Reels") {
//                               Navigator.pop(context, {
//                                 'trackId': trackId,
//                                 'previewUrl': previewUrl,
//                                 'name': name,
//                                 'track': track,
//                               });
//                             }
//                           } else {
//                             showSnackBar(
//                                 "song is not available at this time ", context);
//                           }
//                           spotifyService.stopPreview();
//                         },
//                         title: Text(track['name']),
//                         subtitle: Text(track['artists'][0]['name']),
//                         trailing: IconButton(
//                           icon: Icon(
//                             currentlyPlayingTrack == trackId
//                                 ? Icons.pause
//                                 : Icons.play_arrow,
//                           ),
//                           onPressed: () {
//                             // print(previewUrl);
//                             if (previewUrl != null) {
//                               togglePlayPause(trackId, previewUrl);
//                             } else {
//                               showSnackBar(
//                                   "song is not available at this time ",
//                                   context);
//                             }
//                           },
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
