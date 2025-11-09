// lib/domain/usecases/generate_image_usecase.dart

import 'dart:typed_data';
import 'package:ai_preview_studio/data/repositories/image_repository.dart';

class GenerateImageUseCase {
  final ImageRepository repository;

  GenerateImageUseCase(this.repository);

  // 💥 CORRECCIÓN 2: baseImage DEBE ser Uint8List (no nulo)
  Future<Uint8List?> call(
    String prompt, 
    Uint8List baseImage, // <-- ¡QUITAR el '?' de aquí!
    {required String mimeType}
  ) async {
    // ...
    // Al llamar al Repositorio, también debe ser no nulo
    return repository.generateImage(
      prompt, 
      baseImage, // <-- Ahora es un Uint8List seguro
      mimeType: mimeType
    );
  }
}