import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_app/core/app_color.dart';
import 'package:phone_app/features/auth/widgets/common_button_widget.dart';
import 'package:phone_app/features/home/provider/add_contact_provider.dart';
import 'package:phone_app/providers/theme_provider.dart';

class EditContactScreen extends ConsumerStatefulWidget {
  final String? id;
  final String? name;
  final String? phone;
  final String? imageUrl;

  const EditContactScreen({
    super.key,
    this.id,
    this.name,
    this.phone,
    this.imageUrl,
  });

  @override
  ConsumerState<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends ConsumerState<EditContactScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(addContactControllerProvider.notifier);
      controller.resetForm();

      // If coming from edit, populate the fields
      if (widget.id != null) {
        controller.nameController.text = widget.name ?? '';
        controller.phoneController.text = widget.phone ?? '';
        controller.setExistingImageUrl(widget.imageUrl);
        // Note: imageUrl handling would need additional implementation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String getInitials(String? name) {
      if (name == null || name.isEmpty) return "?";

      final parts = name.trim().split(' ');
      if (parts.length == 1) {
        return parts[0].substring(0, 1).toUpperCase();
      } else {
        return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
            .toUpperCase();
      }
    }

    final themeMode = ref.watch(themeModeProvider);
    final themeHelper = ThemeHelper(themeMode);
    final state = ref.watch(addContactControllerProvider);
    final controller = ref.read(addContactControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.id == null ? "Add Contact" : "Edit Contact",
          style: GoogleFonts.poppins(color: themeHelper.textColor),
        ),
        backgroundColor: themeHelper.backgroundColor,
        iconTheme: IconThemeData(color: themeHelper.textColor),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Gap(40.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 200.h,
                              width: 200.w,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                image: (state.imageFile != null)
                                    ? DecorationImage(
                                        image: FileImage(state.imageFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : (widget.imageUrl != null &&
                                          widget.imageUrl!.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(widget.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  (state.imageFile == null &&
                                      (widget.imageUrl == null ||
                                          widget.imageUrl!.isEmpty))
                                  ? Center(
                                      child: Text(
                                        getInitials(widget.name),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 48.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),

                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  await controller.pickImageFromGallery();
                                },
                                child: Container(
                                  height: 80.h,
                                  width: 80.w,
                                  decoration: BoxDecoration(
                                    color: themeHelper.textColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      size: 40.sp,
                                      Icons.camera_alt,
                                      color: themeHelper.antiCameraColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Gap(30.h),
                    Text(
                      state.imageFile == null && widget.imageUrl == null
                          ? "Tap to add photo"
                          : "Tap to change photo",
                      style: GoogleFonts.poppins(color: themeHelper.textColor),
                    ),
                    Gap(40.h),
                    TextField(
                      controller: controller.nameController,
                      onChanged: controller.setName,
                      style: TextStyle(color: themeHelper.textColor),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: themeHelper.textColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: themeHelper.textColor),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: themeHelper.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    Gap(20.h),
                    TextField(
                      controller: controller.phoneController,
                      onChanged: controller.setPhoneNumber,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: themeHelper.textColor),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: themeHelper.textColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: themeHelper.textColor),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: themeHelper.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    Gap(70.h),

                    if (state.errorMessage != null)
                      Text(
                        state.errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),

                    CommonButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (widget.id == null) {
                                controller.addContact(context);
                              } else {
                                controller.editContact(
                                  context,
                                  widget.id!,
                                  ref,
                                );
                              }
                            },
                      text: widget.id == null
                          ? (state.isLoading ? "Adding..." : "Add Contact")
                          : (state.isLoading
                                ? "Updating..."
                                : "Update Contact"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.isLoading) ...[
            Opacity(
              opacity: 0.6,
              child: ModalBarrier(
                dismissible: false,
                color: themeHelper.backgroundColor,
              ),
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
      backgroundColor: themeHelper.backgroundColor,
    );
  }
}
