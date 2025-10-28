import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:huellas_salud_movil/services/announcement_services.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _cellPhoneController = TextEditingController();
  final AnnouncementService _service = AnnouncementService();

  // 🔹 Estas dos variables son para manejar la imagen (web + móvil)
  Uint8List? _webImage;
  File? _mobileImage;

  // 🔹 Selector de imagen
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
      } else {
        setState(() => _mobileImage = File(pickedFile.path));
      }
    }
  }

  // 🔹 Vista previa de imagen
  Widget _buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!, height: 150);
    } else if (!kIsWeb && _mobileImage != null) {
      return Image.file(_mobileImage!, height: 150);
    } else {
      return const Icon(Icons.image, size: 100, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Anuncio")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Descripción"),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese una descripción" : null,
              ),
              TextFormField(
                controller: _cellPhoneController,
                decoration: const InputDecoration(labelText: "Teléfono"),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese un teléfono" : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Botón para elegir imagen
              Center(
                child: Column(
                  children: [
                    _buildImagePreview(),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Seleccionar imagen"),
                      onPressed: pickImage,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _service.createAnnouncement(
                      description: _descriptionController.text,
                      cellPhone: _cellPhoneController.text,
                      nameUserCreated: "Juan Pérez",
                      emailUserCreated: "juan@correo.com",
                      roleUserCreated: "ADMINISTRADOR",
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✅ Anuncio creado correctamente"),
                      ),
                    );
                  }
                },
                child: const Text("Crear Anuncio"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
