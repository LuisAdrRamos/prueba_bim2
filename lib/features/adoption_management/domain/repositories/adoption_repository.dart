import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/adoption_request.dart';

abstract class AdoptionRepository {
  // 1. Enviar solicitud (Actualizado con datos de contacto)
  Future<Either<Failure, void>> submitRequest({
    required String petId,
    required String adopterId,
    required String shelterId,
    String? message,
    required String adopterName, // <--- Nuevo
    required String adopterEmail, // <--- Nuevo
  });

  // 2. Ver mis solicitudes enviadas (Adoptante)
  Future<Either<Failure, List<AdoptionRequest>>> getAdopterRequests(
      String userId);

  // 3. Ver solicitudes recibidas (Refugio)
  Future<Either<Failure, List<AdoptionRequest>>> getShelterRequests(
      String shelterId);

  // 4. Actualizar estado (Aceptar/Rechazar)
  Future<Either<Failure, void>> updateRequestStatus(
      String requestId, String status);
}
