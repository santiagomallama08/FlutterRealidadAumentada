// lib/data/repositories/image_repository_impl.dart

import 'dart:typed_data';
import 'package:ai_preview_studio/data/repositories/image_repository.dart';
import 'package:ai_preview_studio/domain/entities/generated_image_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ai_service.dart';
import '../../core/constants/app_constants.dart'; // Tu archivo de constantes

class ImageRepositoryImpl implements ImageRepository {
  final SupabaseClient supabase;
  final AIService aiService;

  ImageRepositoryImpl(this.supabase, this.aiService);

  @override
  // 💥 Retorna los bytes, tal como se definió en la interfaz corregida
  Future<Uint8List?> generateImage(
    String prompt, 
    Uint8List image, 
    {required String mimeType} 
  ) async {
    // 1. Generar los bytes de la nueva imagen
    final generatedBytes = await aiService.generateImage(
      prompt: prompt, 
      baseImage: image,
      mimeType: mimeType, 
    );

    if (generatedBytes == null) return null;

    // 2. Subir la imagen y obtener la URL
    final imageUrl = await _uploadToSupabase(generatedBytes);

    // 3. Crear la entidad para el registro en la base de datos
    final generatedEntity = GeneratedImageEntity(
      userId: supabase.auth.currentUser?.id ?? '',
      imageUrl: imageUrl, // generated_url en DB
      prompt: prompt,    // prompt_used en DB
      strength: AppConstants.defaultStrength, 
      createdAt: DateTime.now(),
    );
    
    // 4. Guardar la entidad en la tabla 'generated_images'
    await saveGeneratedImage(generatedEntity); 

    // 5. 💥 RETORNAR LOS BYTES para que el Controller los muestre en la UI
    return generatedBytes;
  }

  Future<String> _uploadToSupabase(Uint8List imageBytes) async {
    // Usando 'generated_images' bucket de Supabase
    final fileName = 'generated_${DateTime.now().millisecondsSinceEpoch}.png';
    await supabase.storage
        .from(AppConstants.supabaseBucketGenerated) // Asumiendo que esta constante apunta a 'generated_images'
        .uploadBinary(fileName, imageBytes);
    return supabase.storage.from(AppConstants.supabaseBucketGenerated).getPublicUrl(fileName);
  }

  @override
  Future<void> saveGeneratedImage(GeneratedImageEntity image) async {
    // Mapeo a la tabla 'generated_images'
    await supabase.from('generated_images').insert({
      'user_id': image.userId,
      'generated_url': image.imageUrl,
      'prompt_used': image.prompt,
      'strength': image.strength,
      'model': AppConstants.stabilityModel, 
    });
  }
}