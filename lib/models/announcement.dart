class Announcement {
  final String idAnnouncement;
  final String description;
  final String cellPhone;
  final bool status;
  final MediaFile? mediaFile;

  Announcement({
    required this.idAnnouncement,
    required this.description,
    required this.cellPhone,
    required this.status,
    this.mediaFile,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      idAnnouncement: json["idAnnouncement"] ?? "",
      description: json["description"] ?? "",
      cellPhone: json["cellPhone"] ?? "",
      status: json["status"] ?? false,
      mediaFile: json["mediaFile"] != null
          ? MediaFile.fromJson(json["mediaFile"])
          : null
    );
  }
}

class MediaFile {
  final String fileName;
  final String contentType;
  final String attachment;

  MediaFile({
    required this.fileName,
    required this.contentType,
    required this.attachment,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      fileName: json['fileName'],
      contentType: json['contentType'],
      attachment: json['attachment'],
    );
  }
}
