import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_app/core/pop_up_helper.dart';
import 'package:phone_app/features/auth/provider/register_provider.dart';
import 'package:phone_app/features/auth/view/login_screen.dart';
import 'package:phone_app/features/auth/widgets/common_button_widget.dart';
import 'package:phone_app/features/auth/widgets/common_textfield.widget.dart';
import 'package:phone_app/features/home/view/home_screen.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller & state
    final controller = ref.watch(registerControllerInstanceProvider.notifier);
    final registerState = ref.watch(registerControllerInstanceProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: SingleChildScrollView(
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Create An Account",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      Gap(50.h),
                      CommonTextfield(
                        hintText: "Enter your name",
                        heading: "Name",
                        controller: controller.nameController,
                      ),
                      Gap(60.h),
                      CommonTextfield(
                        prefixIcon: Icon(
                          Icons.mail,
                          color: Colors.purpleAccent,
                        ),
                        hintText: "Enter your email",
                        heading: "Email",
                        controller: controller.emailController,
                      ),
                      Gap(60.h),
                      CommonTextfield(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.purpleAccent,
                        ),
                        hintText: "Enter your password",
                        heading: "Password",
                        controller: controller.passwordController,
                        // obscureText: registerState.obscurePassword,
                      ),
                      Gap(60.h),
                      CommonTextfield(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.purpleAccent,
                        ),
                        hintText: "Enter confirm password",
                        heading: "Confirm Password",
                        controller: controller.confirmPasswordController,
                        // obscureText: registerState.obscurePassword,
                      ),
                      Gap(60.h),
                      CommonButton(
                        onPressed: registerState.isLoading
                            ? null
                            : () async {
                                final success = await controller.register();
                                if (success) {
                                  await PopupAlertHelper.showPopupAlert(
                                    context,
                                    true,
                                    "Registration successful",
                                  );
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (Route<dynamic> route) =>
                                        false, // This removes all previous routes
                                  );
                                } else {
                                  await PopupAlertHelper.showPopupAlert(
                                    context,
                                    false,
                                    registerState.errorMessage ??
                                        "Registration failed",
                                  );
                                }
                              },
                        text: "Sign Up",
                      ),
                      Gap(20.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Already have an account? Login",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay with Lottie when isLoading == true
            if (registerState.isLoading) ...[
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
      ),
    );
  }
}
