import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print('🟡 REPO: Iniciando login para $email'); // DEBUG

    // 1. Desactivamos temporalmente el check de internet para probar si es el culpable
    // if (!await networkInfo.isConnected) {
    //   print('🔴 REPO: Sin internet');
    //   return const Left(NetworkFailure('Sin conexión a internet'));
    // }

    try {
      print('🟡 REPO: Llamando a Supabase DataSource...');
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('🟢 REPO: Login exitoso!');
      return Right(user);
    } catch (e) {
      print('🔴 REPO: Error capturado -> $e'); // DEBUG CRÍTICO
      // Limpiamos el mensaje de error para que se vea bonito en el SnackBar
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      return Left(AuthFailure(cleanMessage));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? role,
  }) async {
    print('🟡 REPO: Iniciando registro');
    // if (!await networkInfo.isConnected) {
    //   return const Left(NetworkFailure('Sin conexión a internet'));
    // }

    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      return Right(user);
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      return Left(AuthFailure(cleanMessage));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }
}
