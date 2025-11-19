import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice.dart';

class InvoiceService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://huellassalud.onrender.com/internal",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Cache en memoria
  List<Map<String, dynamic>>? _cachedProducts;
  List<Map<String, dynamic>>? _cachedServices;

  InvoiceService() {
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

  Future<List<Invoice>> getInvoices() async {
    final response = await _dio.get("/invoice/list-invoices");

    if (response.statusCode == 200) {
      final List<dynamic> list = response.data;
      return list.map((json) => Invoice.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener facturas");
    }
  }

  // -------------------------------------------------------------------------
  // 🔥 PRODUCTOS (CORREGIDO CON json["data"])
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getProducts() async {
    if (_cachedProducts != null) return _cachedProducts!;

    final response = await _dio.get("/product/list-products");

    if (response.statusCode == 200) {
      final List<dynamic> list = response.data;

      _cachedProducts = list.map((json) {
        final data = json["data"]; // ⬅️ AQUI ESTABA EL ERROR

        return {
          "id": data["idProduct"],
          "name": data["name"],
        };
      }).toList();

      return _cachedProducts!;
    } else {
      throw Exception("Error al obtener productos");
    }
  }

  Future<String> getProductName(String id) async {
    final products = await getProducts();

    final match = products.firstWhere(
      (p) => p["id"] == id,
      orElse: () => {"name": "Producto"},
    );

    return match["name"];
  }

  // -------------------------------------------------------------------------
  // 🔥 SERVICIOS (CORREGIDO CON json["data"])
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getServices() async {
    if (_cachedServices != null) return _cachedServices!;

    final response = await _dio.get("/services/list-services");

    if (response.statusCode == 200) {
      final List<dynamic> list = response.data;

      _cachedServices = list.map((json) {
        final data = json["data"]; // ⬅️ MISMO ERROR AQUI

        return {
          "id": data["idService"],
          "name": data["name"],
        };
      }).toList();

      return _cachedServices!;
    } else {
      throw Exception("Error al obtener servicios");
    }
  }

  Future<String> getServiceName(String id) async {
    final services = await getServices();

    final match = services.firstWhere(
      (s) => s["id"] == id,
      orElse: () => {"name": "Servicio"},
    );

    return match["name"];
  }
}
