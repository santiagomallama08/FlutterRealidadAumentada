// lib/data/repositories/gallery_repository.dart

import 'package:ai_preview_studio/data/models/generated_image_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GalleryRepository {
  final SupabaseClient _supabase;

  GalleryRepository(this._supabase);

  /// Obtener todas las imágenes del usuario actual
  Future<List<GeneratedImageModel>> getUserImages() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase
          .from('generated_images')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => GeneratedImageModel.fromJson(json))
          .toList();
    } catch (e) {
      print('⚠️ Error en getUserImages: $e');
      rethrow;
    }
  }

  /// Eliminar imagen por ID
  Future<void> deleteImage(int imageId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Eliminar solo si pertenece al usuario
      await _supabase
          .from('generated_images')
          .delete()
          .eq('id', imageId)
          .eq('user_id', userId);

      print('✅ Imagen $imageId eliminada');
    } catch (e) {
      print('⚠️ Error en deleteImage: $e');
      rethrow;
    }
  }

  /// Obtener imagen por ID
  Future<GeneratedImageModel?> getImageById(int imageId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase
          .from('generated_images')
          .select()
          .eq('id', imageId)
          .eq('user_id', userId)
          .single();

      return GeneratedImageModel.fromJson(response);
    } catch (e) {
      print('⚠️ Error en getImageById: $e');
      return null;
    }
  }

  /// Buscar imágenes por prompt
  Future<List<GeneratedImageModel>> searchByPrompt(String query) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase
          .from('generated_images')
          .select()
          .eq('user_id', userId)
          .ilike('prompt_used', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => GeneratedImageModel.fromJson(json))
          .toList();
    } catch (e) {
      print('⚠️ Error en searchByPrompt: $e');
      rethrow;
    }
  }
}