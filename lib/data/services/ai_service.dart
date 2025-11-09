// lib/data/services/ai_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';

/// Procesamiento de imagen (1024x1024 con transparencia RGBA)
Future<Uint8List> _processImageInIsolate(Uint8List baseImage) async {
  final decoded = img.decodeImage(baseImage);
  if (decoded == null) throw Exception("No se pudo decodificar la imagen.");

  // Redimensionar a 1024x1024
  final resized = img.copyResize(decoded, width: 1024, height: 1024);
  
  // CRÍTICO: Forzar conversión a RGBA (4 canales con alpha)
  final rgba = resized.convert(numChannels: 4, alpha: 255);
  
  // Asegurar que todos los píxeles tengan canal alpha
  for (int y = 0; y < rgba.height; y++) {
    for (int x = 0; x < rgba.width; x++) {
      final pixel = rgba.getPixel(x, y);
      // Si no tiene alpha, agregarlo (totalmente opaco)
      if (pixel.a == 0) {
        rgba.setPixelRgba(x, y, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), 255);
      }
    }
  }
  
  return Uint8List.fromList(img.encodePng(rgba, level: 3)); // Menos compresión = más rápido
}

/// Crear máscara con área central editable (círculo grande en el centro)
Future<Uint8List> _createEditableMask(int _) async {
  // Crear imagen RGBA (4 canales)
  final mask = img.Image(width: 1024, height: 1024, numChannels: 4);
  
  // Llenar con blanco opaco (no editar)
  for (int y = 0; y < 1024; y++) {
    for (int x = 0; x < 1024; x++) {
      mask.setPixelRgba(x, y, 255, 255, 255, 255); // Blanco opaco
    }
  }
  
  // Centro transparente = área editable (radio grande)
  final centerX = 512;
  final centerY = 512;
  final radius = 480; // Casi toda la imagen
  
  for (int y = 0; y < 1024; y++) {
    for (int x = 0; x < 1024; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      final distance = (dx * dx + dy * dy);
      
      if (distance < radius * radius) {
        // Transparente = editable (negro con alpha 0)
        mask.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  
  return Uint8List.fromList(img.encodePng(mask, level: 3)); // Menos compresión
}

class AIService {
  final String? _openaiKey = dotenv.env['OPENAI_API_KEY'];

  /// 🎨 Genera/edita imagen usando DALL-E 2 (SÍ usa imagen base)
  Future<Uint8List?> generateImage({
    required String prompt,
    required Uint8List baseImage,
    required String mimeType,
  }) async {
    if (_openaiKey == null || _openaiKey!.isEmpty) {
      throw Exception("❌ OPENAI_API_KEY no configurada en .env");
    }

    try {
      // 1) Traducir y optimizar prompt
      print("🧠 Traduciendo prompt...");
      final translator = GoogleTranslator();
      final translated =
          (await translator.translate(prompt, from: 'es', to: 'en')).text;
      
      final optimizedPrompt = _optimizePromptForDalle(translated);
      print("🗣️ Prompt optimizado: $optimizedPrompt");

      // 2) Procesar imagen base (DALL-E 2 requiere PNG RGBA 1024x1024)
      print("🖼️ Procesando imagen base...");
      final processedImage = await compute(_processImageInIsolate, baseImage);

      // 3) Crear máscara (área editable)
      print("🎭 Creando máscara...");
      final maskBytes = await compute(_createEditableMask, 1024);

      // 4) Editar con DALL-E 2
      return await _editWithDalle2(optimizedPrompt, processedImage, maskBytes);
    } catch (e, stack) {
      print("⚠️ Error en generateImage(): $e");
      print(stack);
      return null;
    }
  }

  /// Optimizar prompt según el tipo de contenido
  String _optimizePromptForDalle(String prompt) {
    final text = prompt.toLowerCase();
    
    if (text.contains('tattoo') || text.contains('tatuaje')) {
      return "A hyper-realistic photograph with a detailed black ink tattoo of $prompt, professional tattoo art, highly detailed skin texture, natural lighting";
    } else if (text.contains('furniture') || text.contains('mueble')) {
      return "An interior photograph featuring $prompt, modern design, natural lighting, photorealistic, professional interior photography";
    } else if (text.contains('add') || text.contains('put')) {
      return "A photorealistic photograph featuring $prompt, highly detailed, professional quality, natural lighting";
    } else {
      return "A photorealistic image with $prompt, highly detailed, professional photography, natural lighting";
    }
  }

  /// Edición con DALL-E 2 usando /images/edits (con reintentos)
  Future<Uint8List?> _editWithDalle2(
    String prompt,
    Uint8List imageBytes,
    Uint8List maskBytes,
  ) async {
    // Intentar hasta 3 veces si hay error 500
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        if (attempt > 1) {
          print("🔄 Reintento $attempt/3...");
          await Future.delayed(Duration(seconds: 2 * attempt));
        }
        
        print("🚀 Editando con DALL-E 2 (usando imagen base)...");
        
        // Validar tamaños ANTES de enviar
        print("   Imagen: ${imageBytes.length} bytes");
        print("   Máscara: ${maskBytes.length} bytes");
        
        if (imageBytes.length > 4 * 1024 * 1024) {
          throw Exception("Imagen demasiado grande (máx 4MB)");
        }
        
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.openai.com/v1/images/edits'),
        );

        request.headers.addAll({
          "Authorization": "Bearer $_openaiKey",
        });

        // Imagen original (REQUERIDA)
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.png',
          contentType: MediaType('image', 'png'),
        ));

        // Máscara (área transparente = editable)
        request.files.add(http.MultipartFile.fromBytes(
          'mask',
          maskBytes,
          filename: 'mask.png',
          contentType: MediaType('image', 'png'),
        ));

        // Parámetros
        request.fields.addAll({
          'model': 'dall-e-2',
          'prompt': prompt,
          'n': '1',
          'size': '1024x1024',
          'response_format': 'b64_json',
        });

        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final b64 = data['data']?[0]?['b64_json'];
          
          if (b64 == null) {
            throw Exception("Respuesta vacía de OpenAI");
          }
          
          print("✅ Imagen editada correctamente (usó imagen base)");
          return base64Decode(b64);
        } else if (response.statusCode == 500 && attempt < 3) {
          // Error 500: reintentar
          print("⚠️ Error 500 del servidor OpenAI, reintentando...");
          continue;
        } else {
          print("❌ Error OpenAI (${response.statusCode}): ${response.body}");
          
          try {
            final error = jsonDecode(response.body);
            final msg = error['error']?['message'] ?? 'Error desconocido';
            throw Exception('OpenAI Error: $msg');
          } catch (_) {
            throw Exception('OpenAI Error ${response.statusCode}');
          }
        }
      } catch (e) {
        if (attempt == 3) {
          print("⚠️ Error en _editWithDalle2() después de 3 intentos: $e");
          rethrow;
        }
      }
    }
    
    return null;
  }
}

/*
✅ DALL-E 2 CON EDICIÓN DE IMAGEN BASE

DIFERENCIAS vs tu código anterior:
✅ Usa /images/edits (no /images/generations)
✅ Envía imagen base como multipart/form-data
✅ Incluye máscara con área editable
✅ Usa DALL-E 2 (no DALL-E 3)

IMPORTANTE:
- DALL-E 3 NO soporta image-to-image
- DALL-E 2 SÍ usa la imagen base con /edits
- La máscara define QUÉ área modificar

💰 COSTO:
- ~$0.02 por imagen (más barato que otras opciones)

⚠️ LIMITACIONES:
- Menos preciso que SDXL para agregar objetos específicos
- Puede cambiar más de lo esperado
- Resultados variables

🎯 RECOMENDACIÓN:
1. Prueba esto (ya lo tienes pagado)
2. Si no funciona bien → Replicate $10 (solución profesional)
*/