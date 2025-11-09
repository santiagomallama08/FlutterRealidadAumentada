import 'package:ai_preview_studio/data/repositories/image_repository.dart';
import '../entities/generated_image_entity.dart';

class SaveGeneratedImageUseCase {
  final ImageRepository repository;
  SaveGeneratedImageUseCase(this.repository);

  Future<void> call(GeneratedImageEntity image) async {
    await repository.saveGeneratedImage(image);
  }
}
