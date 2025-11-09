import 'dart:typed_data';
import 'dart:io';
import 'package:ai_preview_studio/presentation/pages/vr_view_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ResultPage extends StatelessWidget {
  final Uint8List imageData;
  final String prompt;

  const ResultPage({
    super.key,
    required this.imageData,
    required this.prompt,
  });

  /// 🔹 Guarda la imagen generada por DALL·E 3 en el almacenamiento local
  Future<String> _saveImageToDisk(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/generated_image.png';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        elevation: 4,
        title: const Text(
          "Resultado generado",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Imagen generada con IA",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Imagen generada
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.memory(
                        imageData,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Prompt
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.purple.shade200,
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      "Prompt: $prompt",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.purple.shade800,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🚀 Botón de Realidad Aumentada
                  ElevatedButton.icon(
                    icon: const Icon(Icons.vrpano_outlined),
                    label: const Text("Ver en Realidad Aumentada"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Preparando imagen para Realidad Aumentada..."),
                        ),
                      );

                      final localPath = await _saveImageToDisk(imageData);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VRViewPage(imageBytes: imageData),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  // 🔙 Botón Volver
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Volver a Editar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
