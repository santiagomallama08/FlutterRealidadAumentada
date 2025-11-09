// lib/domain/providers/gallery_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_preview_studio/data/repositories/gallery_repository.dart';
import 'package:ai_preview_studio/domain/controllers/gallery_controller.dart';

/// Provider del repositorio
final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepository(Supabase.instance.client);
});

/// Provider del controller
final galleryControllerProvider =
    StateNotifierProvider<GalleryController, GalleryState>((ref) {
  final repository = ref.watch(galleryRepositoryProvider);
  return GalleryController(repository);
});