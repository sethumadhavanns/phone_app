// The StateNotifierProvider exposes the state (RegisterState)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_app/features/auth/controllers/register_controller.dart';

final registerControllerProvider =
    StateNotifierProvider<RegisterController, RegisterState>((ref) {
      return RegisterController();
    });

// Separate Provider to get the controller instance itself (to access TextEditingControllers)
final registerControllerInstanceProvider =
    StateNotifierProvider<RegisterController, RegisterState>(
      (ref) => RegisterController(),
    );
