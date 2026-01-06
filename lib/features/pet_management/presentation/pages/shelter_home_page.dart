import 'dart:async'; // Necesario para el Timer del buscador (Debounce)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../domain/entities/pet_entity.dart';
import '../bloc/pet_bloc.dart';
import '../bloc/pet_event.dart';
import '../bloc/pet_state.dart';
import 'create_pet_page.dart';
import '../../../adoption_management/presentation/pages/incoming_requests_page.dart';

class ShelterHomePage extends StatefulWidget {
  final String userId;
  const ShelterHomePage({super.key, required this.userId});

  @override
  State<ShelterHomePage> createState() => _ShelterHomePageState();
}

class _ShelterHomePageState extends State<ShelterHomePage> {
  int _currentIndex = 0;

  // Variables para filtros
  String _currentFilter = 'Todos';
  String _searchQuery = '';
  Timer? _debounce; // Para no buscar en cada tecla, sino al dejar de escribir

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Función para manejar el cambio de filtro (Especie)
  void _onFilterChanged(BuildContext context, String filter) {
    setState(() => _currentFilter = filter);
    context.read<PetBloc>().add(LoadMyPets(widget.userId,
        filter: _currentFilter, searchQuery: _searchQuery));
  }

  // Función para manejar la búsqueda (Nombre)
  void _onSearchChanged(BuildContext context, String query) {
    setState(() => _searchQuery = query);

    // Usamos un "debounce" para esperar 500ms a que termine de escribir
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<PetBloc>().add(LoadMyPets(widget.userId,
          filter: _currentFilter, searchQuery: _searchQuery));
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String shelterName = 'Refugio';
    if (authState is AuthAuthenticated) {
      shelterName = authState.user.displayName ?? 'Refugio';
    }

    return BlocProvider(
      create: (_) => getIt<PetBloc>()..add(LoadMyPets(widget.userId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CreatePetPage()));
                  if (context.mounted) setState(() {});
                },
                label: const Text('Nueva Mascota'),
                icon: const Icon(Icons.add),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              )
            : null,
        body: SafeArea(
          child: _currentIndex == 0
              ? _buildDashboard(context, shelterName)
              : _currentIndex == 1
                  ? IncomingRequestsPage(shelterId: widget.userId)
                  : const ProfilePage(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Theme.of(context).colorScheme.primary,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Panel'),
            BottomNavigationBarItem(
                icon: Icon(Icons.description), label: 'Solicitudes'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, String name) {
    // Usamos un Builder interno para tener acceso al contexto del PetBloc
    return Builder(builder: (dashboardContext) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado + Buscador
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Panel de Administración',
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text(name,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436))),
                      ],
                    ),
                    // Botón de Salir (Igual que en Adoptante)
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF5F7FA),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.black54),
                        onPressed: () => dashboardContext
                            .read<AuthBloc>()
                            .add(const SignOutRequested()),
                      ),
                    ),
                  ],
                ),
                
                // BUSCADOR
                TextField(
                  onChanged: (value) =>
                      _onSearchChanged(dashboardContext, value),
                  decoration: InputDecoration(
                    hintText: 'Buscar mascota...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),

                const SizedBox(height: 16),

                // FILTROS (Chips)
                Row(
                  children: [
                    _AdminFilterChip(
                        label: 'Todos',
                        isSelected: _currentFilter == 'Todos',
                        onTap: () =>
                            _onFilterChanged(dashboardContext, 'Todos')),
                    const SizedBox(width: 8),
                    _AdminFilterChip(
                        label: 'Perro',
                        isSelected: _currentFilter == 'Perro',
                        onTap: () =>
                            _onFilterChanged(dashboardContext, 'Perro')),
                    const SizedBox(width: 8),
                    _AdminFilterChip(
                        label: 'Gato',
                        isSelected: _currentFilter == 'Gato',
                        onTap: () =>
                            _onFilterChanged(dashboardContext, 'Gato')),
                  ],
                ),
              ],
            ),
          ),

          // Grilla de Resultados
          Expanded(
            child: BlocBuilder<PetBloc, PetState>(
              builder: (context, state) {
                if (state is PetLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state is PetLoaded) {
                  if (state.pets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text('No se encontraron mascotas ($_currentFilter)'),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<PetBloc>().add(LoadMyPets(
                              widget.userId,
                              filter: _currentFilter,
                              searchQuery: _searchQuery,
                            )),
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: state.pets.length,
                      itemBuilder: (context, index) {
                        final pet = state.pets[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Foto
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Image.network(
                                    pet.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.pets)),
                                  ),
                                ),
                              ),
                              // Datos
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pet.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text(pet.breed,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                        maxLines: 1),
                                  ],
                                ),
                              ),
                              // Botones
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => CreatePetPage(
                                                      petToEdit: pet)));
                                          if (context.mounted)
                                            context.read<PetBloc>().add(
                                                LoadMyPets(widget.userId,
                                                    filter: _currentFilter));
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 30),
                                          side: BorderSide(
                                              color: Colors.blue.shade200),
                                        ),
                                        child: const Icon(Icons.edit,
                                            size: 16, color: Colors.blue),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _confirmDelete(context, pet),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 30),
                                          side: BorderSide(
                                              color: Colors.red.shade200),
                                        ),
                                        child: const Icon(Icons.delete,
                                            size: 16, color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
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

  void _confirmDelete(BuildContext context, PetEntity pet) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar mascota?'),
        content: Text(
            'Estás a punto de eliminar a ${pet.name}. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PetBloc>().add(DeletePet(
                  petId: pet.id,
                  imageUrl: pet.imageUrl,
                  shelterId: widget.userId));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Chip de filtro simple (Copia local estilizada para admin)
class _AdminFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminFilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
