import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/adoption_request.dart';
import '../../domain/repositories/adoption_repository.dart';
import '../datasources/adoption_remote_data_source.dart';

@LazySingleton(as: AdoptionRepository)
class AdoptionRepositoryImpl implements AdoptionRepository {
  final AdoptionRemoteDataSource remoteDataSource;

  AdoptionRepositoryImpl(this.remoteDataSource);

  // --- 1. Enviar Solicitud (Versión Única y Correcta) ---
  @override
  Future<Either<Failure, void>> submitRequest({
    required String petId,
    required String adopterId,
    required String shelterId,
    String? message,
    required String adopterName,
    required String adopterEmail,
  }) async {
    try {
      await remoteDataSource.submitRequest(
        petId: petId,
        adopterId: adopterId,
        shelterId: shelterId,
        message: message,
        adopterName: adopterName,
        adopterEmail: adopterEmail,
      );
      return const Right(null);
    } catch (e) {
      // Limpiamos el mensaje de error "Exception:"
      final msg = e.toString().replaceAll('Exception: ', '');
      return Left(ServerFailure(msg));
    }
  }

  // --- 2. Ver solicitudes del Adoptante ---
  @override
  Future<Either<Failure, List<AdoptionRequest>>> getAdopterRequests(
      String userId) async {
    try {
      final requests = await remoteDataSource.getAdopterRequests(userId);
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // --- 3. Ver solicitudes del Refugio ---
  @override
  Future<Either<Failure, List<AdoptionRequest>>> getShelterRequests(
      String shelterId) async {
    try {
      final requests = await remoteDataSource.getShelterRequests(shelterId);
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // --- 4. Actualizar Estado ---
  @override
  Future<Either<Failure, void>> updateRequestStatus(
      String requestId, String status) async {
    try {
      await remoteDataSource.updateRequestStatus(requestId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
