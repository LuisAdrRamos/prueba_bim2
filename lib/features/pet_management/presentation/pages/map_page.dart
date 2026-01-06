import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/pet_bloc.dart';
import '../bloc/pet_event.dart';
import '../bloc/pet_state.dart';
import '../../domain/entities/pet_entity.dart'; // Import necesario
import 'pet_detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _myLocation;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    // ... (Misma lógica de permisos que ya tenías, la omito para ahorrar espacio visual, mantenla igual) ...
    // Asegúrate de copiar tu lógica de _determinePosition aquí
    // Si quieres te la pego completa abajo, pero es la misma de antes.
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController.move(_myLocation!, 14.0);
    }
  }

  String _getDistanceString(LatLng point) {
    if (_myLocation == null) return 'Calculando...';
    final Distance distance = const Distance();
    final double km = distance.as(LengthUnit.Kilometer, _myLocation!, point);
    if (km < 1) {
      final double m = distance.as(LengthUnit.Meter, _myLocation!, point);
      return '${m.round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  // Helper para obtener nombre del lugar basado en coordenadas (Hardcode inverso)
  String _getLocationName(double lat, double lng) {
    // Tolerancia pequeña por si los decimales varían mínimamente
    if ((lat - -0.210300).abs() < 0.001 && (lng - -78.489000).abs() < 0.001)
      return 'Poliperros EPN';
    if ((lat - -0.217300).abs() < 0.001 && (lng - -78.402000).abs() < 0.001)
      return 'PAE Tumbaco';
    if ((lat - -0.180653).abs() < 0.001 && (lng - -78.467834).abs() < 0.001)
      return 'Parque La Carolina';
    return 'Refugio Registrado';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PetBloc>()..add(const LoadPets()),
      child: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(-0.180653, -78.467834),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.petadopt',
                ),
                BlocBuilder<PetBloc, PetState>(
                  builder: (context, state) {
                    List<Marker> markers = [];

                    // 1. MI UBICACIÓN
                    if (_myLocation != null) {
                      markers.add(
                        Marker(
                          point: _myLocation!,
                          width: 60,
                          height: 60,
                          child: const Column(
                            children: [
                              Icon(Icons.location_history,
                                  color: Colors.blue, size: 40),
                              Text('Yo',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }

                    // 2. LOGICA DE AGRUPACIÓN DE MASCOTAS
                    if (state is PetLoaded) {
                      // Map para agrupar: "lat,lng" -> [Lista de mascotas]
                      final Map<String, List<PetEntity>> groupedPets = {};

                      for (var pet in state.pets) {
                        if (pet.locationLat == 0 && pet.locationLng == 0)
                          continue;

                        // Clave única basada en posición
                        final key = '${pet.locationLat},${pet.locationLng}';
                        if (!groupedPets.containsKey(key)) {
                          groupedPets[key] = [];
                        }
                        groupedPets[key]!.add(pet);
                      }

                      // Crear un marcador por cada GRUPO (Ubicación)
                      groupedPets.forEach((key, petsAtLocation) {
                        final lat = petsAtLocation.first.locationLat;
                        final lng = petsAtLocation.first.locationLng;
                        final point = LatLng(lat, lng);
                        final count = petsAtLocation.length;

                        markers.add(
                          Marker(
                            point: point,
                            width: 60, height: 60, // Un poco más grande
                            child: GestureDetector(
                              onTap: () {
                                _showPetsAtLocation(
                                    context, petsAtLocation, point);
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.red, size: 50),
                                  // Si hay más de 1, mostramos el número
                                  if (count > 1)
                                    Positioned(
                                      top: 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$count',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    }
                    return MarkerLayer(markers: markers);
                  },
                ),
              ],
            ),

            // Botón GPS (Igual que antes)
            Positioned(
              right: 20,
              bottom: 40,
              child: FloatingActionButton(
                heroTag: 'gps_fab',
                onPressed: () {
                  if (_myLocation != null)
                    _mapController.move(_myLocation!, 15.0);
                  else
                    _determinePosition();
                },
                child: _isLoadingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(color: Colors.white))
                    : const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NUEVO MODAL: LISTA DE MASCOTAS ---
  void _showPetsAtLocation(
      BuildContext context, List<PetEntity> pets, LatLng point) {
    final distanceStr = _getDistanceString(point);
    final locationName = _getLocationName(point.latitude, point.longitude);

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Para permitir que sea más alto si es necesario
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 400, // Altura fija suficiente para lista
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra deslizadora
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Título de la Ubicación
            Text(locationName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('A $distanceStr de ti',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('${pets.length} mascotas',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade900)),
                )
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),

            // LISTA DE MASCOTAS EN ESTE LUGAR
            Expanded(
              child: ListView.separated(
                itemCount: pets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Cerrar modal
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetDetailPage(
                            pet: pet,
                            userLocation: _myLocation,
                            locationName:
                                locationName, // Pasamos el nombre del lugar
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          // Foto
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              pet.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300]),
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pet.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text('${pet.breed} • ${pet.age}',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13)),
                                const SizedBox(height: 8),
                                const Text('Ver detalles >',
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
