import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref().child('profile_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadVoiceNote(String chatId, File file) async {
    final ref = _storage.ref().child('voice_notes/$chatId/${DateTime.now().millisecondsSinceEpoch}.m4a');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadStatusMedia(String uid, File file, String ext) async {
    final ref = _storage.ref().child('statuses/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
