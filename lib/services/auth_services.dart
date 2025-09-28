import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://huellassalud.onrender.com/internal/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<bool> recoverPassword(String email) async {
    try {
      // Simulamos una petición a la API
      await Future.delayed(const Duration(seconds: 2));
      
      // En un caso real, aquí harías la petición a tu backend:
      // final response = await _dio.post('auth/recover-password', data: {
      //   'email': email,
      // });
      
      // return response.statusCode == 200;
      
      // Por ahora simulamos éxito siempre
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      // Simulamos una petición a la API
      await Future.delayed(const Duration(seconds: 2));
      
      // En un caso real:
      // final response = await _dio.post('auth/reset-password', data: {
      //   'token': token,
      //   'newPassword': newPassword,
      // });
      
      // return response.statusCode == 200;
      
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}