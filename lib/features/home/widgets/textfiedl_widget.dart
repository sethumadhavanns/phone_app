import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phone_app/core/app_color.dart';
import 'package:phone_app/features/home/provider/add_contact_provider.dart';
import 'package:phone_app/providers/theme_provider.dart';

class TextFieldWidget extends ConsumerWidget {
  const TextFieldWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeHelper = ThemeHelper(themeMode);
    return TextField(
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).state = value;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: themeHelper.antiBackgroundColor,
        hintText: "Search contacts..",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.r),
          borderSide: BorderSide(color: Colors.black, width: 0.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.r),
          borderSide: BorderSide(color: Colors.black, width: 0.1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.r),
          borderSide: BorderSide(color: Colors.black, width: 0.1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.r),
          borderSide: BorderSide(color: Colors.black, width: 0.1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.r),
          borderSide: BorderSide(color: Colors.black, width: 0.1),
        ),
      ),
    );
  }
}
