import 'package:flutter/material.dart';
import '../models/announcement.dart';
import 'announcementCard.dart';

class AnnouncementList extends StatelessWidget {
  final List<Announcement> announcements;
  final Function(Announcement) onAnnouncementTap;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const AnnouncementList({
    super.key,
    required this.announcements,
    required this.onAnnouncementTap,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Detecta cuando se llega al final del scroll y carga más
        if (onLoadMore != null &&
            !isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore!();
        }
        return false;
      },
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // dos columnas
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75, // ajusta proporción según el diseño
              ),
              padding: const EdgeInsets.all(8),
              itemCount: announcements.length + (isLoading && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Mostrar spinner de carga si hay más elementos cargando
                if (index == announcements.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final announcement = announcements[index];
                return AnnouncementCard(
                  announcement: announcement,
                  onTap: () => onAnnouncementTap(announcement),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
