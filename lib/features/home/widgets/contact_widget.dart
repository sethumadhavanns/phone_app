import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:phone_app/core/app_color.dart';
import 'package:phone_app/core/pop_up_helper.dart';
import 'package:phone_app/features/home/provider/contacts_provider.dart';
import 'package:phone_app/features/home/view/edit_screen_view.dart';
import 'package:phone_app/providers/theme_provider.dart';

class ContactWidget extends ConsumerStatefulWidget {
  final String name, number, imageUrl, id;
  final bool isFavourite;

  const ContactWidget({
    super.key,
    required this.id,
    required this.name,
    required this.isFavourite,
    required this.number,
    required this.imageUrl,
  });

  @override
  ConsumerState<ContactWidget> createState() => _ContactWidgetState();
}

class _ContactWidgetState extends ConsumerState<ContactWidget> {
  String _getInitials(String name) {
    final names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    log(widget.id.toString());
    final themeMode = ref.watch(themeModeProvider);
    final themeHelper = ThemeHelper(themeMode);
    final contactOps = ref.watch(contactOperationsProvider);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        border: Border.all(color: themeHelper.backgroundColor),
        color: themeHelper.antiBackgroundColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 120.h,
                width: 120.w,
                decoration: BoxDecoration(
                  color: themeHelper.contactProfile,
                  shape: BoxShape.circle,
                ),
                child: widget.imageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                _getInitials(widget.name),
                                style: TextStyle(
                                  color: themeHelper.antiTextColor,
                                  fontSize: 40.sp,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          _getInitials(widget.name),
                          style: TextStyle(
                            color: themeHelper.antiTextColor,
                            fontSize: 40.sp,
                          ),
                        ),
                      ),
              ),
              Gap(20.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(color: themeHelper.antiTextColor),
                  ),
                  Gap(20.h),
                  Text(widget.number, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          Gap(50.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.call, size: 50.sp),
                onPressed: () async {
                  await ref
                      .read(contactOperationsProvider.notifier)
                      .makePhoneCall(widget.number, context);
                  // TODO: handle call action
                },
              ),
              IconButton(
                icon: Icon(Icons.message, size: 50.sp),
                onPressed: () async {
                  await ref
                      .read(contactOperationsProvider.notifier)
                      .sendSMS(widget.number, context);
                  // TODO: handle message action
                },
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 50.sp),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditContactScreen(
                        id: widget.id,
                        name: widget.name,
                        phone: widget.number,
                        imageUrl: widget.imageUrl,
                      ),
                    ),
                  );
                  // TODO: handle edit action
                },
              ),
              IconButton(
                icon: contactOps.isLoading
                    ? SizedBox(
                        height: 10.h,
                        width: 10.w,
                        child: CircularProgressIndicator(),
                      )
                    : Icon(Icons.delete, size: 50.sp),
                onPressed: contactOps.isLoading
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(contactOperationsProvider.notifier)
                              .deleteContact(widget.id);
                          ref.invalidate(contactsProvider);
                          PopupAlertHelper.showPopupAlert(
                            context,
                            true,
                            "contact deleted successfully",
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      },
              ),
              IconButton(
                icon: contactOps.isLoading
                    ? SizedBox(
                        height: 10.h,
                        width: 10.w,
                        child: CircularProgressIndicator(),
                      )
                    : widget.isFavourite
                    ? Icon(Icons.favorite, size: 50.sp, color: Colors.green)
                    : Icon(
                        Icons.favorite_border_outlined,
                        size: 50.sp,
                        color: Colors.green,
                      ),
                onPressed: contactOps.isLoading
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(contactOperationsProvider.notifier)
                              .toggleFavorite(widget.id, widget.isFavourite);
                          ref.invalidate(contactsProvider);
                          // Optional: Show success message
                          PopupAlertHelper.showPopupAlert(
                            context,
                            true,
                            widget.isFavourite
                                ? 'Removed from favorites'
                                : 'Added to favorites',
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
