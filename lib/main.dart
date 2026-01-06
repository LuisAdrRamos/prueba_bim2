import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'PetAdopt', // Cambiado nombre a PetAdopt
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // CORRECCIÓN CLAVE AQUÍ:
            // Solo mostramos el spinner global si estamos en el estado INICIAL puro.
            // Si es 'AuthLoading', dejamos que LoginPage o WelcomePage manejen su propio loading.
            if (state is AuthInitial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Si el usuario está autenticado, vamos al Home/Welcome
            else if (state is AuthAuthenticated) {
              return WelcomePage(user: state.user);
            }

            // Para cualquier otro estado (Unauthenticated, Loading, Error),
            // mostramos el Login. El Login ya tiene su propio LoadingOverlay.
            else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
