import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import 'core/constants/app_constants.dart';
import 'injection_container.config.dart';

// Definimos la instancia global
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // 1. Inicializar Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // 2. Registrar Dependencias Externas (Que no tienen anotaciones @injectable)
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // NECESARIO: Registramos http.Client manualmente porque es una librería externa
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // 3. Inicializar TODAS las inyecciones generadas (Auth, Pets Y Chat IA)
  // Al llamar a esto, se leen las anotaciones @injectable de tus archivos nuevos
  getIt.init();
}
