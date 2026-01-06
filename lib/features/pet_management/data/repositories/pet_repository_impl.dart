import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/repositories/pet_repository.dart';
import '../datasources/pet_remote_data_source.dart';
import '../models/pet_model.dart';

@LazySingleton(as: PetRepository)
class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PetRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> createPet({
    required PetEntity pet,
    required File imageFile,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      // Convertimos Entity a Model
      final petModel = PetModel(
        id: pet.id,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        age: pet.age,
        size: pet.size,
        gender: pet.gender,
        description: pet.description,
        imageUrl: '', // Se llenará en el datasource
        locationLat: pet.locationLat,
        locationLng: pet.locationLng,
        shelterId: pet.shelterId,
        isAdopted: pet.isAdopted,
      );

      await remoteDataSource.createPet(petModel, imageFile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<PetEntity>>> getPets() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      final pets = await remoteDataSource.getPets();
      return Right(pets);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<PetEntity>>> getMyPets(String shelterId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      final pets = await remoteDataSource.getMyPets(shelterId);
      return Right(pets);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> updatePet(
      {required PetEntity pet, File? newImage}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      // Convertir Entity a Model
      final petModel = PetModel(
        id: pet.id,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        age: pet.age,
        size: pet.size,
        gender: pet.gender,
        description: pet.description,
        imageUrl: pet.imageUrl,
        locationLat: pet.locationLat,
        locationLng: pet.locationLng,
        shelterId: pet.shelterId,
        isAdopted: pet.isAdopted,
      );

      await remoteDataSource.updatePet(petModel, newImage);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String petId, String imageUrl) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      await remoteDataSource.deletePet(petId, imageUrl);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
