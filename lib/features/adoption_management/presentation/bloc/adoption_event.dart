import 'package:equatable/equatable.dart';

abstract class AdoptionEvent extends Equatable {
  const AdoptionEvent();
  @override
  List<Object?> get props => [];
}

class SubmitAdoptionRequest extends AdoptionEvent {
  final String petId;
  final String adopterId;
  final String shelterId;
  final String? message;
  // --- NUEVOS CAMPOS ---
  final String adopterName;
  final String adopterEmail;

  const SubmitAdoptionRequest({
    required this.petId,
    required this.adopterId,
    required this.shelterId,
    this.message,
    required this.adopterName,
    required this.adopterEmail,
  });

  @override
  List<Object?> get props =>
      [petId, adopterId, shelterId, message, adopterName, adopterEmail];
}

class LoadAdopterRequests extends AdoptionEvent {
  final String userId;
  const LoadAdopterRequests(this.userId);
  @override
  List<Object> get props => [userId];
}

class LoadShelterRequests extends AdoptionEvent {
  final String shelterId;
  const LoadShelterRequests(this.shelterId);
  @override
  List<Object> get props => [shelterId];
}

class UpdateAdoptionStatus extends AdoptionEvent {
  final String requestId;
  final String status;
  final String shelterIdRef; // Para recargar la lista después

  const UpdateAdoptionStatus(this.requestId, this.status, this.shelterIdRef);
  @override
  List<Object> get props => [requestId, status, shelterIdRef];
}
