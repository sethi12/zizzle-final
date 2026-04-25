import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoaderConfig {
  static final LoaderConfig _instance = LoaderConfig._internal();
  factory LoaderConfig() => _instance;

  LoaderConfig._internal();

  // default values
  double size = 190.0;
  List<Color> gradientColors = const [
    Colors.cyan,
    Colors.indigo,
    Colors.red,
    Colors.yellow,
  ];
  int particleCount = 730;

  /// Call this once (e.g. in SplashScreen)
  Future<void> loadFromFirestore(String username) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        size = (data['loadingSize'] as num?)?.toDouble() ?? size;
        particleCount = (data['loadingParticleCount'] as int?) ?? particleCount;

        final colorInts = List<int>.from(data['colors'] ?? []);
        if (colorInts.isNotEmpty) {
          gradientColors =
              colorInts.map((intValue) => Color(intValue)).toList();
        }
      }
    } catch (e) {
      debugPrint("Error loading loader config: $e");
    }
  }
}
