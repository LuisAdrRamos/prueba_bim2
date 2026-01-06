import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pet_entity.dart';

abstract class PetEvent extends Equatable {
  const PetEvent();
  @override
  List<Object?> get props => [];
}

// Cargar todas las mascotas (para el Home Adoptante)
class LoadPets extends PetEvent {
  final String filter;
  final String searchQuery; // <--- NUEVO CAMPO

  const LoadPets(
      {this.filter = 'Todos',
      this.searchQuery = '' // <--- Valor por defecto vacío
      });

  @override
  List<Object> get props => [filter, searchQuery];
}

// Cargar SOLO mis mascotas (para el Panel del Refugio)
class LoadMyPets extends PetEvent {
  final String shelterId;
  final String filter; // 'Todos', 'Perro', 'Gato'
  final String searchQuery; // Texto del buscador

  const LoadMyPets(this.shelterId,
      {this.filter = 'Todos', this.searchQuery = ''});

  @override
  List<Object> get props => [shelterId, filter, searchQuery];
}

// Crear una nueva mascota
class CreatePet extends PetEvent {
  final PetEntity pet;
  final File imageFile;

  const CreatePet({required this.pet, required this.imageFile});
  @override
  List<Object> get props => [pet, imageFile];
}

// Actualizar una mascota existente
class UpdatePet extends PetEvent {
  final PetEntity pet;
  final File? newImage;

  const UpdatePet({required this.pet, this.newImage});
  @override
  List<Object?> get props => [pet, newImage];
}

// Borrar una mascota
class DeletePet extends PetEvent {
  final String petId;
  final String imageUrl;
  final String shelterId; // Para recargar la lista después

  const DeletePet({
    required this.petId,
    required this.imageUrl,
    required this.shelterId,
  });
  @override
  List<Object> get props => [petId, imageUrl, shelterId];
}
