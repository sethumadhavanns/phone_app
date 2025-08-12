import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_app/core/pop_up_helper.dart';
import 'package:phone_app/features/home/provider/contacts_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddContactState {
  final String name;
  final String phoneNumber;
  final bool isLoading;
  final String? errorMessage;
  final bool success;
  final File? imageFile; // Add this line
  final String? existingImageUrl;

  AddContactState({
    this.name = '',
    this.phoneNumber = '',
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
    this.imageFile, // Add this line
    this.existingImageUrl,
  });

  AddContactState copyWith({
    String? name,
    String? phoneNumber,
    bool? isLoading,
    String? errorMessage,
    bool? success,
    File? imageFile, // Add this line
    String? existingImageUrl,
  }) {
    return AddContactState(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? this.success,
      imageFile: imageFile ?? this.imageFile, // Add this line
      existingImageUrl: existingImageUrl ?? this.existingImageUrl,
    );
  }
}

class AddContactController extends StateNotifier<AddContactState> {
  AddContactController() : super(AddContactState()) {
    // Initialize listeners if needed
    state = state.copyWith(imageFile: null);
    nameController.addListener(_nameListener);
    phoneController.addListener(_phoneListener);
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void initializeForEdit(String name, String phone, String? imageUrl) {
    nameController.text = name;
    phoneController.text = phone;
    state = state.copyWith(
      name: name,
      phoneNumber: phone,
      existingImageUrl: imageUrl,
    );
  }

  void setExistingImageUrl(String? url) {
    state = state.copyWith(existingImageUrl: url);
  }

  void _nameListener() {
    setName(nameController.text);
  }

  void _phoneListener() {
    setPhoneNumber(phoneController.text);
  }

  void setName(String value) {
    state = state.copyWith(name: value, errorMessage: null, success: false);
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        state = state.copyWith(imageFile: File(image.path));
        log("successfull with image");
      }
    } catch (e) {
      log("Image picker error: $e");
      state = state.copyWith(errorMessage: "Failed to pick image");
    }
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(
      phoneNumber: value,
      errorMessage: null,
      success: false,
    );
  }

  void resetForm() {
    nameController.clear();
    phoneController.clear();
    state = AddContactState(); // Resets to initial state
  }

  Future<void> addContact(BuildContext context) async {
    // Validate inputs
    if (state.name.trim().isEmpty || state.phoneNumber.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: "Please fill all fields",
        success: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, success: false);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null)
        throw Exception("User not authenticated - please log in");

      // Verify we have a valid session
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null)
        throw Exception("Session expired - please log in again");

      // 1. Upload image if exists
      String? imageUrl;
      if (state.imageFile != null) {
        final filePath =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('contact-avatars')
            .upload(filePath, state.imageFile!);

        imageUrl = Supabase.instance.client.storage
            .from('contact-avatars')
            .getPublicUrl(filePath);
      }

      // 2. Insert contact - MUST include user_id that matches auth.uid()
      await Supabase.instance.client.from('contacts').insert({
        'name': state.name.trim(),
        'phone': state.phoneNumber.trim(),
        'avatar_url': imageUrl,
        'user_id': user.id, // This is critical for RLS
        'is_favorite': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 3. On success
      if (context.mounted) {
        await PopupAlertHelper.showPopupAlert(
          context,
          true,
          "Contact added successfully!",
        );
        resetForm();
        Navigator.of(context).pop(true);
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Authentication error: ${e.message}",
      );
      if (context.mounted) {
        await PopupAlertHelper.showPopupAlert(
          context,
          false,
          "Please log in again",
        );
      }
    } on PostgrestException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Database error: ${e.message}",
      );
      if (context.mounted) {
        await PopupAlertHelper.showPopupAlert(
          context,
          false,
          "Failed to save contact",
        );
      }
    } catch (e) {
      log(e.toString());
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Error: ${e.toString()}",
      );
      if (context.mounted) {
        await PopupAlertHelper.showPopupAlert(
          context,
          false,
          "An unexpected error occurred",
        );
      }
    }
  }

  Future<void> editContact(
    BuildContext context,
    String contactId,
    WidgetRef ref,
  ) async {
    // Validate inputs
    if (state.name.trim().isEmpty || state.phoneNumber.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: "Please fill all fields",
        success: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, success: false);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null)
        throw Exception("User not authenticated - please log in");

      final session = Supabase.instance.client.auth.currentSession;
      if (session == null)
        throw Exception("Session expired - please log in again");

      // 1. Upload new image if changed
      String? imageUrl = state.existingImageUrl;
      if (state.imageFile != null) {
        final filePath =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('contact-avatars')
            .upload(filePath, state.imageFile!);

        imageUrl = Supabase.instance.client.storage
            .from('contact-avatars')
            .getPublicUrl(filePath);
      }

      // 2. Update contact
      await Supabase.instance.client
          .from('contacts')
          .update({
            'name': state.name.trim(),
            'phone': state.phoneNumber.trim(),
            'avatar_url': imageUrl == "" ? null : imageUrl,
            'created_at': DateTime.now().toIso8601String(),
          })
          .eq('id', contactId)
          .eq('user_id', user.id);

      // 3. On success - exit screen
      if (context.mounted) {
        await PopupAlertHelper.showPopupAlert(
          context,
          true,
          "Contact updated successfully!",
        );
        resetForm();
        Navigator.of(context).pop(true); // Only exit here on success
        ref.refresh(contactsProvider);
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Authentication error: ${e.message}",
      );
      if (context.mounted) {
        await PopupAlertHelper.showPopupAlert(
          context,
          false,
          "Please log in again",
        );
      }
      // Don't exit - stay on screen
    } on PostgrestException catch (e) {
      log(e.toString());
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Database error: ${e.message}",
      );
      if (context.mounted) {
        await PopupAlertHelper.showPopupAlert(
          context,
          false,
          "Failed to update contact",
        );
      }
      // Don't exit - stay on screen
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Error: ${e.toString()}",
      );
      if (context.mounted) {
        await PopupAlertHelper.showPopupAlert(
          context,
          false,
          "An unexpected error occurred",
        );
      }
      // Don't exit - stay on screen
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_nameListener);
    phoneController.removeListener(_phoneListener);
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
