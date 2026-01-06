import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // Para LatLng y Distance
import '../../domain/entities/pet_entity.dart';

class PetCard extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback onTap;
  final LatLng? userLocation; // <--- Recibimos ubicación del usuario

  const PetCard({
    super.key,
    required this.pet,
    required this.onTap,
    this.userLocation, // Opcional (puede ser null si no hay GPS)
  });

  // Función auxiliar para calcular distancia
  String _calculateDistance() {
    if (userLocation == null) return '';
    // Si la mascota no tiene ubicación (0,0), no mostramos nada
    if (pet.locationLat == 0 && pet.locationLng == 0) return '';

    final Distance distance = const Distance();
    final double km = distance.as(
      LengthUnit.Kilometer,
      userLocation!,
      LatLng(pet.locationLat, pet.locationLng),
    );

    if (km < 1) {
      // Si es menos de 1km, mostramos metros
      final double meters = distance.as(
        LengthUnit.Meter,
        userLocation!,
        LatLng(pet.locationLat, pet.locationLng),
      );
      return '${meters.round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final distanceText = _calculateDistance();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGEN
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Hero(
                        tag: pet.id,
                        child: Image.network(
                          pet.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.pets,
                                size: 40, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // INFORMACIÓN
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
                            color: Color(0xFF2D3436),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        pet.gender == 'Macho' ? Icons.male : Icons.female,
                        size: 16,
                        color:
                            pet.gender == 'Macho' ? Colors.blue : Colors.pink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Raza y Edad
                  Text(
                    '${pet.breed} • ${pet.age}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // --- NUEVA TARJETA DE UBICACIÓN ---
                  if (distanceText.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14,
                            color: Color(0xFFFF8B3D)), // Color Naranja marca
                        const SizedBox(width: 4),
                        Text(
                          distanceText, // "2.5 km"
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    )
                  else
                    // Si no hay ubicación, mostramos algo genérico o nada
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          'Ver ubicación',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
