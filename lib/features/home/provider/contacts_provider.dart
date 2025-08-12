import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final contactsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const Stream.empty();

    return Supabase.instance.client
        .from('contacts')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
  },
);

final contactOperationsProvider =
    StateNotifierProvider<ContactOperations, AsyncValue<void>>((ref) {
      return ContactOperations(ref);
    });

class ContactOperations extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ContactOperations(this.ref) : super(const AsyncValue.data(null));

  Future<void> deleteContact(String contactId) async {
    state = const AsyncValue.loading();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await Supabase.instance.client
          .from('contacts')
          .delete()
          .eq('id', contactId)
          .eq('user_id', user.id);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> toggleFavorite(String contactId, bool currentStatus) async {
    state = const AsyncValue.loading();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await Supabase.instance.client
          .from('contacts')
          .update({'is_favorite': !currentStatus})
          .eq('id', contactId)
          .eq('user_id', user.id);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // NEW: Call and Message functions
  Future<void> makePhoneCall(String phoneNumber, BuildContext context) async {
    try {
      // Clean the phone number (remove spaces, dashes, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        log("notworking");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone dialer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> sendSMS(String phoneNumber, BuildContext context) async {
    try {
      // Clean the phone number (remove spaces, dashes, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri smsUri = Uri(scheme: 'sms', path: cleanNumber);

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch SMS app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening SMS: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
