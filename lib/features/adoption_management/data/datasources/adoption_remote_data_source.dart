import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/adoption_request_model.dart';

abstract class AdoptionRemoteDataSource {
  Future<void> submitRequest({
    required String petId,
    required String adopterId,
    required String shelterId,
    String? message,
    // Nuevos campos de contacto
    required String adopterName,
    required String adopterEmail,
  });

  Future<List<AdoptionRequestModel>> getAdopterRequests(String userId);
  Future<List<AdoptionRequestModel>> getShelterRequests(
      String shelterId); // <--- NUEVO
  Future<void> updateRequestStatus(
      String requestId, String status); // <--- NUEVO
}

@LazySingleton(as: AdoptionRemoteDataSource)
class AdoptionRemoteDataSourceImpl implements AdoptionRemoteDataSource {
  final SupabaseClient client;

  AdoptionRemoteDataSourceImpl(this.client);

  @override
  Future<void> submitRequest({
    required String petId,
    required String adopterId,
    required String shelterId,
    String? message,
    required String adopterName,
    required String adopterEmail,
  }) async {
    try {
      // Validar duplicados
      final existing = await client
          .from('adoption_requests')
          .select()
          .eq('pet_id', petId)
          .eq('adopter_id', adopterId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existing != null) {
        throw Exception('Ya tienes una solicitud pendiente para esta mascota.');
      }

      // Guardamos con los datos del adoptante
      await client.from('adoption_requests').insert({
        'pet_id': petId,
        'adopter_id': adopterId,
        'shelter_id': shelterId,
        'message': message,
        'status': 'pending',
        'adopter_name': adopterName, // <--- Guardamos nombre
        'adopter_email': adopterEmail, // <--- Guardamos email
      });
    } catch (e) {
      throw Exception('Error al enviar solicitud: $e');
    }
  }

  // Ver mis solicitudes (Adoptante)
  @override
  Future<List<AdoptionRequestModel>> getAdopterRequests(String userId) async {
    try {
      final response = await client
          .from('adoption_requests')
          .select('*, pets(name, image_url)')
          .eq('adopter_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AdoptionRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar solicitudes: $e');
    }
  }

  // Ver solicitudes recibidas (Refugio)
  @override
  Future<List<AdoptionRequestModel>> getShelterRequests(
      String shelterId) async {
    try {
      final response = await client
          .from('adoption_requests')
          .select('*, pets(name, image_url)')
          .eq('shelter_id', shelterId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AdoptionRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar solicitudes del refugio: $e');
    }
  }

  // Aceptar o Rechazar
  @override
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await client
          .from('adoption_requests')
          .update({'status': status}).eq('id', requestId);
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }
}
