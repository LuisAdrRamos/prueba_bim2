import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import 'core/constants/app_constants.dart';
import 'injection_container.config.dart';

// --- IMPORTS: ADOPTION FEATURE ---
import 'features/adoption_management/data/datasources/adoption_remote_data_source.dart';
import 'features/adoption_management/data/repositories/adoption_repository_impl.dart';
import 'features/adoption_management/domain/repositories/adoption_repository.dart';
import 'features/adoption_management/presentation/bloc/adoption_bloc.dart';

// Definimos la instancia global
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // 1. Inicializar Supabase (Base de datos)
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // 2. Registrar Dependencias Externas
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // 3. Inicializar inyecciones generadas automáticamente
  // (Aquí se cargan Auth, Pets y el Chat IA si usaste @injectable)
  getIt.init();

  // Data Source
  getIt.registerLazySingleton<AdoptionRemoteDataSource>(
    () => AdoptionRemoteDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<AdoptionRepository>(
    () => AdoptionRepositoryImpl(getIt()),
  );

  // BLoC
  getIt.registerFactory(
    () => AdoptionBloc(getIt()),
  );
}
