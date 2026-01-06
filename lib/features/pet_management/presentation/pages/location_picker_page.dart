import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialLocation; // Para cuando editamos

  const LocationPickerPage({super.key, this.initialLocation});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  // Coordenada por defecto (Quito Centro-Norte)
  LatLng _selectedLocation = const LatLng(-0.180653, -78.467834);
  final MapController _mapController = MapController();

  // DATOS QUEMADOS (Refugios conocidos)
  final Map<String, LatLng> _shelters = {
    'Poliperros EPN': const LatLng(-0.210300, -78.489000), // Cerca de la Poli
    'PAE Tumbaco': const LatLng(-0.217300, -78.402000), // Referencial
    'Parque La Carolina': const LatLng(-0.180653, -78.467834),
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      // Si la ubicación guardada no es 0,0, la usamos
      if (widget.initialLocation!.latitude != 0) {
        _selectedLocation = widget.initialLocation!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Retornamos la coordenada seleccionada a la pantalla anterior
              Navigator.pop(context, _selectedLocation);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Botones de "Datos Quemados" (Para el Ingeniero)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _shelters.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ActionChip(
                    avatar: const Icon(Icons.pin_drop, size: 16),
                    label: Text(entry.key),
                    onPressed: () {
                      setState(() {
                        _selectedLocation = entry.value;
                      });
                      _mapController.move(entry.value, 15.0);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. El Mapa Interactivo
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 14.0,
                onTap: (tapPosition, point) {
                  // Al tocar el mapa, movemos el pin
                  setState(() {
                    _selectedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.petadopt',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Coordenadas (Info visual)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ubicación seleccionada:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    '${_selectedLocation.latitude}, ${_selectedLocation.longitude}'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedLocation);
                    },
                    child: const Text('Confirmar Ubicación'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
