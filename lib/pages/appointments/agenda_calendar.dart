import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointments_services.dart';
import '../../widgets/appbar.dart';

class AgendaCalendarScreen extends StatefulWidget {
  const AgendaCalendarScreen({super.key});

  @override
  State<AgendaCalendarScreen> createState() => _AgendaCalendarScreenState();
}

class _AgendaCalendarScreenState extends State<AgendaCalendarScreen> {
  final CitaService _citaService = CitaService();
  final List<Cita> _citas = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadCitas();
  }

  Future<void> _loadCitas() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newCitas = await _citaService.fetchCitas(limit: _limit, offset: _offset);
      setState(() {
        if (newCitas.isEmpty) {
          _hasMore = false;
        } else {
          final existingIds = _citas.map((c) => c.id).toSet();
          final filtered = newCitas.where((c) => !existingIds.contains(c.id)).toList();
          _citas.addAll(filtered);
          _offset += _limit;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar agenda: $e')),
      );
    }
  }

  Color _getColorByEstado(String estado) {
    switch (estado) {
      case 'Confirmada':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'Programada':
        return Colors.blue;
      case 'Cancelada':
        return Colors.red;
      case 'Completada':
        return Colors.grey;
      case 'Reprogramada':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildCitaItem(Cita cita) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cita.mascotaNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getColorByEstado(cita.estado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cita.estado,
                    style: TextStyle(
                      color: _getColorByEstado(cita.estado),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cita.tipoServicio,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(cita.fecha),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  cita.hora,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Veterinario: ${cita.veterinario}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mi Agenda',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Header informativo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.1),
                  Colors.blue.withOpacity(0.1),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agenda de Citas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Visualiza todas tus citas programadas en un solo lugar',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          // Lista de citas
          Expanded(
            child: _citas.isEmpty && !_isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tienes citas programadas',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Agenda una cita para verla aquí',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _citas.clear();
                        _offset = 0;
                        _hasMore = true;
                      });
                      await _loadCitas();
                    },
                    child: ListView.builder(
                      itemCount: _citas.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _citas.length) {
                          return _isLoading
                              ? const Center(child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ))
                              : const SizedBox();
                        }
                        return _buildCitaItem(_citas[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}