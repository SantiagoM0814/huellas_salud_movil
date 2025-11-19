// lib/pages/appointments/appointments.dart

import 'package:flutter/material.dart';
import '../../services/appointment_service.dart';
import '../../models/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final AppointmentService _service = AppointmentService();

  late Future<List<Appointment>> _futureAppointments;

  @override
  void initState() {
    super.initState();
    _futureAppointments = _service.fetchAppointments();
  }

  String formatDate(DateTime dt) => DateFormat("yyyy-MM-dd").format(dt);
  String formatTime(DateTime dt) => DateFormat("HH:mm").format(dt);

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "FINALIZADA":
        return Colors.green;
      case "CANCELADA":
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de Citas"),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _futureAppointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final citas = snapshot.data ?? [];

          if (citas.isEmpty) {
            return const Center(child: Text("No hay citas registradas."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: citas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = citas[index];

              final date = c.data.dateTime;
              final statusColor = getStatusColor(c.data.status);

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📅 ${formatDate(date)}   ⏰ ${formatTime(date)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("🐾 Mascota ID: ${c.data.idPet}"),
                      Text("👤 Propietario: ${c.data.idOwner}"),
                      Text("👨‍⚕️ Veterinario: ${c.data.idVeterinarian}"),

                      Text("🛠 Servicio(s): ${c.data.services.join(', ')}"),

                      if (c.data.notes != null && c.data.notes!.isNotEmpty)
                        Text("📝 Notas: ${c.data.notes}"),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          c.data.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
