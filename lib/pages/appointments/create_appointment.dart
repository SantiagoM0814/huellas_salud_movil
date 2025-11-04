import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import '../../services/appointments_services.dart';
import '../../models/appointment.dart';


class CrearCitaScreen extends StatefulWidget {
  const CrearCitaScreen({super.key});


  @override
  State<CrearCitaScreen> createState() => _CrearCitaScreenState();
}


class _CrearCitaScreenState extends State<CrearCitaScreen> {
  final CitaService _citaService = CitaService();
  final _formKey = GlobalKey<FormState>();
 
  // Controladores
  final TextEditingController _mascotaController = TextEditingController();
  final TextEditingController _servicioController = TextEditingController();
  final TextEditingController _veterinarioController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
 
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = TimeOfDay.now();
  bool _isLoading = false;


  // Listas de opciones
  final List<String> _mascotas = ['Firulais', 'Mishi', 'Rex', 'Luna'];
  final List<String> _servicios = [
    'Consulta General',
    'Vacunación',
    'Limpieza Dental',
    'Cirugía',
    'Urgencias',
    'Desparasitación'
  ];
  final List<String> _veterinarios = [
    'Dr. Carlos Rodriguez',
    'Dra. Maria Gonzalez',
    'Dra. Ana Martinez',
    'Dr. Luis Fernandez'
  ];


  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
   
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }


  Future<void> _seleccionarHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
   
    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }


  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }


  Future<void> _crearCita() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);


      try {
        final nuevaCita = Cita(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          mascotaId: '1',
          mascotaNombre: _mascotaController.text,
          tipoServicio: _servicioController.text,
          fecha: _fechaSeleccionada,
          hora: _formatTime(_horaSeleccionada),
          estado: 'Programada',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
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


                    // Servicio
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
                          _servicioController.text = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona un servicio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),


                    // Fecha
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: const OutlineInputBorder(),
                        hintText: _formatDate(_fechaSeleccionada),
                      ),
                      onTap: _seleccionarFecha,
                      validator: (value) {
                        if (_fechaSeleccionada.isBefore(DateTime.now())) {
                          return 'La fecha no puede ser en el pasado';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),


                    // Hora
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Hora',
                        prefixIcon: const Icon(Icons.access_time),
                        border: const OutlineInputBorder(),
                        hintText: _formatTime(_horaSeleccionada),
                      ),
                      onTap: _seleccionarHora,
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
                        hintText: 'Observaciones adicionales...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),


                    // Botón de crear cita
                    ElevatedButton(
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
    _servicioController.dispose();
    _veterinarioController.dispose();
    _notasController.dispose();
    super.dispose();
  }
}