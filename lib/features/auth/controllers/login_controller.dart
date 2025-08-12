import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_app/core/pop_up_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(LoginState());

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    // Input validations
    if (email.isEmpty || password.isEmpty) {
      await PopupAlertHelper.showPopupAlert(
        context,
        false,
        "Please fill in all fields",
      );
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      await PopupAlertHelper.showPopupAlert(
        context,
        false,
        "Please enter a valid email address",
      );
      return false;
    }

    if (password.length < 6) {
      await PopupAlertHelper.showPopupAlert(
        context,
        false,
        "Password must be at least 6 characters",
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, success: false);

    try {
      // Attempt regular login
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      // Successful login (regardless of email confirmation status)
      if (response.session != null) {
        await PopupAlertHelper.showPopupAlert(
          context,
          true,
          "Login successful!",
        );

        state = state.copyWith(
          isLoading: false,
          success: true,
          errorMessage: null,
        );
        return true;
      }

      // This should theoretically never be reached
      await PopupAlertHelper.showPopupAlert(context, false, "Login failed");
      state = state.copyWith(isLoading: false, success: false);
      return false;
    } on AuthException catch (e) {
      // Special handling for email not confirmed error
      if (e.message.toLowerCase().contains('email not confirmed')) {
        try {
          // Force login by getting new session
          final session = await Supabase.instance.client.auth.refreshSession();

          if (session.session != null) {
            await PopupAlertHelper.showPopupAlert(
              context,
              true,
              "Login successful!",
            );
            state = state.copyWith(isLoading: false, success: true);
            return true;
          }
        } catch (refreshError) {
          // Continue to show original error if refresh fails
        }
      }

      // Show original error for all other cases
      await PopupAlertHelper.showPopupAlert(context, false, e.message);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        success: false,
      );
      return false;
    } catch (e) {
      await PopupAlertHelper.showPopupAlert(
        context,
        false,
        "An unexpected error occurred. Please try again.",
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: "An unexpected error occurred. Please try again.",
        success: false,
      );
      return false;
    }
  }
}

class LoginState {
  final bool obscurePassword;
  final bool isLoading;
  final bool success;
  final String? errorMessage;

  LoginState({
    this.obscurePassword = true,
    this.isLoading = false,
    this.success = false,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? obscurePassword,
    bool? isLoading,
    bool? success,
    String? errorMessage,
  }) {
    return LoginState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      errorMessage: errorMessage,
    );
  }
}
