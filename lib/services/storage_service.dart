// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload user profile image
  Future<String> uploadProfileImage({
    required String uid,
    required String filePath,
  }) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: $filePath');
      }

      // Create storage reference
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');

      // Upload task
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Return download URL
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print('FirebaseStorageException during upload: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic error uploading file: $e');
      rethrow;
    }
  }
}

