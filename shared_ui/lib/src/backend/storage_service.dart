import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload an image and return the public URL
  Future<String> uploadImage(String bucketName, String path, File file) async {
    await _supabase.storage.from(bucketName).upload(
      path,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    
    return _supabase.storage.from(bucketName).getPublicUrl(path);
  }

  // Delete an image
  Future<void> deleteImage(String bucketName, List<String> paths) async {
    await _supabase.storage.from(bucketName).remove(paths);
  }
}
