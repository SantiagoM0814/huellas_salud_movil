class Cita {
  final String id;
  final String mascotaId;
  final String mascotaNombre;
  final String tipoServicio;
  final DateTime fecha;
  final String hora;
  final String estado;
  final String veterinario;
  final String notas;

  Cita({
    required this.id,
    required this.mascotaId,
    required this.mascotaNombre,
    required this.tipoServicio,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.veterinario,
    required this.notas,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return Cita(
      id: data['id'] ?? '',
      mascotaId: data['mascotaId'] ?? '',
      mascotaNombre: data['mascotaNombre'] ?? '',
      tipoServicio: data['tipoServicio'] ?? '',
      fecha: DateTime.parse(data['fecha'] ?? DateTime.now().toString()),
      hora: data['hora'] ?? '',
      estado: data['estado'] ?? '',
      veterinario: data['veterinario'] ?? '',
      notas: data['notas'] ?? '',
    );
  }

  Cita copyWith({
    String? id,
    String? mascotaId,
    String? mascotaNombre,
fecha,
    String? hora,
    String? estado,
    String? veterinario,
    String? notas,
  }) {
    return Cita(
      id: id ?? this.id,
      mascotaId: mascotaId ?? this.mascotaId,
      mascotaNombre: mascotaNombre ?? this.mascotaNombre,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      estado: estado ?? this.estado,
      veterinario: veterinario ?? this.veterinario,
      notas: notas ?? this.notas,
    );
  }
}