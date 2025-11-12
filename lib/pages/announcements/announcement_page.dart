import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../services/announcement_services.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({Key? key}) : super(key: key);

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _cellPhoneController = TextEditingController();
  final AnnouncementService _announcementService = AnnouncementService();

  Uint8List? _webImageBytes;
  io.File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _webImageBytes = bytes);
      } else {
        setState(() => _selectedImage = io.File(picked.path));
      }
    }
  }

  Widget _buildPreviewImage(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final bool hasImage =
        (kIsWeb && _webImageBytes != null) || (!kIsWeb && _selectedImage != null);

    final imageWidget = (kIsWeb && _webImageBytes != null)
        ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
        : (!kIsWeb && _selectedImage != null)
            ? Image.file(_selectedImage!, fit: BoxFit.cover)
            : Image.asset('assets/img/images/placeholder.png', fit: BoxFit.contain);

    return GestureDetector(
      onTap: _pickImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: hasImage ? 200 : 120,
          width: double.infinity,
          color: Colors.grey[200],
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageWidget,
              if (hasImage)
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black38],
                    ),
                  ),
                  child: const Text(
                    "Cambiar imagen",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Center(
                  child: Text(
                    "Seleccionar imagen",
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final id = await _announcementService.createAnnouncement(
        description: _descriptionController.text.trim(),
        cellPhone: _cellPhoneController.text.trim(),
        imageFile: _selectedImage,
        imageBytes: _webImageBytes,
      );

      if (id != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Anuncio creado exitosamente")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("❌ Error al crear anuncio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al crear el anuncio")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FB),
      body: SafeArea(
        child: Stack(
          children: [
            // 🟣 Contenido más centrado
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 140, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Crear anuncio",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 8,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildPreviewImage(context),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: "Descripción del anuncio",
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Campo requerido" : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _cellPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Teléfono de contacto",
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Campo requerido" : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔙 Flecha de regreso
            Positioned(
              top: 16,
              left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),

      // 🟣 Barra inferior tipo navbar refinada
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _createAnnouncement,
            icon: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white, size: 20),
            label: Text(
              _isLoading ? "Publicando..." : "Publicar anuncio",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
