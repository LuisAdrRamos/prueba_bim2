import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'injection_container.dart'; // Da acceso a getIt y configureDependencies

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. CARGA SEGURA DEL .ENV (Corrección clave)
  // Usamos try-catch para que la app no muera si falla la carga del archivo
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ Advertencia: No se pudo cargar el archivo .env: $e");
  }

  // 2. INICIALIZAR DEPENDENCIAS
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Inyectamos el AuthBloc y lanzamos el evento de verificación al inicio
      create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'PetAdopt',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Manejador de estado global de Autenticación
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Solo mostramos loading global si el BLoC está recién creado
            if (state is AuthInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Si está autenticado -> Vamos adentro
            else if (state is AuthAuthenticated) {
              return WelcomePage(user: state.user);
            }

            // Si no está autenticado, hubo error, o está cargando el login -> Vamos al Login
            else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
