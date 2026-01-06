import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import 'email_verification_sent_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Estado para el rol seleccionado
  String _selectedRole = 'adopter'; // 'adopter' o 'shelter'

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName: _nameController.text.trim(),
              role: _selectedRole, // Enviamos el rol seleccionado
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is EmailVerificationRequired) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) =>
                      EmailVerificationSentPage(email: state.email)),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is AuthLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('¿Quién eres?',
                          style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 8),
                      const Text(
                          'Selecciona el tipo de cuenta que deseas crear'),
                      const SizedBox(height: 24),

                      // SELECCIÓN DE ROL (Tarjetas)
                      Row(
                        children: [
                          Expanded(
                              child: _RoleCard(
                            title: 'Adoptante',
                            icon: Icons.home_rounded,
                            isSelected: _selectedRole == 'adopter',
                            onTap: () =>
                                setState(() => _selectedRole = 'adopter'),
                            color: const Color(0xFFFF8B3D),
                          )),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _RoleCard(
                            title: 'Refugio',
                            icon: Icons.pets_rounded,
                            isSelected: _selectedRole == 'shelter',
                            onTap: () =>
                                setState(() => _selectedRole = 'shelter'),
                            color: const Color(0xFF00BFA5),
                          )),
                        ],
                      ),
                      const SizedBox(height: 32),

                      CustomTextField(
                        controller: _nameController,
                        label: _selectedRole == 'shelter'
                            ? 'Nombre del Refugio'
                            : 'Nombre Completo',
                        hint: _selectedRole == 'shelter'
                            ? 'Refugio de Animales'
                            : 'Nombre Apellido',
                        prefixIcon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Correo electrónico',
                        hint: 'hola@ejemplo.com',
                        prefixIcon: Icons.email_outlined,
                        validator: (v) =>
                            !v!.contains('@') ? 'Email inválido' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (v) =>
                            v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: state is AuthLoading ? null : _handleSignUp,
                        child: Text(
                            'Crear cuenta como ${_selectedRole == 'shelter' ? 'Refugio' : 'Adoptante'}'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget auxiliar para las tarjetas de selección
class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
