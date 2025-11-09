// lib/data/models/generated_image_model.dart

class GeneratedImageModel {
  final int id;
  final DateTime createdAt;
  final String userId;
  final String generatedUrl;
  final String promptUsed;
  final double? strength;
  final String? model;
  final int? originalImageId;

  GeneratedImageModel({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.generatedUrl,
    required this.promptUsed,
    this.strength,
    this.model,
    this.originalImageId,
  });

  /// Crear desde JSON de Supabase
  factory GeneratedImageModel.fromJson(Map<String, dynamic> json) {
    return GeneratedImageModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'] as String,
      generatedUrl: json['generated_url'] as String,
      promptUsed: json['prompt_used'] as String? ?? '',
      strength: json['strength'] != null 
          ? (json['strength'] as num).toDouble() 
          : null,
      model: json['model'] as String?,
      originalImageId: json['original_image_id'] as int?,
    );
  }

  /// Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'generated_url': generatedUrl,
      'prompt_used': promptUsed,
      'strength': strength,
      'model': model,
      'original_image_id': originalImageId,
    };
  }

  /// Copiar con cambios
  GeneratedImageModel copyWith({
    int? id,
    DateTime? createdAt,
    String? userId,
    String? generatedUrl,
    String? promptUsed,
    double? strength,
    String? model,
    int? originalImageId,
  }) {
    return GeneratedImageModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      generatedUrl: generatedUrl ?? this.generatedUrl,
      promptUsed: promptUsed ?? this.promptUsed,
      strength: strength ?? this.strength,
      model: model ?? this.model,
      originalImageId: originalImageId ?? this.originalImageId,
    );
  }
}