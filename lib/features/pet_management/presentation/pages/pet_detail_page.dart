import 'package:flutter/material.dart';
import '../../domain/entities/pet_entity.dart';

class PetDetailPage extends StatelessWidget {
  final PetEntity pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Color crema suave del diseño
      body: CustomScrollView(
        slivers: [
          // AppBar Elástica con la Foto
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black), // Flecha negra
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: pet.id,
                child: Image.network(
                  pet.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Contenido redondeado
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0), // Subir un poco
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1), // Verde menta suave
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
                  const SizedBox(height: 24),

                  // Cajas de Info (Edad, Sexo, Tamaño)
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
      // Botón de Acción
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Implementar lógica de solicitud en Fase 5
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Funcionalidad de Solicitud en Fase 5')),
            );
          },
          backgroundColor: const Color(0xFFFF8B3D), // Naranja del diseño
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
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFFF8B3D))),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
