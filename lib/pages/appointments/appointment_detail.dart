import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointments_services.dart';
import '../../widgets/appbar.dart';


class DetalleCitaScreen extends StatefulWidget {
  final Cita cita;
  final VoidCallback onCitaUpdated;


  const DetalleCitaScreen({
    super.key,
    required this.cita,
    required this.onCitaUpdated,
  });


  @override
  State<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}


class _DetalleCitaScreenState extends State<DetalleCitaScreen> {
  final CitaService _citaService = CitaService();
  late Cita _cita;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _cita = widget.cita;
  }


  Future<void> _cancelarCita() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Cita'),
          content: Text('¿Estás seguro de que deseas cancelar la cita para ${_cita.mascotaNombre}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
               
                try {
                  final success = await _citaService.cancelarCita(_cita.id);
                  if (success) {
                    setState(() {
                      _cita = _cita.copyWith(estado: 'Cancelada');
                    });
                    widget.onCitaUpdated();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cita cancelada exitosamente')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cancelar cita: $e')),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _reprogramarCita() async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: _cita.fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );


    if (nuevaFecha != null) {
      final TimeOfDay? nuevaHora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_cita.fecha),
      );


      if (nuevaHora != null) {
        setState(() => _isLoading = true);
       
        try {
          final success = await _citaService.reprogramarCita(
            _cita.id,
            nuevaFecha,
            '${nuevaHora.hour}:${nuevaHora.minute.toString().padLeft(2, '0')}',
          );


          if (success) {
            setState(() {
              _cita = _cita.copyWith(
                fecha: nuevaFecha,
                hora: '${nuevaHora.hour}:${nuevaHora.minute.toString().padLeft(2, '0')}',
                estado: 'Reprogramada',
              );
            });
            widget.onCitaUpdated();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cita reprogramada exitosamente')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al reprogramar cita: $e')),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      }
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


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Detalle de Cita',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado de la cita
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _getColorByEstado(_cita.estado).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getColorByEstado(_cita.estado)),
                      ),
                      child: Text(
                        _cita.estado.toUpperCase(),
                        style: TextStyle(
                          color: _getColorByEstado(_cita.estado),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),


                  // Información de la cita
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información de la Cita',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Mascota:', _cita.mascotaNombre),
                          _buildInfoRow('Servicio:', _cita.tipoServicio),
                          _buildInfoRow('Fecha:', _formatDate(_cita.fecha)),
                          _buildInfoRow('Hora:', _cita.hora),
                          _buildInfoRow('Veterinario:', _cita.veterinario),
                          if (_cita.notas.isNotEmpty)
                            _buildInfoRow('Notas:', _cita.notas),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),


                  // Botones de acción
                  if (_cita.estado != 'Cancelada' && _cita.estado != 'Completada') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _reprogramarCita,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                            ),
                            child: const Text('Reprogramar Cita'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _cancelarCita,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                            ),
                            child: const Text('Cancelar Cita'),
                          ),
                        ),
                      ],
                    ),
                  ],


                  if (_cita.estado == 'Cancelada')
                    const Center(
                      child: Text(
                        'Esta cita ha sido cancelada',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}