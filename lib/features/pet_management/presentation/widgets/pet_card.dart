import 'package:flutter/material.dart';
import '../../domain/entities/pet_entity.dart';

class PetCard extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback onTap;

  const PetCard({super.key, required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
            // Imagen
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Hero(
                  tag: pet.id, // Animación suave al abrir detalle
                  child: Image.network(
                    pet.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child:
                          Icon(Icons.pets, size: 40, color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),
            ),
            // Información
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
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Icono de género (opcional)
                      Icon(
                        pet.gender == 'Macho' ? Icons.male : Icons.female,
                        size: 16,
                        color:
                            pet.gender == 'Macho' ? Colors.blue : Colors.pink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.breed} • ${pet.age}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
