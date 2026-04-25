import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zizzle/utils/utils.dart';
import 'package:zizzle/widgets/Particleloadertester.dart';
import 'dart:math' as math;

import 'package:zizzle/widgets/pulseloader.dart';

// THE CUSTOMIZATION SCREEN
class LoaderCustomizationScreen extends StatefulWidget {
  final String? username;
  const LoaderCustomizationScreen({Key? key, required this.username})
      : super(key: key);

  @override
  _LoaderCustomizationScreenState createState() =>
      _LoaderCustomizationScreenState();
}

class _LoaderCustomizationScreenState extends State<LoaderCustomizationScreen> {
  // Default values
  double _size = 190.0;
  List<Color> _gradientColors = [
    Colors.cyan,
    Colors.indigo,
    Colors.red,
    Colors.yellow
  ];
  int _particleCount = 730;

  final TextEditingController _hexController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadFromFirestore();
    print(widget.username);
  }

  Future<void> _loadFromFirestore() async {
    if (_userId == null) return;
    final doc = await _firestore.collection('users').doc(widget.username).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      setState(() {
        _size = (data['loadingSize'] as num?)?.toDouble() ?? _size;
        _particleCount =
            (data['loadingParticleCount'] as int?) ?? _particleCount;
        final colorInts = List<int>.from(data['colors'] ?? []);
        if (colorInts.isNotEmpty) {
          _gradientColors =
              colorInts.map((intValue) => Color(intValue)).toList();
        }
      });
    }
  }

  void _addColor(Color color) {
    setState(() {
      _gradientColors.add(color);
    });
  }

  void _removeColor(int index) {
    if (_gradientColors.length > 2) {
      setState(() {
        _gradientColors.removeAt(index);
      });
    } else {
      showSnackBar("You need atleast 2 colors", context);
    }
  }

  void _showAddColorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add Color',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Option 1: Select from Palette',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _paletteColor(Colors.redAccent),
                    _paletteColor(Colors.greenAccent),
                    _paletteColor(Colors.blueAccent),
                    _paletteColor(Colors.yellowAccent),
                    _paletteColor(Colors.cyanAccent),
                    _paletteColor(Colors.indigoAccent),
                    _paletteColor(Colors.purpleAccent),
                    _paletteColor(Colors.orangeAccent),
                    _paletteColor(Colors.pinkAccent),
                    _paletteColor(Colors.tealAccent),
                    _paletteColor(Colors.amberAccent),
                    _paletteColor(Colors.limeAccent),
                  ].map((colorWidget) {
                    return SizedBox(
                      width: 40,
                      height: 40,
                      child: colorWidget,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Option 2: Manual Hex Input',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                TextField(
                  controller: _hexController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Hex Code (e.g., #FF0000)',
                    labelStyle: TextStyle(color: Colors.blueGrey[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blueGrey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blueGrey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    final hex = _hexController.text.trim();
                    if (hex.startsWith('#') &&
                        (hex.length == 7 || hex.length == 9)) {
                      try {
                        final color = Color(
                            int.parse(hex.substring(1), radix: 16) |
                                (hex.length == 7 ? 0xFF000000 : 0));
                        _addColor(color);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid hex code.')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid hex format.')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add Manual Color',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueGrey[200],
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _paletteColor(Color color) {
    return GestureDetector(
      onTap: () {
        _addColor(color);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _previewLoader() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // Make dialog background transparent
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
                  child: Text(
                    'Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(color: Colors.white12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Container(
                    width: _size + 40, // Add padding for the glow effect
                    height: _size + 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: LoaderTester(
                      size: _size,
                      gradientColors: _gradientColors,
                      particleCount: _particleCount,
                    ),
                  ),
                ),
                const Divider(color: Colors.white12),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveToFirestore() async {
    if (widget.username == null) {
      if (mounted) {
        showSnackBar("User not authenticated.", context);
      }
      return;
    }

    // show loading
    setState(() => _isSaving = true);

    final colorInts = _gradientColors.map((color) => color.value).toList();

    try {
      await _firestore.collection('users').doc(widget.username).update({
        'colors': colorInts,
        'loadingSize': _size,
        'loadingParticleCount': _particleCount,
      });

      if (mounted) {
        showSnackBar("Customizations saved successfully!", context);
      }
    } catch (e) {
      debugPrint("Error updating document: $e");
      if (mounted) {
        showSnackBar("Failed to save customizations.", context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Customize Loader',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              color: Colors.grey[850],
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Size',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.blueAccent,
                        inactiveTrackColor: Colors.blueGrey[700],
                        thumbColor: Colors.blueAccent,
                        overlayColor: Colors.blueAccent.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10.0),
                      ),
                      child: Slider(
                        value: _size,
                        min: 20.0,
                        max: 300.0,
                        onChanged: (value) => setState(() => _size = value),
                      ),
                    ),
                    Text(
                      'Current Size: ${_size.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Particle Count',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.pinkAccent,
                        inactiveTrackColor: Colors.blueGrey[700],
                        thumbColor: Colors.pinkAccent,
                        overlayColor: Colors.pinkAccent.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10.0),
                      ),
                      child: Slider(
                        value: _particleCount.toDouble(),
                        min: 10,
                        max: 1000,
                        divisions: 90,
                        onChanged: (value) =>
                            setState(() => _particleCount = value.toInt()),
                      ),
                    ),
                    Text(
                      'Current Particle Count: $_particleCount',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.grey[850],
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gradient Colors',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      children: List.generate(_gradientColors.length, (index) {
                        return GestureDetector(
                          onTap: () => _removeColor(index),
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: _gradientColors[index],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      _gradientColors[index].withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _gradientColors.length > 2
                                  ? const Icon(Icons.close,
                                      color: Colors.white, size: 24)
                                  : const SizedBox(),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showAddColorDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Add Color',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _previewLoader,
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text('Preview',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveToFirestore,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[700],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
