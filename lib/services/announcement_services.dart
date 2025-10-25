import 'package:dio/dio.dart';

class AnnouncementService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://huellassalud.onrender.com/internal/announcement/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    try {
      final response = await _dio.get('list-announcements');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error al obtener anuncios');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Error de red: ${e.message}');
    }
  }

  Future<void> createAnnouncement({
    required String user,
    required String petName,
    required String message,
    required String imageUrl,
  }) async {
    try {
      await _dio.post('create', data: {
        'user': user,
        'petName': petName,
        'message': message,
        'imageUrl': imageUrl,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Error al crear anuncio');
    }
  }
}