import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phone_app/core/app_color.dart';
import 'package:phone_app/features/auth/view/login_screen.dart';
import 'package:phone_app/features/home/provider/add_contact_provider.dart';
import 'package:phone_app/features/home/provider/contacts_provider.dart';
import 'package:phone_app/features/home/view/edit_screen_view.dart';
import 'package:phone_app/features/home/widgets/contact_widget.dart';
import 'package:phone_app/features/home/widgets/textfiedl_widget.dart';
import 'package:phone_app/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themeHelper = ThemeHelper(themeMode);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditContactScreen()),
          );
          ref.refresh(contactsProvider);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: themeHelper.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeHelper.backgroundColor,
        title: Text(
          "Phone Book",
          style: GoogleFonts.poppins(
            color: themeHelper.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: themeHelper.textColor),
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          Gap(50.w),
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: themeHelper.textColor,
            ),
            onPressed: () {
              themeNotifier.state = themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(contactsProvider.future),
            child: contactsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (contacts) {
                final filteredContacts = contacts.where((contact) {
                  final name = contact['name']?.toString().toLowerCase() ?? '';
                  final phone =
                      contact['phone']?.toString().toLowerCase() ?? '';
                  final query = searchQuery.toLowerCase();
                  return name.contains(query) || phone.contains(query);
                }).toList();

                final favorites = filteredContacts
                    .where((c) => c['is_favorite'] == true)
                    .toList();
                final recent = filteredContacts.take(3).toList();

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFieldWidget(),
                      Gap(80.h),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            color: themeHelper.textColor,
                          ),
                          Gap(30.w),
                          Text(
                            "Favorites",
                            style: GoogleFonts.poppins(
                              color: themeHelper.textColor,
                            ),
                          ),
                        ],
                      ),
                      Gap(30.h),
                      ...favorites.map(
                        (contact) => Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: ContactWidget(
                            id: contact["id"],
                            name: contact["name"],
                            number: contact["phone"],
                            isFavourite: contact["is_favorite"],
                            imageUrl: contact["avatar_url"] ?? "",
                          ),
                        ),
                      ),
                      Gap(150.h),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            color: themeHelper.textColor,
                          ),
                          Gap(30.w),
                          Text(
                            "Recently Added",
                            style: GoogleFonts.poppins(
                              color: themeHelper.textColor,
                            ),
                          ),
                        ],
                      ),
                      Gap(30.h),
                      ...recent.map(
                        (contact) => Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: ContactWidget(
                            id: contact["id"],
                            name: contact["name"],
                            number: contact["phone"],
                            isFavourite: contact["is_favorite"],
                            imageUrl: contact["avatar_url"] ?? "",
                          ),
                        ),
                      ),
                      Gap(150.h),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            color: themeHelper.textColor,
                          ),
                          Gap(30.w),
                          Text(
                            "All Contacts",
                            style: GoogleFonts.poppins(
                              color: themeHelper.textColor,
                            ),
                          ),
                        ],
                      ),
                      Gap(30.h),
                      ...filteredContacts.map(
                        (contact) => Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: ContactWidget(
                            id: contact["id"],
                            name: contact["name"],
                            number: contact["phone"],
                            isFavourite: contact["is_favorite"],
                            imageUrl: contact["avatar_url"] ?? "",
                          ),
                        ),
                      ),
                      Gap(200.h),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
