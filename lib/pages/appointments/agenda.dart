import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../widgets/appbar.dart';

class AgendaCalendarScreen extends StatefulWidget {
  const AgendaCalendarScreen({super.key});

  @override
  State<AgendaCalendarScreen> createState() => _AgendaCalendarScreenState();
}

class _AgendaCalendarScreenState extends State<AgendaCalendarScreen> {
  final AppointmentService _service = AppointmentService();
  final List<Appointment> _citas = [];
  bool _isLoading = false;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late Map<DateTime, List<Appointment>> _citasPorDia;

  @override
  void initState() {
    super.initState();
    _citasPorDia = {};
    _loadCitas();
  }

  Future<void> _loadCitas() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final newCitas = await _service.fetchAppointments();
      setState(() {
        _citas.clear();
        _citas.addAll(newCitas);
        _organizarCitasPorDia();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar agenda: $e')));
    }
  }

  void _organizarCitasPorDia() {
    _citasPorDia.clear();
    for (var cita in _citas) {
      final fecha = DateTime(cita.data.dateTime.year, cita.data.dateTime.month, cita.data.dateTime.day);
      if (_citasPorDia.containsKey(fecha)) {
        _citasPorDia[fecha]!.add(cita);
      } else {
        _citasPorDia[fecha] = [cita];
      }
    }
  }

  Color _getColorByEstado(String estado) {
    switch (estado) {
      case 'FINALIZADA':
      case 'Completada':
        return Colors.green;
      case 'Pendiente':
      case 'PENDIENTE':
        return Colors.orange;
      case 'Programada':
      case 'PROGRAMADA':
        return Colors.blue;
      case 'CANCELADA':
      case 'Cancelada':
        return Colors.red;
      case 'Reprogramada':
      case 'REPROGRAMADA':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  String _formatTime(String hora) => hora;
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Widget _buildCalendarHeader() {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Calendario de Citas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple[700])),
            const SizedBox(height: 4),
            Text('${_getMonthName(_focusedDay.month)} ${_focusedDay.year}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ]),
          Row(children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            }),
            TextButton(onPressed: () {
              setState(() { _focusedDay = DateTime.now(); _selectedDay = DateTime.now(); });
            }, child: const Text('Hoy')),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            }),
          ]),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    const weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return Row(children: weekDays.map((day) {
      return Expanded(child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
        child: Text(day, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
      ));
    }).toList());
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    final firstWeekday = firstDay.weekday;
    for (var i = firstWeekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }
    for (var i = 0; i < lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }
    final lastWeekday = lastDay.weekday;
    for (var i = 1; i <= 7 - lastWeekday; i++) {
      days.add(lastDay.add(Duration(days: i)));
    }
    return days;
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_focusedDay);
    final today = DateTime.now();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.2),
      itemCount: daysInMonth.length,
      itemBuilder: (context, index) {
        final day = daysInMonth[index];
        final isCurrentMonth = day.month == _focusedDay.month;
        final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
        final isSelected = day.year == _selectedDay.year && day.month == _selectedDay.month && day.day == _selectedDay.day;
        final hasCitas = _citasPorDia.containsKey(DateTime(day.year, day.month, day.day));
        final citasDelDia = hasCitas ? _citasPorDia[DateTime(day.year, day.month, day.day)]! : [];

        return GestureDetector(
          onTap: () {
            if (isCurrentMonth) setState(() => _selectedDay = day);
          },
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple.withOpacity(0.1) : isToday ? Colors.blue.withOpacity(0.1) : Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.purple : isToday ? Colors.blue : Colors.grey[300]!,
                width: isSelected ? 2 : isToday ? 1 : 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(day.day.toString(), style: TextStyle(fontSize: 16, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isCurrentMonth ? (isToday ? Colors.blue : Colors.black87) : Colors.grey[400])),
              if (hasCitas) ...[
                const SizedBox(height: 4),
                ...citasDelDia.take(2).map((cita) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    height: 4,
                    width: 20,
                    decoration: BoxDecoration(color: _getColorByEstado(cita.data.status), borderRadius: BorderRadius.circular(2)),
                  );
                }).toList(),
                if (citasDelDia.length > 2) ...[
                  const SizedBox(height: 2),
                  Text('+${citasDelDia.length - 2}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ],
            ]),
          ),
        );
      },
    );
  }

  Widget _buildCitasDelDia() {
    final citasDelDia = _citasPorDia[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ?? [];

    if (citasDelDia.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(children: [const Icon(Icons.event_available, size: 64, color: Colors.grey), const SizedBox(height: 16), Text('No hay citas para el ${_formatDate(_selectedDay)}', style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center)]),
      );
    }

    return ListView.builder(
      itemCount: citasDelDia.length,
      itemBuilder: (context, index) {
        final cita = citasDelDia[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(cita.data.idPet, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _getColorByEstado(cita.data.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(cita.data.status, style: TextStyle(color: _getColorByEstado(cita.data.status), fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ]),
              const SizedBox(height: 8),
              Text(cita.data.services.join(', '), style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${cita.data.dateTime.hour.toString().padLeft(2,'0')}:${cita.data.dateTime.minute.toString().padLeft(2,'0')}', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(cita.data.idVeterinarian, style: const TextStyle(fontSize: 14)),
              ]),
              if (cita.data.notes != null && cita.data.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notas: ${cita.data.notes}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Mi Calendario', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              _buildCalendarHeader(),
              _buildWeekDaysHeader(),
              const SizedBox(height: 8),
              Expanded(flex: 2, child: _buildCalendarGrid()),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.centerLeft, child: Text('Citas del ${_formatDate(_selectedDay)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple))),
              const SizedBox(height: 8),
              Expanded(flex: 3, child: _buildCitasDelDia()),
            ]),
    );
  }
}
