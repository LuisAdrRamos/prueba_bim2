import 'package:equatable/equatable.dart';

class AdoptionRequest extends Equatable {
  final String id;
  final String petId;
  final String adopterId;
  final String shelterId;
  final String status; // 'pending', 'approved', 'rejected'
  final String? message;
  final DateTime createdAt;

  // Datos expandidos (opcionales, para mostrar en UI sin hacer más consultas)
  final String? petName;
  final String? petImage;
  final String? adopterName;
  final String? adopterEmail;

  const AdoptionRequest({
    required this.id,
    required this.petId,
    required this.adopterId,
    required this.shelterId,
    required this.status,
    this.message,
    required this.createdAt,
    this.petName,
    this.petImage,
    this.adopterName,
    this.adopterEmail,
  });

  @override
  List<Object?> get props => [id, petId, adopterId, status];
}
