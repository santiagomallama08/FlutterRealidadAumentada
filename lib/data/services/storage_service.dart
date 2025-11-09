// lib/data/services/storage_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String bucketName = 'images';

  /// 🔹 Sube una imagen al bucket y devuelve la URL pública
  Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = const Uuid().v4();
      final filePath = 'uploads/$fileName.jpg';

      await _client.storage
          .from(bucketName)
          .upload(filePath, imageFile, fileOptions: const FileOptions(upsert: true));

      final publicUrl = _client.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }
}
