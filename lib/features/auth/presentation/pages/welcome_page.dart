import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import '../../../pet_management/presentation/pages/shelter_home_page.dart';
import '../../../pet_management/presentation/pages/adopter_home_page.dart';

class WelcomePage extends StatelessWidget {
  final UserEntity user;

  const WelcomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Envolvemos la decisión de vistas con un Listener que vigila la sesión
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Si el estado cambia a "No Autenticado" (cerró sesión), nos vamos al Login
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) =>
                false, // Elimina todas las pantallas anteriores del stack
          );
        }
      },
      // Aquí mantenemos tu lógica de roles
      child: user.role == 'shelter'
          ? ShelterHomePage(userId: user.id)
          : const AdopterHomePage(),
    );
  }
}
