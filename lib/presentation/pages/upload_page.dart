import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_preview_studio/domain/providers/upload_provider.dart';
import 'result_page.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;
  String? _selectedImageMimeType;
  final TextEditingController _promptController = TextEditingController();

  /// Permite elegir entre cámara o galería
  Future<void> pickImageOption() async {
    final option = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Selecciona una opción",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.purple),
              title: const Text("Tomar foto con cámara"),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.purple),
              title: const Text("Elegir desde galería"),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (option != null) {
      await pickImage(option);
    }
  }

  /// Carga imagen desde cámara o galería
  Future<void> pickImage(String source) async {
    final ImageSource imageSource =
        source == 'camera' ? ImageSource.camera : ImageSource.gallery;

    final XFile? pickedFile = await _picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _selectedImage = bytes;
        _selectedImageMimeType = pickedFile.mimeType ?? 'image/jpeg';
      });
    }
  }

  Future<void> generateWithAI() async {
    final prompt = _promptController.text;

    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor escribe un prompt.")),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La Edición de DALL-E 2 requiere una imagen base.")),
      );
      return;
    }

    final controller = ref.read(uploadControllerProvider);
    await controller.generate(
      prompt,
      _selectedImage!,
      mimeType: _selectedImageMimeType ?? 'image/jpeg',
    );

    if (controller.errorMessage != null && mounted) {
      if (!controller.errorMessage!.contains("Bucket not found")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${controller.errorMessage}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }

    if (controller.generatedImage != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            imageData: controller.generatedImage!,
            prompt: prompt,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(uploadControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Editar con DALL·E 2",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.purple.shade700,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImageOption,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text(
                    "Seleccionar o Tomar Imagen",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (_selectedImage != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.memory(
                      _selectedImage!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Column(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Ninguna imagen seleccionada",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 28),

                TextField(
                  controller: _promptController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Describe la edición a aplicar",
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                ElevatedButton.icon(
                  onPressed: controller.isLoading ? null : generateWithAI,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    "Editar",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                ),

                const SizedBox(height: 24),

                if (controller.isLoading)
                  Column(
                    children: const [
                      CircularProgressIndicator(color: Colors.purpleAccent),
                      SizedBox(height: 12),
                      Text("Generando imagen, por favor espera..."),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
