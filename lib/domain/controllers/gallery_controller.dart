// lib/domain/controllers/gallery_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_preview_studio/data/models/generated_image_model.dart';
import 'package:ai_preview_studio/data/repositories/gallery_repository.dart';

/// Estado de la galería
class GalleryState {
  final List<GeneratedImageModel> images;
  final bool isLoading;
  final String? errorMessage;

  GalleryState({
    this.images = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GalleryState copyWith({
    List<GeneratedImageModel>? images,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GalleryState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller de la galería
class GalleryController extends StateNotifier<GalleryState> {
  final GalleryRepository _repository;

  GalleryController(this._repository) : super(GalleryState());

  /// Cargar imágenes del usuario
  Future<void> loadImages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final images = await _repository.getUserImages();
      state = state.copyWith(
        images: images,
        isLoading: false,
      );
      print('✅ ${images.length} imágenes cargadas');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error cargando imágenes: $e',
      );
      print('⚠️ Error en loadImages: $e');
    }
  }

  /// Eliminar imagen
  Future<bool> deleteImage(int imageId) async {
    try {
      await _repository.deleteImage(imageId);
      
      // Actualizar estado local
      state = state.copyWith(
        images: state.images.where((img) => img.id != imageId).toList(),
      );
      
      print('✅ Imagen $imageId eliminada');
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error eliminando imagen: $e',
      );
      print('⚠️ Error en deleteImage: $e');
      return false;
    }
  }

  /// Buscar por prompt
  Future<void> searchByPrompt(String query) async {
    if (query.isEmpty) {
      loadImages();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final images = await _repository.searchByPrompt(query);
      state = state.copyWith(
        images: images,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error buscando: $e',
      );
    }
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}