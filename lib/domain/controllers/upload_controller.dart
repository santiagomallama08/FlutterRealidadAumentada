import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../usecases/generate_image_usecase.dart';

class UploadController extends ChangeNotifier {
  final GenerateImageUseCase generateImageUseCase;

  bool isLoading = false;
  Uint8List? generatedImage;
  String? errorMessage;

  UploadController(this.generateImageUseCase);

  Future<void> generate(
    String prompt,
    Uint8List baseImage, {
    required String mimeType,
  }) async {
    errorMessage = null;
    generatedImage = null;

    try {
      isLoading = true;
      notifyListeners();

      // 🚀 Llamada al caso de uso
      generatedImage = await generateImageUseCase.call(
        prompt,
        baseImage,
        mimeType: mimeType,
      );

      if (generatedImage != null) {
        debugPrint("✅ Imagen generada y lista para mostrar.");
      }

    } catch (e, stackTrace) {
      debugPrint("❌ Error capturado en UploadController:");
      debugPrint("➡️ Tipo: ${e.runtimeType}");
      debugPrint("➡️ Mensaje: $e");
      debugPrint("➡️ Stacktrace: $stackTrace");

      errorMessage = _parseError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🧠 Analiza y traduce el error a un mensaje más útil
  String _parseError(dynamic e) {
    final msg = e.toString();

    // 🔹 Error de Supabase
    if (msg.contains("StorageException")) {
      if (msg.contains("Bucket not found")) {
        return "⚠️ No se encontró el bucket en Supabase. Verifica el nombre en tu consola.";
      } else if (msg.contains("Invalid credentials")) {
        return "⚠️ Error de autenticación. Vuelve a iniciar sesión.";
      } else {
        return "⚠️ Error de almacenamiento en Supabase: $msg";
      }
    }

    // 🔹 Error de OpenAI
    if (msg.contains("OpenAI Falló") || msg.contains("DALL-E")) {
      if (msg.contains("safety system")) {
        return "🚫 El prompt fue bloqueado por el sistema de seguridad de OpenAI. Intenta con una descripción más neutra.";
      } else if (msg.contains("unsupported mimetype")) {
        return "⚠️ Formato de imagen no admitido. Usa una imagen PNG o JPG.";
      } else if (msg.contains("network")) {
        return "🌐 Error de conexión con OpenAI. Verifica tu Internet.";
      } else {
        return "⚠️ Error de comunicación con OpenAI: $msg";
      }
    }

    // 🔹 Error genérico de red
    if (msg.contains("SocketException") || msg.contains("Connection refused")) {
      return "🌐 No hay conexión con el servidor. Revisa tu red.";
    }

    // 🔹 Error genérico
    return "❗ Error inesperado: $msg";
  }
}
