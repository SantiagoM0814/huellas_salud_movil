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
    return SizedBox(
      width: 170,
      height: 220,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen o ícono por defecto
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Center(child: _buildAnnouncementImage(announcement)),
                ),

                const SizedBox(height: 8),

                // Descripción
                Expanded(
                  child: Text(
                    announcement.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 4),

                // Teléfono
                Text(
                  announcement.cellPhone.isNotEmpty
                      ? '📞 ${announcement.cellPhone}'
                      : 'Sin teléfono',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                // Estado (activo/inactivo)
                Text(
                  announcement.status ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: announcement.status ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementImage(Announcement announcement) {
    if (announcement.mediaFile != null &&
        announcement.mediaFile!.attachment.isNotEmpty) {
      try {
        final bytes = base64Decode(announcement.mediaFile!.attachment);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            height: 120,
            width: 120,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        return const Icon(Icons.image_not_supported, size: 60, color: Colors.grey);
      }
    }
    return const Icon(Icons.image_not_supported, size: 60, color: Colors.grey);
  }
}
