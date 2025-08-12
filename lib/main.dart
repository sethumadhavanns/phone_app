import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phone_app/features/auth/view/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uwlmlmottzvrtxezitbj.supabase.co', // Your Supabase URL here
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3bG1sbW90dHp2cnR4ZXppdGJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MTY0NzQsImV4cCI6MjA3MDQ5MjQ3NH0.m17vcLpr4ESvhtFlJO6GLr2pIxIBMMbL-EZ0VeC8sno',
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );
  runApp(const ProviderScope(child: PhoneBookApp()));
}

class PhoneBookApp extends ConsumerWidget {
  const PhoneBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(1080, 2340),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Phone Book App',
          // theme: lightTheme,
          // darkTheme: darkTheme,
          // themeMode: themeMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
