import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointments_services.dart';
import '../../widgets/appbar.dart';
import 'appointment_detail.dart';
import 'create_appointment.dart';


class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});


  @override
  State<CitasScreen> createState() => _CitasScreenState();
}


class _CitasScreenState extends State<CitasScreen> {
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
        SnackBar(content: Text('Error al cargar citas: $e')),
      );
    }
  }


  Future<void> _cancelarCita(int index) async {
    final cita = _citas[index];
   
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Cita'),
          content: Text('¿Estás seguro de que deseas cancelar la cita para ${cita.mascotaNombre}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final success = await _citaService.cancelarCita(cita.id);
                  if (success) {
                    setState(() {
                      _citas[index] = cita.copyWith(estado: 'Cancelada');
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cita cancelada exitosamente')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cancelar cita: $e')),
                  );
                }
              },
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _reprogramarCita(int index) async {
    final cita = _citas[index];
   
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: cita.fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );


    if (nuevaFecha != null) {
      final TimeOfDay? nuevaHora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(cita.fecha),
      );


      if (nuevaHora != null) {
        final horaFormateada = _formatTime(nuevaHora);
       
        final confirmar = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Reprogramar Cita'),
              content: Text(
                '¿Reprogramar cita de ${cita.mascotaNombre} para el ${_formatDate(nuevaFecha)} a las $horaFormateada?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Reprogramar'),
                ),
              ],
            );
          },
        );


        if (confirmar == true) {
          try {
            final success = await _citaService.reprogramarCita(
              cita.id,
              nuevaFecha,
              horaFormateada,
            );
           
            if (success) {
              setState(() {
                _citas[index] = cita.copyWith(
                  fecha: nuevaFecha,
                  hora: horaFormateada,
                  estado: 'Reprogramada',
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cita reprogramada exitosamente')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al reprogramar cita: $e')),
            );
          }
        }
      }
    }
  }


  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }


  void _navigateToCreateCita() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CrearCitaScreen()),
    );


    if (result == true) {
      setState(() {
        _citas.clear();
        _offset = 0;
        _hasMore = true;
      });
      _loadCitas();
    }
  }


  void _verDetalleCita(Cita cita) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleCitaScreen(
          cita: cita,
          onCitaUpdated: () {
            setState(() {
              _citas.clear();
              _offset = 0;
              _hasMore = true;
            });
            _loadCitas();
          },
        ),
      ),
    );
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


  Widget _buildCitaCard(Cita cita, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _verDetalleCita(cita),
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
              if (cita.estado != 'Cancelada' && cita.estado != 'Completada') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _reprogramarCita(index),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Text('Reprogramar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelarCita(index),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Mis Citas',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateCita,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
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
                  'Gestión de Citas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Programa, cancela o reprograma las citas de tus mascotas',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
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
                          'Presiona el botón + para agendar una cita',
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
                        return _buildCitaCard(_citas[index], index);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}