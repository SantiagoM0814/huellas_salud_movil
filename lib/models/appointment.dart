class Appointment {
  final String id;
  final AppointmentData data;
  final AppointmentMeta meta;

  Appointment({
    required this.id,
    required this.data,
    required this.meta,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      data: AppointmentData.fromJson(json['data'] as Map<String, dynamic>),
      meta: AppointmentMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data.toJson(),
      'meta': meta.toJson(),
    };
  }

  Appointment copyWith({
    String? id,
    AppointmentData? data,
    AppointmentMeta? meta,
  }) {
    return Appointment(
      id: id ?? this.id,
      data: data ?? this.data,
      meta: meta ?? this.meta,
    );
  }
}

// ---------------------------------------------------------
// DATA
// ---------------------------------------------------------
class AppointmentData {
  final String idAppointment;
  final String idOwner;
  final String idPet;
  final List<String> services;
  final DateTime dateTime;
  final String status;
  final String? notes;
  final String idVeterinarian;

  AppointmentData({
    required this.idAppointment,
    required this.idOwner,
    required this.idPet,
    required this.services,
    required this.dateTime,
    required this.status,
    this.notes,
    required this.idVeterinarian,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    return AppointmentData(
      idAppointment: json['idAppointment'] ?? '',
      idOwner: (json['idOwner'] ?? '').toString(),
      idPet: json['idPet'] ?? '',
      services: (json['services'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: json['status'] ?? '',
      notes: json['notes'] as String?,
      idVeterinarian: (json['idVeterinarian'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAppointment': idAppointment,
      'idOwner': idOwner,
      'idPet': idPet,
      'services': services,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'idVeterinarian': idVeterinarian,
    };
  }

  AppointmentData copyWith({
    String? idAppointment,
    String? idOwner,
    String? idPet,
    List<String>? services,
    DateTime? dateTime,
    String? status,
    String? notes,
    String? idVeterinarian,
  }) {
    return AppointmentData(
      idAppointment: idAppointment ?? this.idAppointment,
      idOwner: idOwner ?? this.idOwner,
      idPet: idPet ?? this.idPet,
      services: services ?? this.services,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      idVeterinarian: idVeterinarian ?? this.idVeterinarian,
    );
  }
}

// ---------------------------------------------------------
// META
// ---------------------------------------------------------
class AppointmentMeta {
  final DateTime creationDate;
  final DateTime lastUpdate;
  final String ipAddress;
  final String source;
  final String nameUserCreated;
  final String emailUserCreated;
  final String roleUserCreated;
  final String? nameUserUpdated;
  final String? emailUserUpdated;
  final String? roleUserUpdated;
  final String tokenRaw; // obligatorio

  AppointmentMeta({
    required this.creationDate,
    required this.lastUpdate,
    required this.ipAddress,
    required this.source,
    required this.nameUserCreated,
    required this.emailUserCreated,
    required this.roleUserCreated,
    this.nameUserUpdated,
    this.emailUserUpdated,
    this.roleUserUpdated,
    required this.tokenRaw,
  });

  factory AppointmentMeta.fromJson(Map<String, dynamic> json) {
    return AppointmentMeta(
      creationDate: DateTime.parse(json['creationDate'] as String),
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      ipAddress: json['ipAddress'] ?? '',
      source: json['source'] ?? '',
      nameUserCreated: json['nameUserCreated'] ?? '',
      emailUserCreated: json['emailUserCreated'] ?? '',
      roleUserCreated: json['roleUserCreated'] ?? '',
      nameUserUpdated: json['nameUserUpdated'] as String?,
      emailUserUpdated: json['emailUserUpdated'] as String?,
      roleUserUpdated: json['roleUserUpdated'] as String?,
      tokenRaw: json['tokenRaw'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creationDate': creationDate.toIso8601String(),
      'lastUpdate': lastUpdate.toIso8601String(),
      'ipAddress': ipAddress,
      'source': source,
      'nameUserCreated': nameUserCreated,
      'emailUserCreated': emailUserCreated,
      'roleUserCreated': roleUserCreated,
      'nameUserUpdated': nameUserUpdated,
      'emailUserUpdated': emailUserUpdated,
      'roleUserUpdated': roleUserUpdated,
      'tokenRaw': tokenRaw,
    };
  }

  AppointmentMeta copyWith({
    DateTime? creationDate,
    DateTime? lastUpdate,
    String? ipAddress,
    String? source,
    String? nameUserCreated,
    String? emailUserCreated,
    String? roleUserCreated,
    String? nameUserUpdated,
    String? emailUserUpdated,
    String? roleUserUpdated,
    String? tokenRaw,
  }) {
    return AppointmentMeta(
      creationDate: creationDate ?? this.creationDate,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      ipAddress: ipAddress ?? this.ipAddress,
      source: source ?? this.source,
      nameUserCreated: nameUserCreated ?? this.nameUserCreated,
      emailUserCreated: emailUserCreated ?? this.emailUserCreated,
      roleUserCreated: roleUserCreated ?? this.roleUserCreated,
      nameUserUpdated: nameUserUpdated ?? this.nameUserUpdated,
      emailUserUpdated: emailUserUpdated ?? this.emailUserUpdated,
      roleUserUpdated: roleUserUpdated ?? this.roleUserUpdated,
      tokenRaw: tokenRaw ?? this.tokenRaw,
    );
  }
}
