import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:zizzle/widgets/pulseloader.dart';

class OrginalAudio extends StatefulWidget {
  final String? Audioname;
  final String caller;
  final int? videoDuration; // in seconds

  const OrginalAudio({
    super.key,
    this.Audioname,
    required this.caller,
    this.videoDuration,
  });

  @override
  State<OrginalAudio> createState() => _OrginalAudioState();
}

class _OrginalAudioState extends State<OrginalAudio> {
  final TextEditingController _renameController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _metaPlayer = AudioPlayer();
  final Map<String, Duration> _durations = {};
  String? _currentlyPlayingUrl;

  double _sliderStart = 0;
  double _sliderEnd = 0;
  bool _showTrimSlider = false;
  String _selectedSongName = '';
  String _selectedSongUrl = '';
  StreamSubscription<Duration>? _positionSubscription;
  double _currentPlaybackPosition = 0;

  Future<void> fetchSongDuration(String url) async {
    try {
      // Slight delay to reduce heavy fetching at once
      await Future.delayed(const Duration(milliseconds: 100));
      final duration = await _metaPlayer.setUrl(url);
      if (duration != null && mounted) {
        setState(() {
          _durations[url] = duration;
        });
      }
    } catch (e) {
      print("Error fetching duration for $url: $e");
    }
  }

  // Future<void> _playPause(String url) async {
  //   print("Play/Pause called for: $url");

  //   try {
  //     if (_currentlyPlayingUrl == url && _audioPlayer.playing) {
  //       print("Pausing audio...");
  //       await _audioPlayer.pause();
  //     } else {
  //       if (_currentlyPlayingUrl != url) {
  //         print("Setting new URL: $url");
  //         await _audioPlayer.setUrl(url);
  //         await _audioPlayer.load();

  //         print("Waiting for audio to be ready...");
  //         await _audioPlayer.processingStateStream.firstWhere(
  //           (state) => state == ProcessingState.ready,
  //         );

  //         print("Audio is ready to play");

  //         if (url == _selectedSongUrl && _showTrimSlider) {
  //           await _audioPlayer.seek(Duration(seconds: _sliderStart.round()));
  //         } else {
  //           await _audioPlayer.seek(Duration.zero);
  //         }

  //         _currentlyPlayingUrl = url;
  //       }

  //       print("Trying to play audio...");
  //       await _audioPlayer.play();
  //       print("Playback started");
  //     }
  //   } catch (e) {
  //     print("Error in _playPause: $e");
  //   }

  //   setState(() {});
  // }

  Future<void> _playPause(String previewUrl) async {
    try {
      await _audioPlayer.setUrl(previewUrl);
      await _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.play();
    } catch (e) {
      print('Error playing preview: $e');
    }
  }

