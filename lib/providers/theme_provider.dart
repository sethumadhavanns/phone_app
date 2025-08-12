import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the current ThemeMode for the app
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark; // Default to dark mode for now
});
