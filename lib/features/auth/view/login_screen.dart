import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_app/features/auth/provider/login_provider.dart';
import 'package:phone_app/features/auth/view/register_screen.dart';
import 'package:phone_app/features/auth/widgets/common_button_widget.dart';
import 'package:phone_app/features/auth/widgets/common_textfield.widget.dart';
import 'package:phone_app/features/home/view/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final loginNotifier = ref.read(loginControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome Back",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  SizedBox(height: 60.h),
                  Text(
                    "Login to continue",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  Gap(60.h),

                  // Email
                  CommonTextfield(
                    prefixIcon: Icon(Icons.mail, color: Colors.purpleAccent),
                    hintText: "Enter your email",
                    heading: "Email Address",
                    controller: emailController,
                  ),
                  Gap(60.h),

                  // Password with Riverpod toggle
                  CommonTextfield(
                    obscureText: loginState.obscurePassword,
                    prefixIcon: Icon(Icons.lock, color: Colors.purpleAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        loginState.obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.purpleAccent,
                      ),
                      onPressed: loginNotifier.togglePasswordVisibility,
                    ),
                    hintText: "Enter your password",
                    heading: "Password",
                    controller: passwordController,
                  ),

                  Gap(10.h),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       "Forgot Password?",
                  //       style: GoogleFonts.poppins(
                  //         fontWeight: FontWeight.w500,
                  //         color: Colors.purpleAccent,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Gap(50.h),

                  CommonButton(
                    text: loginState.isLoading ? "Loading..." : "Login",
                    onPressed: loginState.isLoading
                        ? null
                        : () async {
                            final success = await loginNotifier.login(
                              emailController.text,
                              passwordController.text,
                              context,
                            );
                            if (success && mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                                (Route<dynamic> route) =>
                                    false, // This removes all previous routes
                              );
                            }
                          },
                  ),
                  Gap(50.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign up now",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ),
                  // ... (rest of your existing content)
                ],
              ),
            ),
          ),

          // Loading overlay
          if (loginState.isLoading) ...[
            Opacity(
              opacity: 0.6,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
            Center(
              child: SizedBox(
                width: 150.w,
                height: 150.w,
                child: Lottie.asset(
                  'assets/lottie/loader.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