  @override
  void dispose() {
    _renameController.dispose();
    _audioPlayer.dispose();
    _metaPlayer.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPlaybackPosition = position.inSeconds.toDouble();
      });

      final end = Duration(seconds: _sliderEnd.round());
      if (_audioPlayer.playing &&
          _currentlyPlayingUrl == _selectedSongUrl &&
          _showTrimSlider &&
          position >= end) {
        _audioPlayer.pause();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Original Audios"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0A0A), // Very dark gray
              Color(0xFF1E1E1E), // Slightly lighter dark gray
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kToolbarHeight),
              // Card(
              //   color: Colors.white.withOpacity(0.05),
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(15)),
              //   elevation: 5,
              // child: const Padding(
              //   padding: EdgeInsets.all(16.0),
              //   child: Text(
              //     "Select a Song:",
              //     style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold),
              //   ),
              // ),
              // ),
              // const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('songs')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }

                    final songs = snapshot.data!.docs;

                    if (songs.isEmpty) {
                      return const Center(
                        child: Text("No songs found.",
                            style: TextStyle(color: Colors.white)),
                      );
                    }

                    for (var songDoc in songs) {
                      final song = songDoc.data() as Map<String, dynamic>;
                      final songUrl = song['url'] ?? '';
                      if (!_durations.containsKey(songUrl)) {
                        fetchSongDuration(songUrl);
                      }
                    }

                    int totalSongs = songs.length;
                    int loadedDurations = songs.where((songDoc) {
                      final song = songDoc.data() as Map<String, dynamic>;
                      final songUrl = song['url'] ?? '';
                      return _durations.containsKey(songUrl);
                    }).length;

                    double progress =
                        totalSongs == 0 ? 0 : loadedDurations / totalSongs;
                    int percent = (progress * 100).round();
                    final allDurationsLoaded = loadedDurations == totalSongs;

                    if (!allDurationsLoaded) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Finding compatible songs for your video...",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 6,
                                    color: Colors.cyanAccent,
                                    backgroundColor: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  "$percent%",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    final displaySongs = widget.caller == "Reels"
                        ? songs.where((songDoc) {
                            final song = songDoc.data() as Map<String, dynamic>;
                            final songUrl = song['url'] ?? '';
                            final duration = _durations[songUrl];
                            return duration != null &&
                                duration.inSeconds >= widget.videoDuration!;
                          }).toList()
                        : songs;

                    if (widget.caller == "Reels" && displaySongs.isEmpty) {
                      return const Center(
                        child: Text("No compatible songs found.",
                            style: TextStyle(color: Colors.white)),
                      );
                    }

                    return ListView.builder(
                      itemCount: displaySongs.length,
                      itemBuilder: (context, index) {
                        final song =
                            displaySongs[index].data() as Map<String, dynamic>;
                        final songName = song['name'] ?? 'Unknown';
                        final songUrl = song['url'] ?? '';
                        final duration = _durations[songUrl]!;

                        final durationText =
                            "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
                        final isCurrent = _currentlyPlayingUrl == songUrl;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          color: isCurrent
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 3,
                          child: ListTile(
                            onTap: () async {
                              final renamed = _renameController.text.trim();
                              setState(() {
                                _showTrimSlider = true;
                                _sliderStart = 0;
                                _sliderEnd = widget.caller == "Reels"
                                    ? widget.videoDuration!.toDouble()
                                    : duration.inSeconds.toDouble();
                                _selectedSongName = songName;
                                _selectedSongUrl = songUrl;
                                _currentlyPlayingUrl = songUrl;
                                _currentPlaybackPosition = 0;
                              });
                              _playPause(songUrl);
                            },
                            title: Text(songName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(durationText,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            trailing: Icon(
                              isCurrent ? Icons.equalizer : Icons.music_note,
                              color:
                                  isCurrent ? Colors.cyanAccent : Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_selectedSongUrl != null && _selectedSongUrl!.isNotEmpty)
                Card(
                  color: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  margin: const EdgeInsets.only(top: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _audioPlayer.playing
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: Colors.cyanAccent,
                                size: 30,
                              ),
                              onPressed: () async {
                                _playPause(_selectedSongUrl!);
                              },
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.cyanAccent,
                                  inactiveTrackColor: Colors.grey[700],
                                  thumbColor: Colors.white,
                                  overlayColor:
                                      Colors.cyanAccent.withOpacity(0.2),
                                  trackHeight: 4.0,
                                ),
                                child: Slider(
                                  value: _currentPlaybackPosition,
                                  max: (_durations[_selectedSongUrl]
                                          ?.inSeconds
                                          ?.toDouble() ??
                                      1),
                                  min: 0,
                                  onChanged: (value) async {
                                    setState(
                                        () => _currentPlaybackPosition = value);
                                    await _audioPlayer
                                        .seek(Duration(seconds: value.toInt()));
                                  },
                                ),
                              ),
                            ),
                            Text(
                              "${_currentPlaybackPosition.toInt()}s",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        if (_showTrimSlider)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text("Trim Audio for: $_selectedSongName",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.greenAccent,
                                  inactiveTrackColor: Colors.grey[700],
                                  thumbColor: Colors.white,
                                  overlayColor:
                                      Colors.greenAccent.withOpacity(0.2),
                                  // rangeTrackHeight: 4.0,
                                ),
                                child: RangeSlider(
                                  values: RangeValues(_sliderStart, _sliderEnd),
                                  min: 0,
                                  max: widget.caller == "Reels"
                                      ? (_durations[_selectedSongUrl]
                                                  ?.inSeconds ??
                                              widget.videoDuration!)!
                                          .toDouble()
                                      : (_durations[_selectedSongUrl]
                                              ?.inSeconds
                                              ?.toDouble() ??
                                          0),
                                  labels: RangeLabels(
                                    _sliderStart.toStringAsFixed(0),
                                    _sliderEnd.toStringAsFixed(0),
                                  ),
                                  onChanged: (RangeValues values) async {
                                    setState(() {
                                      if (widget.caller == "Reels") {
                                        final windowSize =
                                            widget.videoDuration!.toDouble();
                                        final newStart = values.start;
                                        final newEnd = newStart + windowSize;
                                        final maxEnd =
                                            (_durations[_selectedSongUrl]
                                                        ?.inSeconds ??
                                                    windowSize)
                                                .toDouble();

                                        if (newEnd > maxEnd) {
                                          _sliderStart = maxEnd - windowSize;
                                          _sliderEnd = maxEnd;
                                        } else {
                                          _sliderStart = newStart;
                                          _sliderEnd = newEnd;
                                        }
                                      } else {
                                        _sliderStart = values.start;
                                        _sliderEnd = values.end;
                                      }
                                    });
                                    await _audioPlayer.seek(Duration(
                                        seconds: _sliderStart.round()));
                                    if (!_audioPlayer.playing) {
                                      await _audioPlayer.play();
                                    }
                                  },
                                  divisions: widget.caller == "Reels"
                                      ? ((_durations[_selectedSongUrl]
                                                      ?.inSeconds ??
                                                  widget.videoDuration!)! -
                                              widget.videoDuration!)
                                          .clamp(1, 1000)
                                      : ((_durations[_selectedSongUrl]
                                                      ?.inSeconds ??
                                                  1) -
                                              1)
                                          .clamp(1, 1000),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.green, Colors.teal],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    final renamed =
                                        _renameController.text.trim();
                                    Navigator.pop(context, {
                                      "songname": _selectedSongName,
                                      "url": _selectedSongUrl,
                                      "rename": renamed,
                                      "start": _sliderStart.round(),
                                      "end": _sliderEnd.round(),
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                  ),
                                  child: const Text("Use This Trimmed Audio",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
