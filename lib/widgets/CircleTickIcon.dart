import 'package:flutter/material.dart';

class CircleTickIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: const CircleAvatar(
        radius: 10,
        backgroundColor: Color.fromRGBO(
            255, 222, 173, 0.6), // Set your preferred circle color
        child: Icon(
          Icons.check_circle,
          size: 18,
          color:
              Color.fromRGBO(129, 207, 224, 1), // Set your preferred tick color
        ),
      ),
    );
  }
}
