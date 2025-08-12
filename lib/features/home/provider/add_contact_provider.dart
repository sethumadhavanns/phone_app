import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_app/features/home/controller/add_contact_controller.dart';

final addContactControllerProvider =
    StateNotifierProvider<AddContactController, AddContactState>((ref) {
      return AddContactController();
    });
// Add this to your providers file
final searchQueryProvider = StateProvider<String>((ref) => '');
