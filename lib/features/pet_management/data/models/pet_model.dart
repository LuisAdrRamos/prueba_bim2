import '../../domain/entities/pet_entity.dart';

class PetModel extends PetEntity {
  const PetModel({
    required super.id,
    required super.name,
    required super.species,
    required super.breed,
    required super.age,
    required super.size,
    required super.gender,
    required super.description,
    required super.imageUrl,
    required super.locationLat,
    required super.locationLng,
    required super.shelterId,
    required super.isAdopted,
  });

  // De JSON (Supabase) a Dart
  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'] ?? '',
      age: json['age'] ?? '',
      size: json['size'] ?? '',
      gender: json['gender'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      locationLat: (json['location_lat'] as num?)?.toDouble() ?? 0.0,
      locationLng: (json['location_lng'] as num?)?.toDouble() ?? 0.0,
      shelterId: json['shelter_id'],
      isAdopted: json['is_adopted'] ?? false,
    );
  }

  // De Dart a JSON (Para subir a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'size': size,
      'gender': gender,
      'description': description,
      'image_url': imageUrl,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'shelter_id': shelterId,
    };
  }
}
