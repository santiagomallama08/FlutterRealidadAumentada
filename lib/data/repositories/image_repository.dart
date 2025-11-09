// lib/data/repositories/image_repository.dart
import '../../domain/entities/generated_image_entity.dart';
import 'dart:typed_data';

abstract class ImageRepository {
  
  // 💥 CORRECCIÓN: Retorna Uint8List? para que el UseCase pueda pasarlo al Controller
  Future<Uint8List?> generateImage(
    String prompt, 
    Uint8List image, 
    {required String mimeType} 
  );
  
  Future<void> saveGeneratedImage(GeneratedImageEntity image);
}