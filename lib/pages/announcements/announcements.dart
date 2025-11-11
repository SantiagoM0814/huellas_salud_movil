import 'package:flutter/material.dart';
import '../../models/announcement.dart';
import '../../services/announcement_services.dart';
import '../../widgets/announcementList.dart';
import 'announcement_page.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final AnnouncementService _service = AnnouncementService();

  List<Announcement> _announcements = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements({bool loadMore = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final newAnnouncements = await _service.fetchAnnouncements();

      setState(() {
        if (loadMore) {
          _announcements.addAll(newAnnouncements);
        } else {
          _announcements = newAnnouncements;
        }

        _hasMore = newAnnouncements.length == _limit;
        if (_hasMore) _offset += _limit;
      });
    } catch (e) {
      debugPrint('Error cargando anuncios: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onAnnouncementTap(Announcement announcement) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Anuncio: ${announcement.description}')),
    );
  }

  // 🟣 Ir a la página de creación de anuncios
  Future<void> _goToCreateAnnouncement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnnouncementPage()),
    );

    // Si se creó un anuncio, recargamos la lista
    if (result == true && mounted) {
      _fetchAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _announcements.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnnouncementList(
              announcements: _announcements,
              onAnnouncementTap: _onAnnouncementTap,
              isLoading: _isLoading,
              hasMore: _hasMore,
              onLoadMore: () => _fetchAnnouncements(loadMore: true),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: _goToCreateAnnouncement, // ya no hay postFrameCallback
        child: const Icon(Icons.add),
      ),
    );
  }
}
