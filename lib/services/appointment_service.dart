import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';

class AppointmentService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://huellassalud.onrender.com/internal",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  AppointmentService() {
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

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  // ---------- LIST ALL ----------
  Future<List<Appointment>> fetchAppointments() async {
    try {
      final response = await _dio.get("/appointment/list-appointments");

      if (response.statusCode == 200) {
        // backend returns a LIST (array) of objects
        final List<dynamic> raw = response.data as List<dynamic>;
        return raw.map((item) => Appointment.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception("Error loading appointments: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.response?.data ?? e.message}");
    }
  }

  // ---------- LIST BY OWNER ----------
  Future<List<Appointment>> fetchAppointmentsByOwner(String idOwner) async {
    try {
      final response = await _dio.get("/appointment/list-appointments-user/$idOwner");
      if (response.statusCode == 200) {
        final List<dynamic> raw = response.data as List<dynamic>;
        return raw.map((item) => Appointment.fromJson(item as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.response?.data ?? e.message}");
    }
  }

  // ---------- LIST BY VETERINARIAN ----------
  Future<List<Appointment>> fetchAppointmentsByVeterinarian(String idVeterinarian) async {
    try {
      final response = await _dio.get("/appointment/list-appointments-veterinarian/$idVeterinarian");
      if (response.statusCode == 200) {
        final List<dynamic> raw = response.data as List<dynamic>;
        return raw.map((item) => Appointment.fromJson(item as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.response?.data ?? e.message}");
    }
  }

  // ---------- GET BY ID ----------
  Future<Appointment?> fetchAppointmentById(String idAppointment) async {
    try {
      // The API doesn't explicitly show a "get by id" endpoint in your doc,
      // so we try list and filter (fallback). If you have a real endpoint, replace this.
      final all = await fetchAppointments();
      final match = all.firstWhere((a) => a.data.idAppointment == idAppointment, orElse: () => null as Appointment);
      return match;
    } catch (e) {
      throw Exception("Error fetching appointment by id: $e");
    }
  }

  // ---------- AVAILABLE SLOTS ----------
  /// date expects ISO date string (yyyy-MM-dd) or DateTime.toIso8601String(), idVeterinarian required
  Future<List<String>> availableSlots({required String date, required String idVeterinarian}) async {
    try {
      final response = await _dio.get(
        "/appointment/available",
        queryParameters: {
          'date': date,
          'idVeterinarian': idVeterinarian,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = response.data as List<dynamic>;
        return raw.map((e) => e.toString()).toList();
      } else {
        throw Exception("Error getting availability: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.response?.data ?? e.message}");
    }
  }

  // ---------- CREATE ----------
  Future<bool> createAppointment({required AppointmentData data}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final name = prefs.getString('user_name') ?? '';
      final email = prefs.getString('user_email') ?? '';
      final role = prefs.getString('user_role') ?? 'CLIENTE';

      final meta = AppointmentMeta(
        creationDate: DateTime.now(),
        lastUpdate: DateTime.now(),
        ipAddress: '',
        source: 'flutter-app',
        nameUserCreated: name,
        emailUserCreated: email,
        roleUserCreated: role,
        nameUserUpdated: null,
        emailUserUpdated: null,
        roleUserUpdated: null,
        tokenRaw: token.isNotEmpty ? 'Bearer $token' : '',
      );

      final payload = {
        'data': data.toJson(),
        'meta': meta.toJson(),
      };

      final response = await _dio.post("/appointment/create", data: payload);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Create failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio error on create: ${e.response?.data ?? e.message}");
    }
  }

  // ---------- UPDATE ----------
  Future<bool> updateAppointment({required AppointmentData data}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final name = prefs.getString('user_name') ?? '';
      final email = prefs.getString('user_email') ?? '';
      final role = prefs.getString('user_role') ?? 'CLIENTE';

      final meta = AppointmentMeta(
        creationDate: DateTime.now(), // backend may ignore creationDate; we send current
        lastUpdate: DateTime.now(),
        ipAddress: '',
        source: 'flutter-app',
        nameUserCreated: name,
        emailUserCreated: email,
        roleUserCreated: role,
        nameUserUpdated: name,
        emailUserUpdated: email,
        roleUserUpdated: role,
        tokenRaw: token.isNotEmpty ? 'Bearer $token' : '',
      );

      final payload = {
        'data': data.toJson(),
        'meta': meta.toJson(),
      };

      final response = await _dio.put("/appointment/update", data: payload);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Update failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio error on update: ${e.response?.data ?? e.message}");
    }
  }

  // ---------- DELETE ----------
  Future<bool> deleteAppointment({required String idAppointment}) async {
    try {
      final response = await _dio.delete(
        "/appointment/delete",
        queryParameters: {'idAppointment': idAppointment},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Delete failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio error on delete: ${e.response?.data ?? e.message}");
    }
  }
}
