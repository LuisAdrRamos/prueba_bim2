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
  // 1. Inicializar Supabase (Configuración global)
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // 2. Registrar Dependencias Externas (Librerías de terceros)
  // Estas NO tienen anotaciones @injectable, así que van manuales.
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // 3. Inicializar Inyección Automática
  // Esto carga TODAS tus features (Auth, Pets, AI, Adoption)
  // leyendo los archivos generados por build_runner.
  getIt.init();

  // ¡Y LISTO! No agregues nada más abajo.
}
