import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonTextfield extends StatelessWidget {
  final String? heading, hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  const CommonTextfield({
    this.suffixIcon,
    super.key,
    this.prefixIcon,
    this.heading,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: heading != null,
          child: Column(
            children: [
              Text(
                heading.toString(),
                style: GoogleFonts.poppins(color: Colors.purpleAccent),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
        TextField(
          style: TextStyle(
            // fontSize: 30.sp,
            color: Colors.black, // ✅ Set input text color to black
          ),
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            hintText: hintText,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.purpleAccent,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.purpleAccent,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.purpleAccent,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
