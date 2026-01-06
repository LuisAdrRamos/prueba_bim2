import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String age;
  final String size;
  final String gender;
  final String description;
  final String imageUrl;
  final double locationLat;
  final double locationLng;
  final String shelterId;
  final bool isAdopted;

  const PetEntity({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.size,
    required this.gender,
    required this.description,
    required this.imageUrl,
    required this.locationLat,
    required this.locationLng,
    required this.shelterId,
    required this.isAdopted,
  });

  @override
  List<Object?> get props => [id, name, shelterId, imageUrl];
}
