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
      onNotification: (scrollInfo) {
        if (onLoadMore != null &&
            !isLoading &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
          onLoadMore!();
        }
        return false;
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: announcements.length + (isLoading && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == announcements.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
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
