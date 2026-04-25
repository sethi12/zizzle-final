import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Function()? function;
  final Color backgroundcolor;
  final Color bordercolor;
  final String text;
  final Color textcolor;
  const FollowButton({
    Key? key,
    required this.text,
    required this.bordercolor,
    required this.backgroundcolor,
    required this.textcolor,
    this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: TextButton(
        onPressed: function,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width / 2.1,
          height: 38,
          decoration: BoxDecoration(
            color: backgroundcolor,
            border: Border.all(color: bordercolor),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: textcolor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
