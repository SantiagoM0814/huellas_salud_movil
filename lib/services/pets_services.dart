import 'dart:convert';

import 'package:dio/dio.dart';
import '../models/pets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://huellassalud.onrender.com/internal/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  PetService() {
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
  //esto lo hizo el flaco man
  Future<List<Pet>> fetchPet({int limit = 20, int offset = 0}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final authUserString = prefs.getString('auth_user');

    String? documentNumber; // 👈 declarar antes del if

    if (authUserString != null) {
      final authUser = jsonDecode(authUserString);
      documentNumber = authUser['data']['documentNumber'];

      print("👤 authUser: $authUser");
      print("📌 Documento: $documentNumber");
    }

    if (documentNumber == null) {
      throw Exception("auth_user no encontrado o inválido");
    }

    final response = await _dio.get(
      'pet/owners-pets/$documentNumber',
      queryParameters: {'limit': limit, 'offset': offset},
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = response.data;

      final List<Pet> pets = results.map((item) {
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

        return Pet(
          idPet: data['idPet'].toString(),
          name: data['name'] ?? 'Sin nombre',
          species: data['species'],
          sex: data['sex'],
          age: data['age'],
          mediaFile: mediaFile,
        );
      }).toList();

      return pets;
    } else {
      throw Exception('Failed to load pets');
    }
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception('Error: ${e.response!.statusCode}');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }
}


  Future<Pet> fetchProductById(int id) async {
    try {
      final response = await _dio.get('pet/$id'); // 👈 Ajusta el endpoint

      if (response.statusCode == 200) {
        return Pet.fromJson(response.data);
      } else {
        throw Exception('Failed to load pet');
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
