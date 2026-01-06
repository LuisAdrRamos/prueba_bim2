import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/pet_model.dart';

abstract class PetRemoteDataSource {
  Future<void> createPet(PetModel pet, File imageFile);
  Future<List<PetModel>> getPets();
  Future<List<PetModel>> getMyPets(String shelterId);
  Future<void> updatePet(PetModel pet, File? newImage);
  Future<void> deletePet(String petId, String imageUrl);
}

@LazySingleton(as: PetRemoteDataSource)
class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final SupabaseClient supabaseClient;

  PetRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> createPet(PetModel pet, File imageFile) async {
    try {
      // 1. Subir Imagen al Bucket 'pets'
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';
      final filePath = 'pets/$fileName';

      await supabaseClient.storage.from('pets').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // 2. Obtener URL pública
      final imageUrl =
          supabaseClient.storage.from('pets').getPublicUrl(filePath);

      // 3. Guardar datos en tabla 'pets' con la URL de la imagen
      final petData = pet.toJson();
      petData['image_url'] = imageUrl; // Actualizamos la URL real

      await supabaseClient.from('pets').insert(petData);
    } catch (e) {
      throw Exception('Error al crear mascota: $e');
    }
  }

  @override
  Future<List<PetModel>> getPets() async {
    try {
      final response = await supabaseClient
          .from('pets')
          .select()
          .eq('is_adopted', false) // Solo las disponibles
          .order('created_at', ascending: false);

      return (response as List).map((e) => PetModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al cargar mascotas: $e');
    }
  }

  @override
  Future<List<PetModel>> getMyPets(String shelterId) async {
    try {
      final response = await supabaseClient
          .from('pets')
          .select()
          .eq('shelter_id', shelterId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => PetModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al cargar mis mascotas: $e');
    }
  }

  @override
  Future<void> updatePet(PetModel pet, File? newImage) async {
    try {
      String imageUrl = pet.imageUrl;

      // 1. Si hay nueva imagen, subirla
      if (newImage != null) {
        final fileExt = newImage.path.split('.').last;
        final fileName = '${const Uuid().v4()}.$fileExt';
        final filePath = 'pets/$fileName';

        await supabaseClient.storage.from('pets').upload(
              filePath,
              newImage,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        imageUrl = supabaseClient.storage.from('pets').getPublicUrl(filePath);

        // Opcional: Borrar la imagen vieja aquí si quieres ahorrar espacio
      }

      // 2. Actualizar datos en la tabla
      final petData = pet.toJson();
      petData['image_url'] =
          imageUrl; // Actualizamos con la nueva (o la misma) URL

      // Eliminamos campos que no deberían cambiar o que Supabase ignora
      petData.remove('id');
      petData.remove('created_at');

      await supabaseClient.from('pets').update(petData).eq('id', pet.id);
    } catch (e) {
      throw Exception('Error al actualizar mascota: $e');
    }
  }

  @override
  Future<void> deletePet(String petId, String imageUrl) async {
    try {
      // 1. Borrar registro de la Base de Datos
      await supabaseClient.from('pets').delete().eq('id', petId);

      // 2. Borrar imagen del Storage
      if (imageUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(imageUrl);
          // La URL suele terminar en .../pets/nombre_imagen.jpg
          // Tomamos el último segmento que es el nombre del archivo
          final fileName = uri.pathSegments.last;

          // Asumimos que guardaste en la carpeta 'pets/' dentro del bucket
          await supabaseClient.storage.from('pets').remove(['pets/$fileName']);
        } catch (e) {
          // Si falla borrar la foto, no detenemos el proceso principal
          print('No se pudo borrar la imagen del storage: $e');
        }
      }
    } catch (e) {
      throw Exception('Error al borrar mascota: $e');
    }
  }
}
