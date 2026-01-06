import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

// Imports de Arquitectura
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart'; // Importante para pasar el usuario
import '../../../adoption_management/presentation/bloc/adoption_bloc.dart';
import '../../../adoption_management/presentation/bloc/adoption_event.dart';
import '../../../adoption_management/presentation/bloc/adoption_state.dart';
import '../../domain/entities/pet_entity.dart';

class PetDetailPage extends StatelessWidget {
  final PetEntity pet;
  final LatLng? userLocation;
  final String? locationName;

  const PetDetailPage({
    super.key,
    required this.pet,
    this.userLocation,
    this.locationName,
  });

  // --- Lógica de UI existente ---
  String _calculateDistance() {
    if (userLocation == null) return '';
    if (pet.locationLat == 0 && pet.locationLng == 0) return '';
    final Distance distance = const Distance();
    final double km = distance.as(
      LengthUnit.Kilometer,
      userLocation!,
      LatLng(pet.locationLat, pet.locationLng),
    );
    if (km < 1) {
      final double meters = distance.as(
        LengthUnit.Meter,
        userLocation!,
        LatLng(pet.locationLat, pet.locationLng),
      );
      return '${meters.round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  String _getLocationName() {
    if (locationName != null && locationName!.isNotEmpty) return locationName!;
    final lat = pet.locationLat;
    final lng = pet.locationLng;
    if ((lat - -0.210300).abs() < 0.001 && (lng - -78.489000).abs() < 0.001) {
      return 'Poliperros EPN';
    }
    if ((lat - -0.217300).abs() < 0.001 && (lng - -78.402000).abs() < 0.001) {
      return 'PAE Tumbaco';
    }
    if ((lat - -0.180653).abs() < 0.001 && (lng - -78.467834).abs() < 0.001) {
      return 'Parque La Carolina';
    }
    return 'Refugio Aliado';
  }

  // --- CORRECCIÓN DEL DIÁLOGO ---
  // Ahora recibe UserEntity completo para sacar nombre y email
  void _showAdoptionDialog(BuildContext context, UserEntity user) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Solicitar Adopción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Estás a un paso de solicitar a ${pet.name}. El refugio recibirá tus datos.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              // ERROR CORREGIDO: Quitamos 'const' aquí
              decoration: InputDecoration(
                hintText: 'Hola, me interesa adoptar a ${pet.name} porque...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Cerrar diálogo

              // ERROR CORREGIDO: Enviamos todos los parámetros requeridos
              context.read<AdoptionBloc>().add(
                    SubmitAdoptionRequest(
                      petId: pet.id,
                      adopterId: user.id,
                      shelterId: pet.shelterId,
                      message: messageController.text.trim(),
                      adopterName:
                          user.displayName ?? 'Usuario Anónimo', // Nuevo
                      adopterEmail: user.email, // Nuevo
                    ),
                  );
            },
            child: const Text('Enviar Solicitud'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distanceText = _calculateDistance();
    final placeName = _getLocationName();

    return BlocProvider(
      create: (_) => getIt<AdoptionBloc>(),
      child: BlocConsumer<AdoptionBloc, AdoptionState>(
        listener: (context, state) {
          if (state is AdoptionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AdoptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFF8F0),
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // AppBar
                    SliverAppBar(
                      expandedHeight: 350,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.5),
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Hero(
                          tag: pet.id,
                          child: Image.network(
                            pet.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: Icon(Icons.pets,
                                      size: 50, color: Colors.grey)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Contenido
                    SliverToBoxAdapter(
                      child: Container(
                        transform: Matrix4.translationValues(0, -20, 0),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF8F0),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.name,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3436),
                                        ),
                                      ),
                                      Text(
                                        pet.breed,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2F1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Disponible',
                                    style: TextStyle(
                                      color: Color(0xFF00695C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Ubicación
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                        Icons.store_mall_directory,
                                        color: Color(0xFF00695C),
                                        size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          placeName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF2D3436),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (distanceText.isNotEmpty)
                                          Row(
                                            children: [
                                              const Icon(Icons.near_me,
                                                  size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                'A $distanceText de ti',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          )
                                        else
                                          Text(
                                            'Ver en mapa',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600]),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _InfoBox(title: 'Edad', value: pet.age),
                                _InfoBox(title: 'Sexo', value: pet.gender),
                                _InfoBox(title: 'Tamaño', value: pet.size),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Descripción
                            const Text(
                              'Sobre mí',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pet.description,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Loader
                if (state is AdoptionLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),

            // BOTÓN
            floatingActionButton: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FloatingActionButton.extended(
                onPressed: state is AdoptionLoading
                    ? null
                    : () {
                        // 1. Obtenemos el usuario autenticado
                        final authState = context.read<AuthBloc>().state;

                        if (authState is AuthAuthenticated) {
                          // 2. Pasamos el USUARIO ENTERO al diálogo
                          _showAdoptionDialog(context, authState.user);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Debes iniciar sesión primero')),
                          );
                        }
                      },
                backgroundColor: const Color(0xFFFF8B3D),
                label: const Text('Solicitar Adopción',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                icon: const Icon(Icons.favorite, color: Colors.white),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFFF8B3D)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
