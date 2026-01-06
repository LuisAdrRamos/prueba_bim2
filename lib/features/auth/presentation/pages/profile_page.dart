import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Foto de perfil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: user.photoUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            size: 20, color: Colors.white),
                        onPressed: () {
                          // TODO: Implementar subida de foto de perfil (Fase de Refinamiento 2)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Próximamente: Editar foto')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Datos
            _ProfileItem(
                title: 'Nombre',
                value: user.displayName ?? 'No especificado',
                icon: Icons.person_outline),
            _ProfileItem(
                title: 'Correo', value: user.email, icon: Icons.email_outlined),
            _ProfileItem(
                title: 'Rol',
                value: user.role == 'shelter'
                    ? 'Refugio / Fundación'
                    : 'Adoptante',
                icon: Icons.verified_user_outlined),

            const SizedBox(height: 40),

            // Botones de acción
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navegar a pantalla de editar datos
                },
                child: const Text('Editar Perfil'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(const SignOutRequested());
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst); // Volver al inicio
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileItem(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
