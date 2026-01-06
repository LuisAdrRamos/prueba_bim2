import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? role,
  });

  Future<UserModel> updateProfile({String? displayName, File? photoFile});

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('No se pudo iniciar sesión');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      // Interceptamos el error de Supabase y lo traducimos
      throw Exception(_mapSupabaseError(e));
    } catch (e) {
      throw Exception('Ocurrió un error inesperado al iniciar sesión.');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? role,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null) 'display_name': displayName,
          'role': role ?? 'adopter',
        },
      );

      // Si hay usuario pero no sesión, es que falta confirmar el correo
      if (response.user != null && response.session == null) {
        return UserModel.fromSupabaseUser(response.user!);
      }

      if (response.user == null) {
        throw Exception('No se pudo crear la cuenta');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw Exception(_mapSupabaseError(e));
    } catch (e) {
      throw Exception('Error al registrarse. Intenta de nuevo.');
    }
  }

  @override
  Future<UserModel> updateProfile(
      {String? displayName, File? photoFile}) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) throw Exception('No hay usuario autenticado');

      String? photoUrl;

      // 1. Si hay foto nueva, la subimos
      // Usamos el bucket 'pets' (o crea uno 'avatars' en Supabase y cambia el nombre aquí)
      if (photoFile != null) {
        final fileExt = photoFile.path.split('.').last;
        // Nombre único para evitar caché: id_timestamp.jpg
        final fileName =
            'avatars/${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        // 'upsert: true' permite sobrescribir si el nombre ya existe
        await supabaseClient.storage.from('pets').upload(
              fileName,
              photoFile,
              fileOptions: const FileOptions(upsert: true),
            );

        photoUrl = supabaseClient.storage.from('pets').getPublicUrl(fileName);
      }

      // 2. Actualizar datos en Auth (Metadata)
      final updates = UserAttributes(
        data: {
          if (displayName != null) 'display_name': displayName,
          // 'avatar_url' debe coincidir con lo que lee tu UserModel
          if (photoUrl != null) 'avatar_url': photoUrl,
        },
      );

      final response = await supabaseClient.auth.updateUser(updates);

      if (response.user == null) throw Exception('Error al actualizar perfil');

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado al actualizar perfil: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        // Asegúrate que este link coincida con el intent-filter en AndroidManifest
        redirectTo: 'loginpro://reset-callback',
      );
    } on AuthException catch (e) {
      throw Exception(_mapSupabaseError(e));
    } catch (e) {
      throw Exception('Error al enviar email de recuperación.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al cerrar sesión.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }

  // --- TRADUCTOR DE ERRORES ---
  String _mapSupabaseError(AuthException error) {
    final msg = error.message.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de entrar.';
    }
    if (msg.contains('user not found')) {
      return 'No existe una cuenta con este correo.';
    }
    if (msg.contains('password should be')) {
      return 'La contraseña es muy débil (mínimo 6 caracteres).';
    }
    if (msg.contains('already registered') ||
        msg.contains('user already exists')) {
      return 'Este correo ya está registrado.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Demasiados intentos. Espera unos minutos.';
    }

    return error.message;
  }
}
