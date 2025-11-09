// lib/domain/providers/upload_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_preview_studio/data/repositories/image_repository.dart';
import 'package:ai_preview_studio/data/repositories/image_repository_impl.dart';
import 'package:ai_preview_studio/data/services/ai_service.dart';
import 'package:ai_preview_studio/domain/usecases/generate_image_usecase.dart';
import 'package:ai_preview_studio/domain/controllers/upload_controller.dart'; 

// --- 1. PROVEEDORES DE DATOS Y SERVICIOS ---

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final aiServiceProvider = Provider((ref) => AIService());


// --- 2. PROVEEDOR DEL REPOSITORIO ---

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final aiService = ref.watch(aiServiceProvider);
  
  return ImageRepositoryImpl(supabase, aiService); 
});


// --- 3. PROVEEDOR DEL CASO DE USO ---

final generateImageUseCaseProvider = Provider((ref) {
  final repository = ref.watch(imageRepositoryProvider);
  return GenerateImageUseCase(repository);
});


// --- 4. PROVEEDOR DEL CONTROLADOR (El que usa la UI) ---

final uploadControllerProvider = ChangeNotifierProvider<UploadController>((ref) {
  final useCase = ref.watch(generateImageUseCaseProvider);
  
  return UploadController(useCase); 
});