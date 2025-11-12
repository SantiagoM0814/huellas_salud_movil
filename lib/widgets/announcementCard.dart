import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: colorScheme.primary.withOpacity(0.1),
        child: Card(
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🖼️ Imagen arriba
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                    image: _buildImageDecoration(announcement),
                  ),
                  child: announcement.mediaFile == null ||
                          announcement.mediaFile!.attachment.isEmpty
                      ? const Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 50)
                      : null,
                ),
                const SizedBox(height: 10),

                // 📝 Descripción
                Text(
                  announcement.description,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // 📞 Teléfono centrado
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text(
                      announcement.cellPhone.isNotEmpty
                          ? announcement.cellPhone
                          : 'Sin teléfono',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DecorationImage? _buildImageDecoration(Announcement announcement) {
    if (announcement.mediaFile != null &&
        announcement.mediaFile!.attachment.isNotEmpty) {
      try {
        final bytes = base64Decode(announcement.mediaFile!.attachment);
        return DecorationImage(
          image: MemoryImage(bytes),
          fit: BoxFit.cover,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
