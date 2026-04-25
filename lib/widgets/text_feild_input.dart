import 'package:flutter/material.dart';
import 'package:zizzle/utils/colors.dart'; // Make sure this path is correct

class TextFeildInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool ispass;
  final String hinttext;
  final TextInputType textInputType;

  const TextFeildInput({
    Key? key,
    required this.textInputType,
    this.ispass = false,
    required this.textEditingController,
    required this.hinttext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color inputFillColor =
        Color.fromRGBO(30, 42, 58, 1.0); // A dark, subtle color for the fill
    const Color hintTextColor = Colors.white54; // Lighter color for hint text
    const Color inputTextColor =
        Colors.white; // White for the actual text input

    const borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide.none, // Removes the visible border line
    );

    return TextField(
      controller: textEditingController,
      style: const TextStyle(color: inputTextColor),
      decoration: InputDecoration(
        hintText: hinttext,
        hintStyle: const TextStyle(color: hintTextColor),
        border: borderStyle,
        focusedBorder: borderStyle.copyWith(
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        enabledBorder: borderStyle,
        filled: true,
        fillColor: inputFillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      ),
      keyboardType: textInputType,
      obscureText: ispass,
    );
  }
}
