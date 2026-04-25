import 'package:flutter/material.dart';

class WalletScreenVideoUI extends StatefulWidget {
  final Map<String, dynamic> reelData;

  const WalletScreenVideoUI({Key? key, required this.reelData}) : super(key: key);

  @override
  State<WalletScreenVideoUI> createState() => _WalletScreenVideoUIState();
}

class _WalletScreenVideoUIState extends State<WalletScreenVideoUI> {
  @override
  Widget build(BuildContext context) {
    var earned = widget.reelData['views']/1000;
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        height: 60, // Increased height to accommodate padding
        padding: EdgeInsets.only(bottom: 10), // Add padding to the bottom
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(height: 30, child: Image.network(widget.reelData['thumbnail'])),
            Text(
              widget.reelData['views'].toString(),
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Text(
              "${earned.toString()} CAD" ,
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
