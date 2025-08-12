import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  const CommonButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purpleAccent, // Button color
          foregroundColor: Colors.white, // Text color
          padding: EdgeInsets.symmetric(vertical: 14), // Optional padding
        ),
        onPressed: onPressed,
        child: Text(
          text,
          // style: TextStyle(fontSize: 16.sp), // Optional text size
        ),
      ),
    );
  }
}
