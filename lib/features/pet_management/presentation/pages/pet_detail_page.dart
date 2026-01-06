import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/pet_entity.dart';

class PetDetailPage extends StatelessWidget {
  final PetEntity pet;
  final LatLng? userLocation;
  final String? locationName;

  const PetDetailPage({
    super.key,
    required this.pet,
    this.userLocation, // Recibimos la ubicación del usuario
    this.locationName, // Recibimos el nombre del lugar (opcional)
  });

  // Función auxiliar para calcular distancia
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

  // Función para obtener el nombre del lugar
  String _getLocationName() {
    // 1. Si ya nos pasaron el nombre (desde el mapa), lo usamos directo
    if (locationName != null && locationName!.isNotEmpty) return locationName!;

    // 2. Si no (venimos del Home), intentamos deducirlo por coordenadas
    final lat = pet.locationLat;
    final lng = pet.locationLng;

    // Usamos una pequeña tolerancia para comparar floats
    if ((lat - -0.210300).abs() < 0.001 && (lng - -78.489000).abs() < 0.001) {
      return 'Poliperros EPN';
    }
    if ((lat - -0.217300).abs() < 0.001 && (lng - -78.402000).abs() < 0.001) {
      return 'PAE Tumbaco';
    }
    if ((lat - -0.180653).abs() < 0.001 && (lng - -78.467834).abs() < 0.001) {
      return 'Parque La Carolina';
    }

    // 3. Default si no coincide con ninguno
    return 'Refugio Aliado';
  }

  @override
  Widget build(BuildContext context) {
    final distanceText = _calculateDistance();
    final placeName = _getLocationName();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: CustomScrollView(
        slivers: [
          // --- 1. IMAGEN (AppBar Elástica) ---
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                        child: Icon(Icons.pets, size: 50, color: Colors.grey)),
                  ),
                ),
              ),
            ),
          ),

          // --- 2. CONTENIDO PRINCIPAL ---
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Nombre, Raza y Estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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

                  // --- TARJETA DE UBICACIÓN (NUEVO) ---
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
                        // Icono de Tienda/Refugio
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1), // Fondo menta suave
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.store_mall_directory,
                              color: Color(0xFF00695C), size: 24),
                        ),
                        const SizedBox(width: 16),
                        // Textos
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                placeName, // Muestra "Poliperros EPN", etc.
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Muestra la distancia si existe
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
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                        // Botón pequeño para ir al mapa (opcional visualmente)
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                  // ------------------------------------

                  const SizedBox(height: 24),

                  // Cajas de Información (Edad, Sexo, Tamaño)
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 100), // Espacio para el botón flotante
                ],
              ),
            ),
          ),
        ],
      ),

      // Botón Inferior
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Solicitud de adopción en construcción (Fase 5)')),
            );
          },
          backgroundColor: const Color(0xFFFF8B3D),
          label: const Text('Solicitar Adopción',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          icon: const Icon(Icons.favorite, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Widget auxiliar para las cajitas de info
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
