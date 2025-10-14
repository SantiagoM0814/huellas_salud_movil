import 'package:dio/dio.dart';
import '../models/appointment.dart';

class CitaService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://huellassalud.onrender.com/internal/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Simular datos de citas para demostración
  Future<List<Cita>> fetchCitas({int limit = 20, int offset = 0}) async {
    try {
      // Simulamos delay de red
      await Future.delayed(const Duration(seconds: 1));

      // Datos de ejemplo
      final List<Cita> citasEjemplo = [
        Cita(
          id: '1',
          mascotaId: '1',
          mascotaNombre: 'Firulais',
          tipoServicio: 'Consulta General',
          fecha: DateTime.now().add(const Duration(days: 2)),
          hora: '09:00 AM',
          estado: 'Confirmada',
          veterinario: 'Dr. Carlos Rodriguez',
          notas: 'Revisión anual de vacunas',
        ),
        Cita(
          id: '2',
          mascotaId: '2',
          mascotaNombre: 'Mishi',
          tipoServicio: 'Vacunación',
          fecha: DateTime.now().add(const Duration(days: 5)),
          hora: '02:30 PM',
          estado: 'Pendiente',
          veterinario: 'Dra. Maria Gonzalez',
          notas: 'Vacuna contra la rabia',
        ),
        Cita(
          id: '3',
          mascotaId: '1',
          mascotaNombre: 'Firulais',
          tipoServicio: 'Limpieza Dental',
          fecha: DateTime.now().add(const Duration(days: 10)),
          hora: '11:00 AM',
          estado: 'Programada',
          veterinario: 'Dr. Carlos Rodriguez',
          notas: 'Limpieza dental profesional',
        ),
        Cita(
          id: '4',
          mascotaId: '3',
          mascotaNombre: 'Rex',
          tipoServicio: 'Cirugía',
          fecha: DateTime.now().add(const Duration(days: 7)),
          hora: '03:00 PM',
          estado: 'Reprogramada',
          veterinario: 'Dra. Ana Martinez',
          notas: 'Castración programada',
        ),
      ];

      return citasEjemplo.sublist(
        offset,
        offset + limit > citasEjemplo.length ? citasEjemplo.length : offset + limit,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<bool> crearCita(Cita cita) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Simulación de creación exitosa
      // En una app real, aquí harías la petición POST a tu API
      print('Creando cita para ${cita.mascotaNombre} - ${cita.tipoServicio}');
      return true;
    } on DioException catch (e) {
      throw Exception('Error al crear cita: ${e.message}');
    }
  }

  Future<bool> cancelarCita(String citaId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Simulación de cancelación exitosa
      // En una app real, aquí harías la petición DELETE o PATCH a tu API
      print('Cancelando cita: $citaId');
      return true;
    } on DioException catch (e) {
      throw Exception('Error al cancelar cita: ${e.message}');
    }
  }

  Future<bool> reprogramarCita(String citaId, DateTime nuevaFecha, String nuevaHora) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Simulación de reprogramación exitosa
      // En una app real, aquí harías la petición PUT/PATCH a tu API
      print('Reprogramando cita $citaId para $nuevaFecha a las $nuevaHora');
      return true;
    } on DioException catch (e) {
      throw Exception('Error al reprogramar cita: ${e.message}');
    }
  }

  // Método adicional para obtener una cita por ID
  Future<Cita> fetchCitaById(String id) async {
    try {
      // Simulamos la búsqueda de una cita específica
      await Future.delayed(const Duration(seconds: 1));
      
      // En una app real, harías: final response = await _dio.get('citas/$id');
      
      // Datos de ejemplo
      return Cita(
        id: id,
        mascotaId: '1',
        mascotaNombre: 'Firulais',
        tipoServicio: 'Consulta General',
        fecha: DateTime.now().add(const Duration(days: 2)),
        hora: '09:00 AM',
        estado: 'Confirmada',
        veterinario: 'Dr. Carlos Rodriguez',
        notas: 'Revisión anual de vacunas',
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