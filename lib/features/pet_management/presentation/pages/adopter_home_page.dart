import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../ai_assistant/presentation/pages/chat_page.dart';
import '../../../ai_assistant/presentation/bloc/chat_bloc.dart';

import '../../../adoption_management/presentation/pages/my_adoption_requests_page.dart';

import '../bloc/pet_bloc.dart';
import '../bloc/pet_event.dart';
import '../bloc/pet_state.dart';
import '../widgets/pet_card.dart';
import 'pet_detail_page.dart';
import 'map_page.dart';

class AdopterHomePage extends StatefulWidget {
  const AdopterHomePage({super.key});

  @override
  State<AdopterHomePage> createState() => _AdopterHomePageState();
}

class _AdopterHomePageState extends State<AdopterHomePage> {
  int _currentIndex = 0;
  String _currentFilter = 'Todos';
  String _searchQuery = '';
  Timer? _debounce;
  LatLng? _userPosition;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _userPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  void _onFilterChanged(BuildContext context, String filter) {
    setState(() => _currentFilter = filter);
    context
        .read<PetBloc>()
        .add(LoadPets(filter: filter, searchQuery: _searchQuery));
  }

  void _onSearchChanged(BuildContext context, String query) {
    setState(() => _searchQuery = query);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context
          .read<PetBloc>()
          .add(LoadPets(filter: _currentFilter, searchQuery: _searchQuery));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario para sacar su ID y Nombre
    final authState = context.watch<AuthBloc>().state;
    String userName = 'Amante de los animales';
    String userId = '';

    if (authState is AuthAuthenticated) {
      userName = authState.user.displayName ?? 'Usuario';
      userId = authState.user.id;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<PetBloc>()..add(const LoadPets()),
        ),
        // Proveedor de Chat persistente
        BlocProvider(
          create: (_) => getIt<ChatBloc>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
        body: SafeArea(
          // USAMOS INDEXEDSTACK PARA 5 PANTALLAS
          child: IndexedStack(
            index: _currentIndex,
            children: [
              // 0. Inicio
              _buildHomeBody(context, userName),

              // 1. Mapa
              const MapPage(),

              // 2. Chat IA
              const ChatPage(),

              // 3. Solicitudes (AQUÍ ESTÁ EL CAMBIO)
              // Pasamos el userId para cargar sus solicitudes
              MyAdoptionRequestsPage(userId: userId),

              // 4. Perfil
              const ProfilePage(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFFF8B3D),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined), label: 'Mapa'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: 'Chat IA'),
            // NUEVO ITEM SEGÚN EL CONCEPTO (Corazón)
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border), label: 'Solicitudes'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  // Cuerpo del Home (Sin cambios, solo copia y pega para mantenerlo)
  Widget _buildHomeBody(BuildContext context, String userName) {
    return Builder(builder: (homeContext) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, $userName 👋',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('Encuentra tu mascota',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D3436))),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black54),
                    onPressed: () =>
                        context.read<AuthBloc>().add(const SignOutRequested()),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              onChanged: (value) => _onSearchChanged(homeContext, value),
              decoration: InputDecoration(
                hintText: 'Buscar mascota...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _FilterChip(
                  label: 'Todos',
                  isSelected: _currentFilter == 'Todos',
                  onTap: () => _onFilterChanged(homeContext, 'Todos'),
                ),
                _FilterChip(
                  label: 'Perro',
                  isSelected: _currentFilter == 'Perro',
                  onTap: () => _onFilterChanged(homeContext, 'Perro'),
                ),
                _FilterChip(
                  label: 'Gato',
                  isSelected: _currentFilter == 'Gato',
                  onTap: () => _onFilterChanged(homeContext, 'Gato'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<PetBloc, PetState>(
              builder: (context, state) {
                if (state is PetLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PetLoaded) {
                  if (state.pets.isEmpty) {
                    return Center(
                        child: Text('No hay mascotas ($_currentFilter)'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => context.read<PetBloc>().add(LoadPets(
                        filter: _currentFilter, searchQuery: _searchQuery)),
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: state.pets.length,
                      itemBuilder: (context, index) {
                        final pet = state.pets[index];
                        return PetCard(
                          pet: pet,
                          userLocation: _userPosition,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PetDetailPage(
                                  pet: pet,
                                  userLocation: _userPosition,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8B3D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: const Color(0xFFFF8B3D).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
