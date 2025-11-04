import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class PetHistoryPage extends StatelessWidget {
  final String petId;
  final String? petName; // opcional, se usa en petList.dart


  const PetHistoryPage({
    super.key,
    required this.petId,
    this.petName,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial médico'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchPetData(petId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }


          if (snapshot.hasError) {
            return Center(
              child: Text('Error de red o servidor: ${snapshot.error}'),
            );
          }


          // Extraer historial médico
          final historial =
          (snapshot.data?['data']?['medicalHistory'] as List?) ?? [];




          // Debug temporal
          print('✅ Historial recibido: $historial');


          if (historial.isEmpty) {
            return const Center(child: Text('No hay historial médico'));
          }


          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (petName != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Mascota: $petName',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final item = historial[index] as Map<String, dynamic>;


                    final fecha =
                        item['date']?.toString().split('T').first ?? 'Sin fecha';
                    final diagnostico = item['diagnostic'] ?? 'Sin diagnóstico';
                    final tratamiento = item['treatment'] ?? 'Sin tratamiento';
                    final cirugias = (item['surgeries'] as List<dynamic>?)
                            ?.join(', ') ??
                        'Sin cirugías';
                    final vacunasList =
                        (item['vaccines'] as List<dynamic>?) ?? [];
                    final vacunas = vacunasList.isNotEmpty
                        ? vacunasList
                            .map((v) => v['name'] ?? 'Desconocida')
                            .join(', ')
                        : 'Sin vacunas';


                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📅 Fecha: $fecha',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('🩺 Diagnóstico: $diagnostico'),
                            const SizedBox(height: 4),
                            Text('💊 Tratamiento: $tratamiento'),
                            const SizedBox(height: 4),
                            Text('🩹 Cirugías: $cirugias'),
                            const SizedBox(height: 4),
                            Text('💉 Vacunas: $vacunas'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  // Traer datos de la mascota (incluye historial)
  Future<Map<String, dynamic>> fetchPetData(String petId) async {
    final dio = Dio();
    final url = 'https://huellassalud.onrender.com/internal/pet/$petId';


    try {
      final response = await dio.get(url);


      print('🔎 Respuesta status: ${response.statusCode}');
      print('📦 Datos recibidos: ${response.data}');


      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener datos (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de red o servidor: $e');
    }
  }
}