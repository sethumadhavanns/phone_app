import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController extends StateNotifier<RegisterState> {
  RegisterController() : super(RegisterState());

  // TextEditingControllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  // Register API or logic simulation
  Future<bool> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      state = state.copyWith(errorMessage: "Please fill all fields");
      return false;
    }

    if (password != confirmPassword) {
      state = state.copyWith(errorMessage: "Passwords do not match");
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Check if email already exists in users table
      final existingUserResponse = await Supabase.instance.client
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (existingUserResponse != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Email already exists",
        );
        // Clear fields on failure (optional)
        _clearFields();
        return false;
      }

      // Register with Supabase auth
      final signUpResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // user metadata
      );

      if (signUpResponse.user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Registration failed",
        );
        // Clear fields on failure (optional)
        _clearFields();
        return false;
      }

      // Insert user details in 'users' table
      await Supabase.instance.client.from('users').insert({
        'id': signUpResponse.user!.id,
        'email': email,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(isLoading: false, success: true);

      // Clear fields on success
      _clearFields();

      return true;
    } on AuthException catch (e) {
      String errorMessage = e.message;

      // Handle specific auth errors
      if (errorMessage.toLowerCase().contains('already registered') ||
          errorMessage.toLowerCase().contains('email already exists') ||
          errorMessage.toLowerCase().contains('duplicate')) {
        errorMessage = "Email already exists";
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      _clearFields();
      return false;
    } on PostgrestException catch (e) {
      // Handle Supabase database errors
      String errorMessage = "Database error occurred";

      if (e.code == '23505') {
        // Unique constraint violation
        errorMessage = "Email already exists";
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      _clearFields();
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "An unexpected error occurred. Please try again.",
      );
      _clearFields();
      return false;
    }
  }

  // Helper function to clear all controllers
  void _clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  // Dispose controllers when provider is disposed
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

class RegisterState {
  final bool obscurePassword;
  final bool isLoading;
  final bool success;
  final String? errorMessage;

  RegisterState({
    this.obscurePassword = true,
    this.isLoading = false,
    this.success = false,
    this.errorMessage,
  });

  RegisterState copyWith({
    bool? obscurePassword,
    bool? isLoading,
    bool? success,
    String? errorMessage,
  }) {
    return RegisterState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      errorMessage: errorMessage,
    );
  }
}
