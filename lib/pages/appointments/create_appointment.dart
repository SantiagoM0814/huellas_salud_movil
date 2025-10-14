import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointments_services.dart';
import '../../widgets/appbar.dart';

class CrearCitaScreen extends StatefulWidget {
  const CrearCitaScreen({super.key});

  @override
  State<CrearCitaScreen> createState() => _CrearCitaScreenState();
}

class _CrearCitaScreenState extends State<CrearCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final CitaService _citaService = CitaService();
  bool _isLoading = false;

  // Controladores para el formulario
  final TextEditingController _mascotaController = TextEditingController();
  final TextEditingController _tipoServicioController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _veterinarioController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  final List<String> _servicios = [
    'Consulta General',
    'Vacunación',
    'Limpieza Dental',
    'Cirugía',
    'Urgencias',
    'Control de Peso',
    'Dermatología',
    'Oftalmología',
  ];

  final List<String> _mascotas = ['Firulais', 'Mishi', 'Rex', 'Luna'];
  final List<String> _veterinarios = [
    'Dr. Carlos Rodriguez',
    'Dra. Maria Gonzalez',
    'Dr. Javier Lopez',
    'Dra. Ana Martinez'
  ];

  @override
  void initState() {
    super.initState();
    _fechaController.text = _formatDate(_selectedDate);
    _horaController.text = _formatTime(_selectedTime);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _horaController.text = _formatTime(picked);
      });
    }
  }

  void _crearCita() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final nuevaCita = Cita(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          mascotaId: '1', // En una app real, esto vendría de la selección
          mascotaNombre: _mascotaController.text,
          tipoServicio: _tipoServicioController.text,
          fecha: _selectedDate,
          hora: _horaController.text,
          estado: 'Pendiente',
          veterinario: _veterinarioController.text,
          notas: _notasController.text,
        );

        final success = await _citaService.crearCita(nuevaCita);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita creada exitosamente')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear cita: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Agendar Cita',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Mascota
              DropdownButtonFormField<String>(
                value: _mascotas.isNotEmpty ? _mascotas.first : null,
                decoration: const InputDecoration(
                  labelText: 'Mascota',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                items: _mascotas.map((String mascota) {
                  return DropdownMenuItem<String>(
                    value: mascota,
                    child: Text(mascota),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _mascotaController.text = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una mascota';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tipo de servicio
              DropdownButtonFormField<String>(
                value: _servicios.isNotEmpty ? _servicios.first : null,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Servicio',
                  prefixIcon: Icon(Icons.medical_services),
                  border: OutlineInputBorder(),
                ),
                items: _servicios.map((String servicio) {
                  return DropdownMenuItem<String>(
                    value: servicio,
                    child: Text(servicio),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoServicioController.text = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un tipo de servicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Fecha
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una fecha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Hora
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectTime(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una hora';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Veterinario
              DropdownButtonFormField<String>(
                value: _veterinarios.isNotEmpty ? _veterinarios.first : null,
                decoration: const InputDecoration(
                  labelText: 'Veterinario',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items: _veterinarios.map((String vet) {
                  return DropdownMenuItem<String>(
                    value: vet,
                    child: Text(vet),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _veterinarioController.text = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un veterinario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Notas
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  hintText: 'Describe el motivo de la cita...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Botón de crear cita
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _crearCita,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Agendar Cita'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mascotaController.dispose();
    _tipoServicioController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _veterinarioController.dispose();
    _notasController.dispose();
    super.dispose();
  }
}