import '../../domain/entities/adoption_request.dart';

class AdoptionRequestModel extends AdoptionRequest {
  const AdoptionRequestModel({
    required super.id,
    required super.petId,
    required super.adopterId,
    required super.shelterId,
    required super.status,
    super.message,
    required super.createdAt,
    super.petName,
    super.petImage,
    super.adopterName,
    super.adopterEmail,
  });

  factory AdoptionRequestModel.fromJson(Map<String, dynamic> json) {
    return AdoptionRequestModel(
      id: json['id'],
      petId: json['pet_id'],
      adopterId: json['adopter_id'],
      shelterId: json['shelter_id'],
      status: json['status'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      // Datos Relacionales (Joins)
      petName: json['pets'] != null ? json['pets']['name'] : null,
      petImage: json['pets'] != null ? json['pets']['image_url'] : null,
      // --- CORRECCIÓN CLAVE: Mapear los datos del adoptante ---
      adopterName: json['adopter_name'],
      adopterEmail: json['adopter_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'adopter_id': adopterId,
      'shelter_id': shelterId,
      'status': status,
      'message': message,
      'adopter_name': adopterName,
      'adopter_email': adopterEmail,
    };
  }
}
