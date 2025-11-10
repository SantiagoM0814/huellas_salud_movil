import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AnnouncementService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://huellassalud.onrender.com"),
  );

  // 🟣 Crear anuncio
  Future<String?> createAnnouncement({
    required String description,
    required String cellPhone,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {

      final body = {
        "data": {
          "description": description,
          "cellPhone": cellPhone,
          "status": true,
        }
      };

      print("📤 Enviando datos al servidor: $body");

      final response = await _dio.post(
        "/internal/announcement/create",
        data: body,
      );

      print("✅ Respuesta del servidor: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data["data"];
        final String? announcementId = data?["idAnnouncement"];


        if (announcementId != null) {
          if (kIsWeb && imageBytes != null) {
            await uploadAnnouncementImageWeb(
              announcementId: announcementId,
              bytes: imageBytes,
            );
          } else if (!kIsWeb && imageFile != null) {
            await uploadAnnouncementImage(
              announcementId: announcementId,
              imageFile: imageFile,
            );
          }
        }

        return announcementId;
      } else {
        print("⚠️ Error al crear anuncio: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      print("❌ Error en createAnnouncement: ${e.response?.data}");
      rethrow;
    }
  }

  // 🟣 Subir imagen (Android/iOS)
  Future<void> uploadAnnouncementImage({
    required String announcementId,
    required File imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        "fileUpload": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      print("📸 Subiendo imagen para anuncio ID: $announcementId");

      final response = await _dio.post(
        "/internal/avatar-user/announcement/$announcementId",
        data: formData,
      );

      if (response.statusCode == 200) {
        print("✅ Imagen subida correctamente");
      } else {
        print("⚠️ Error al subir imagen: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("❌ Error al subir imagen: ${e.response?.data}");
      rethrow;
    }
  }

  // 🟣 Subir imagen (Web)
  Future<void> uploadAnnouncementImageWeb({
    required String announcementId,
    required Uint8List bytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        "fileUpload": MultipartFile.fromBytes(
          bytes,
          filename: "announcement_$announcementId.png",
        ),
      });

      print("🌐 Subiendo imagen (Web) para anuncio ID: $announcementId");

      final response = await _dio.post(
        "/internal/avatar-user/announcement/$announcementId",
        data: formData,
      );

      if (response.statusCode == 200) {
        print("✅ Imagen subida correctamente (Web)");
      } else {
        print("⚠️ Error al subir imagen en Web: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("❌ Error al subir imagen Web: ${e.response?.data}");
      rethrow;
    }
  }

  // 🟣 Listar anuncios
  Future<List<Map<String, dynamic>>> listAnnouncements() async {
    try {
      final response =
          await _dio.get("/internal/announcement/list-announcements");

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> dataList = response.data;

        return dataList.map<Map<String, dynamic>>((item) {
          final data = item["data"] ?? {};
          final meta = item["meta"] ?? {};

          return {
            ...data,
            "nameUserCreated": meta["nameUserCreated"],
            "emailUserCreated": meta["emailUserCreated"],
            "roleUserCreated": meta["roleUserCreated"],
          };
        }).toList();
      }

      print("⚠️ Respuesta inesperada: ${response.statusCode}");
      return [];
    } on DioException catch (e) {
      print("❌ Error listAnnouncements: ${e.response?.data}");
      return [];
    }
  }
}
