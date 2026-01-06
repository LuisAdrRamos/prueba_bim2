import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_entity.dart';

abstract class PetRepository {
  // Subir imagen y crear mascota
  Future<Either<Failure, void>> createPet({
    required PetEntity pet,
    required File imageFile,
  });

  // Leer mascotas (Opcional: filtrar por especie)
  Future<Either<Failure, List<PetEntity>>> getPets();

  // Obtener mis mascotas (para el refugio)
  Future<Either<Failure, List<PetEntity>>> getMyPets(String shelterId);

  Future<Either<Failure, void>> updatePet({
    required PetEntity pet,
    File? newImage, // Opcional
  });

  // Borrar mascota
  Future<Either<Failure, void>> deletePet(String petId, String imageUrl);
}
