import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:huellas_salud_movil/services/announcement_services.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final AnnouncementService _announcementService = AnnouncementService();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> announcements = [];
  bool isLoading = false;

  // Controladores para el formulario
  final TextEditingController userController = TextEditingController();
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    setState(() => isLoading = true);
    try {
      final data = await _announcementService.fetchAnnouncements();
      setState(() => announcements = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar anuncios: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> createAnnouncement() async {
    if (userController.text.isEmpty ||
        petNameController.text.isEmpty ||
        messageController.text.isEmpty ||
        selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    try {
      await _announcementService.createAnnouncement(
        user: userController.text,
        petName: petNameController.text,
        message: messageController.text,
        imageUrl: selectedImage!.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Anuncio creado exitosamente.')),
      );

      Navigator.pop(context);
      fetchAnnouncements(); // refresca lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al crear el anuncio: $e')),
      );
    }
  }

  void showCreateAnnouncementModal() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Crear anuncio'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: 'Usuario'),
              ),
              TextField(
                controller: petNameController,
                decoration: const InputDecoration(labelText: 'Nombre de mascota'),
              ),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mensaje'),
              ),
              const SizedBox(height: 10),
              selectedImage != null
                  ? Image.file(selectedImage!, height: 120)
                  : const Text('No hay imagen seleccionada'),
              TextButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar imagen'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: createAnnouncement,
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  void showListAnnouncementsModal() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Anuncios publicados'),
        content: SizedBox(
          width: double.maxFinite,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : announcements.isEmpty
                  ? const Text('No hay anuncios disponibles.')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final item = announcements[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.pets, color: Colors.blue),
                            title: Text(item['petName'] ?? 'Sin nombre'),
                            subtitle: Text(item['message'] ?? ''),
                            trailing: Text(item['user'] ?? 'Anon'),
                          ),
                        );
                      },
                    ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Anuncios'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : announcements.isEmpty
                ? const Text('No hay anuncios disponibles.')
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final item = announcements[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.pets, color: Colors.teal),
                          title: Text(item['petName'] ?? 'Mascota'),
                          subtitle: Text(item['message'] ?? ''),
                          trailing: Text(item['user'] ?? 'Anon'),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "crear",
            onPressed: showCreateAnnouncementModal,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo anuncio'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "ver",
            onPressed: showListAnnouncementsModal,
            icon: const Icon(Icons.list),
            label: const Text('Ver todos'),
          ),
        ],
      ),
    );
  }
}