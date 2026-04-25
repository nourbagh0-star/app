import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRepository {
  final SupabaseClient _supabase;

  StorageRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  static const String _shopBucket = 'barber shop';
  static const String _avatarBucket = 'customer';

  // ── Upload shop photo ────────────────────────────────────────────
  /// Uploads [bytes] to Supabase, returns the public URL.
  Future<String> uploadShopPhoto(String shopId, Uint8List bytes, String ext) async {
    final path = 'shop-photos/$shopId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _supabase.storage.from(_shopBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: 'image/$ext',
          ),
        );

    return _supabase.storage.from(_shopBucket).getPublicUrl(path);
  }

  // ── Upload staff photo ────────────────────────────────────────────
  Future<String> uploadStaffPhoto(String shopId, Uint8List bytes, String ext) async {
    final path = 'staff-photos/$shopId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _supabase.storage.from(_shopBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: 'image/$ext',
          ),
        );

    return _supabase.storage.from(_shopBucket).getPublicUrl(path);
  }

  // ── Upload portfolio photo ─────────────────────────────────────────
  Future<String> uploadPortfolioPhoto(String barberId, Uint8List bytes, String ext) async {
    final path = 'portfolio-photos/$barberId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _supabase.storage.from(_shopBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: 'image/$ext',
          ),
        );

    return _supabase.storage.from(_shopBucket).getPublicUrl(path);
  }

  // ── Upload avatar ────────────────────────────────────────────────
  Future<String> uploadAvatar(String userId, Uint8List bytes, String ext, {String bucket = _avatarBucket}) async {
    final path = 'avatars/$userId/avatar.$ext';

    await _supabase.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: 'image/$ext',
          ),
        );

    final baseUrl = _supabase.storage.from(bucket).getPublicUrl(path);
    return '$baseUrl?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  // ── Delete files ─────────────────────────────────────────────────
  Future<void> deleteShopPhoto(String shopId, String url) async {
    // Extract path from URL
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    // path is everything after the bucket name in the URL segments
    final bucketIndex = segments.indexOf(_shopBucket);
    if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
      final filePath = segments.sublist(bucketIndex + 1).join('/');
      await _supabase.storage.from(_shopBucket).remove([filePath]);
    }
  }

  Future<void> deletePortfolioPhoto(String url) async {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf(_shopBucket);
    if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
      final filePath = segments.sublist(bucketIndex + 1).join('/');
      await _supabase.storage.from(_shopBucket).remove([filePath]);
    }
  }
}
