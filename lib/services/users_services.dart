import 'package:dio/dio.dart';
import '../models/user.dart';

class UserService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://huellassalud.onrender.com/internal/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<List<User>> fetchUsers({int limit = 20, int offset = 0}) async {
    try {
      // Simulamos datos ya que el endpoint puede no estar disponible
      await Future.delayed(const Duration(seconds: 1));
     
      // Datos de ejemplo para probar la interfaz
      final List<User> usersEjemplo = [
        User(name: 'Andres', lastName: 'Londoño', role: 'Administrador', documentNumber: '123', status: 'Activo'),
        User(name: 'Beatriz', lastName: 'Castro', role: 'Usuario', documentNumber: '124', status: 'Activo'),
        User(name: 'Carlos', lastName: 'Zambrano', role: 'Veterinario', documentNumber: '125', status: 'Activo'),
        User(name: 'Cristina', lastName: 'Lopez', role: 'Veterinario', documentNumber: '126', status: 'Inactivo'),
        User(name: 'Daniel', lastName: 'Hurtado', role: 'Veterinario', documentNumber: '127', status: 'Activo'),
      ];

      return usersEjemplo.sublist(
        offset,
        offset + limit > usersEjemplo.length ? usersEjemplo.length : offset + limit
      );
     
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<User> fetchUserById(int id) async {
    try {
      // Simulamos la búsqueda de un usuario específico
      await Future.delayed(const Duration(seconds: 1));
     
      return User(
        name: 'Usuario',
        lastName: 'Ejemplo',
        role: 'Usuario',
        documentNumber: id.toString(),
        status: 'Activo',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}