import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/announcement.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://huellassalud.onrender.com/internal",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  AnnouncementService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

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
        },
      };

      print("📤 Enviando datos al servidor: $body");

      final response = await _dio.post("/announcement/create", data: body);

      print("✅ Respuesta del servidor: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data["data"];
        final String? announcementId = data?["idAnnouncement"];

        if (announcementId != null) {
          if (kIsWeb && imageBytes != null) {
            await uploadAnnouncementImageWeb(
              announcementId: announcementId,
              imageBytes: imageBytes,
            );
          } else if (!kIsWeb && imageFile != null) {
            await uploadAnnouncementImageWeb(
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

  Future<void> uploadAnnouncementImageWeb({
    required String announcementId,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      FormData formData;

      if (kIsWeb && imageBytes != null) {
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(
            imageBytes,
            filename: "announcement_$announcementId.png",
          ),
        });
      } else if (!kIsWeb && imageFile != null) {
        formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
        });
      } else {
        throw Exception("⚠️ Debes proporcionar una imagen para enviar.");
      }

      print("📤 Subiendo imagen para anuncio ID: $announcementId...");

      final response = await _dio.post(
        "/avatar-user/ANNOUNCEMENT/$announcementId",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode == 201) {
        print("✅ Imagen subida correctamente");
      } else {
        print("⚠️ Error al subir imagen: ${response.statusCode}");
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final statusCode = e.response?.statusCode;
      print("❌ Error al subir imagen: ${errorData ?? e.message}");
      print("📦 Código de estado: $statusCode");

      if (errorData is Map && errorData.containsKey("message")) {
        print("🧩 Detalle del error: ${errorData["message"]}");
      }

      rethrow;
    }
  }

  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => print("📡 DIO LOG: $obj"),
        ),
      );

      final response = await _dio.get('/announcement/list-announcements');

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data;

        final List<Announcement> activeAnnouncements = results
            .where((item) => item['data']?['status'] == true)
            .map((item) {
              final data = item['data'] ?? {};

              MediaFile? mediaFile;
              if (data['mediaFile'] != null) {
                final mf = data['mediaFile'];
                mediaFile = MediaFile(
                  fileName: mf['fileName'] ?? '',
                  contentType: mf['contentType'] ?? '',
                  attachment: mf['attachment'] ?? '',
                );
              }

              return Announcement(
                idAnnouncement: data['idAnnouncement']?.toString() ?? '',
                description: data['description'] ?? 'Sin Descripción',
                cellPhone: data['cellPhone'] ?? '',
                status: data['status'] ?? false,
                mediaFile: mediaFile,
              );
            })
            .toList();

        print("✅ Solo anuncios activos: ${activeAnnouncements.length}");
        return activeAnnouncements;
      } else {
        throw Exception('Failed to load announcements');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
