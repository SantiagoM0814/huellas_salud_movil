import 'dart:io';
import 'package:dio/dio.dart';

class AnnouncementService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://huellassalud.onrender.com',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// 🔹 Crear un anuncio
  Future<void> createAnnouncement({
    required String description,
    required String cellPhone,
    required String nameUserCreated,
    required String emailUserCreated,
    required String roleUserCreated,
  }) async {
    final data = {
      "data": {
        "description": description,
        "cellPhone": cellPhone,
        "status": true,
      }
    };

    try {
      final response = await _dio.post('/internal/announcement/create', data: data);
      print("✅ Anuncio creado: ${response.data}");
    } on DioException catch (e) {
      print("❌ Error al crear anuncio: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }


  Future<List<dynamic>> listAnnouncements() async {
    try {
      final response = await _dio.get('/internal/announcement/list-announcements');
      print("📋 Anuncios obtenidos correctamente");
      return response.data["data"] ?? [];
    } on DioException catch (e) {
      print("❌ Error al listar anuncios: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }


  Future<void> updateAnnouncement({
    required String idAnnouncement,
    required String description,
    required String cellPhone,
  }) async {
    final data = {
      "data": {
        "idAnnouncement": idAnnouncement,
        "description": description,
        "cellPhone": cellPhone,
      },
      "meta": {
        "lastUpdate": DateTime.now().toIso8601String(),
        "source": "http://localhost:8080/internal/API_PATH",
        "nameUserUpdated": "Usuario Actualizado",
        "emailUserUpdated": "usuario@correo.com",
        "roleUserUpdated": "ADMINISTRADOR"
      }
    };

    try {
      final response = await _dio.put('/internal/announcement/update', data: data);
      print("✅ Anuncio actualizado: ${response.data}");
    } on DioException catch (e) {
      print("❌ Error al actualizar anuncio: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  /// 🔹 Eliminar un anuncio
  Future<void> deleteAnnouncement({required String idAnnouncement}) async {
    final data = {
      "data": {"idAnnouncement": idAnnouncement}
    };

    try {
      final response = await _dio.delete('/internal/announcement/delete', data: data);
      print("🗑️ Anuncio eliminado: ${response.data}");
    } on DioException catch (e) {
      print("❌ Error al eliminar anuncio: ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  Future<void> uploadAnnouncementImage({
  required String announcementId,
  required File imageFile,
  required String token,
}) async {
  final formData = FormData.fromMap({
    "file": await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last),
  });

  await _dio.post(
    '/avatar-user/ANNOUNCEMENT/$announcementId',
    data: formData,
    options: Options(
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      },
    ),
  );
}

}
