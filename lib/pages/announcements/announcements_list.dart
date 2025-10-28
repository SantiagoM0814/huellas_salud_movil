import 'package:flutter/material.dart';
import 'package:huellas_salud_movil/services/announcement_services.dart';

class AnnouncementsListPage extends StatefulWidget {
  const AnnouncementsListPage({Key? key}) : super(key: key);

  @override
  State<AnnouncementsListPage> createState() => _AnnouncementsListPageState();
}

class _AnnouncementsListPageState extends State<AnnouncementsListPage> {
  final AnnouncementService _service = AnnouncementService();
  bool _isLoading = true;
  List<dynamic> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.listAnnouncements();
      setState(() => _announcements = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al obtener anuncios: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAnnouncement(String idAnnouncement) async {
    try {
      await _service.deleteAnnouncement(idAnnouncement: idAnnouncement);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Anuncio eliminado correctamente")),
      );
      await _loadAnnouncements();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al eliminar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de Anuncios"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? const Center(child: Text("No hay anuncios registrados"))
              : RefreshIndicator(
                  onRefresh: _loadAnnouncements,
                  child: ListView.builder(
                    itemCount: _announcements.length,
                    itemBuilder: (context, index) {
                      final item = _announcements[index];
                      final id = item["idAnnouncement"] ?? "sin id";
                      final description = item["description"] ?? "Sin descripción";
                      final phone = item["cellPhone"] ?? "Sin teléfono";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          title: Text(description,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("📞 $phone"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAnnouncement(id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _loadAnnouncements,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
