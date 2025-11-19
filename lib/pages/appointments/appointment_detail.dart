// lib/pages/appointments/appointment_detail.dart

import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../widgets/appbar.dart';

class DetalleCitaScreen extends StatefulWidget {
  final Appointment cita;
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
  final AppointmentService _service = AppointmentService();
  late Appointment _cita;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cita = widget.cita;
  }

  Future<void> _cancelarCita() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Text('¿Estás seguro de que deseas cancelar la cita para ${_cita.data.idPet}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sí, cancelar')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await _service.deleteAppointment(idAppointment: _cita.data.idAppointment);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita cancelada exitosamente')));
        widget.onCitaUpdated();
        Navigator.of(context).pop(); // go back
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cancelar cita: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reprogramarCita() async {
    final DateTime? nuevaFecha = await showDatePicker(context: context, initialDate: _cita.data.dateTime, firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (nuevaFecha == null) return;
    final TimeOfDay? nuevaHora = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_cita.data.dateTime));
    if (nuevaHora == null) return;

    final nuevaDateTime = DateTime(nuevaFecha.year, nuevaFecha.month, nuevaFecha.day, nuevaHora.hour, nuevaHora.minute);

    setState(() => _isLoading = true);
    try {
      final newData = _cita.data.copyWith(dateTime: nuevaDateTime, status: 'REPROGRAMADA');
      final success = await _service.updateAppointment(data: newData);
      if (success) {
        setState(() {
          _cita = _cita.copyWith(data: newData);
        });
        widget.onCitaUpdated();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita reprogramada exitosamente')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al reprogramar cita: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getColorByEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'FINALIZADA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      case 'PENDIENTE':
      case 'PENDING':
        return Colors.orange;
      case 'REPROGRAMADA':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text(value)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalle de Cita', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(color: _getColorByEstado(_cita.data.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: _getColorByEstado(_cita.data.status))),
                    child: Text(_cita.data.status.toUpperCase(), style: TextStyle(color: _getColorByEstado(_cita.data.status), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Información de la Cita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                      const SizedBox(height: 16),
                      _buildInfoRow('Mascota ID:', _cita.data.idPet),
                      _buildInfoRow('Servicio(s):', _cita.data.services.join(', ')),
                      _buildInfoRow('Fecha:', _formatDate(_cita.data.dateTime)),
                      _buildInfoRow('Hora:', '${_cita.data.dateTime.hour.toString().padLeft(2,'0')}:${_cita.data.dateTime.minute.toString().padLeft(2,'0')}'),
                      _buildInfoRow('Veterinario:', _cita.data.idVeterinarian),
                      if (_cita.data.notes != null && _cita.data.notes!.isNotEmpty) _buildInfoRow('Notas:', _cita.data.notes!),
                    ]),
                  ),
                ),
                const SizedBox(height: 30),
                if (_cita.data.status.toUpperCase() != 'CANCELADA' && _cita.data.status.toUpperCase() != 'FINALIZADA') ...[
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(onPressed: _reprogramarCita, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size(0, 50)), child: const Text('Reprogramar Cita')),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(onPressed: _cancelarCita, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(0, 50)), child: const Text('Cancelar Cita')),
                    ),
                  ]),
                ],
                if (_cita.data.status.toUpperCase() == 'CANCELADA')
                  const Center(child: Text('Esta cita ha sido cancelada', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))),
              ]),
            ),
    );
  }
}
