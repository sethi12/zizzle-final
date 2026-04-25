import 'package:flutter/material.dart';

class BlueTick extends StatelessWidget {
  const BlueTick({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(
        Icons.verified,
        size: 16,
        color: Color(0xFF0095F6), // Instagram's blue
      ),
    );
  }
}
