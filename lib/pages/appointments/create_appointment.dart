// lib/pages/appointments/create_appointment.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/appointment_service.dart';
import '../../models/appointment.dart';
import '../../widgets/appbar.dart';

class CrearCitaScreen extends StatefulWidget {
  const CrearCitaScreen({super.key});

  @override
  State<CrearCitaScreen> createState() => _CrearCitaScreenState();
}

class _CrearCitaScreenState extends State<CrearCitaScreen> {
  final AppointmentService _service = AppointmentService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _petIdController = TextEditingController();
  final TextEditingController _servicesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _vetController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  bool _isLoading = false;

  List<String> _availableTimes = [];

  @override
  void initState() {
    super.initState();
    // Optionally prefill veterinarian or pet id
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null;
      });
      await _loadAvailability();
    }
  }

  Future<void> _loadAvailability() async {
    if (_vetController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final slots = await _service.availableSlots(date: DateFormat('yyyy-MM-dd').format(_selectedDate), idVeterinarian: _vetController.text);
      setState(() {
        _availableTimes = slots;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando disponibilidad: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una hora disponible')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dt = DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse('${DateFormat('yyyy-MM-dd').format(_selectedDate)}T$_selectedTime');
      final data = AppointmentData(
        idAppointment: DateTime.now().millisecondsSinceEpoch.toString(),
        idOwner: '', // si tienes owner en prefs ponnlo
        idPet: _petIdController.text,
        services: _servicesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        dateTime: dt,
        status: 'PENDIENTE',
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        idVeterinarian: _vetController.text,
      );

      final success = await _service.createAppointment(data: data);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita creada exitosamente')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creando cita: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatTimeDisplay(String t) {
    // t could be "08:00", "08:30", or ISO; try to format simply
    return t;
  }

  @override
  void dispose() {
    _petIdController.dispose();
    _servicesController.dispose();
    _notesController.dispose();
    _vetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Agendar Cita', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _petIdController,
                      decoration: const InputDecoration(labelText: 'Mascota ID', prefixIcon: Icon(Icons.pets), border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el ID de la mascota' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _servicesController,
                      decoration: const InputDecoration(labelText: 'Servicios (separados por coma)', prefixIcon: Icon(Icons.medical_services), border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Agrega al menos un servicio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vetController,
                      decoration: const InputDecoration(labelText: 'ID Veterinario', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el id del veterinario' : null,
                      onFieldSubmitted: (_) => _loadAvailability(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Fecha', prefixIcon: const Icon(Icons.calendar_today), border: const OutlineInputBorder(), hintText: DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    // available times
                    if (_availableTimes.isNotEmpty) Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Horas disponibles'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableTimes.map((t) {
                            final selected = t == _selectedTime;
                            return ChoiceChip(
                              label: Text(_formatTimeDisplay(t)),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedTime = t;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notas (Opcional)', prefixIcon: Icon(Icons.note), border: OutlineInputBorder(), hintText: 'Observaciones adicionales...'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _create,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                      child: const Text('Agendar Cita'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
