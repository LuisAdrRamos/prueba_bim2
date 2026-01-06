import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/adoption_bloc.dart';
import '../bloc/adoption_event.dart';
import '../bloc/adoption_state.dart';

class MyAdoptionRequestsPage extends StatelessWidget {
  final String userId;

  const MyAdoptionRequestsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Inyectamos el BLoC y cargamos las solicitudes del usuario AL INICIAR
      create: (_) => getIt<AdoptionBloc>()..add(LoadAdopterRequests(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Solicitudes'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: const Color(0xFFF5F7FA),
        body: BlocBuilder<AdoptionBloc, AdoptionState>(
          builder: (context, state) {
            if (state is AdoptionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdoptionListLoaded) {
              if (state.requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open,
                          size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      const Text('Aún no has solicitado adopciones.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final req = state.requests[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Foto de la mascota
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              req.petImage ?? '',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[200],
                                child:
                                    const Icon(Icons.pets, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Detalles
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.petName ?? 'Mascota',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Enviada: ${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                _StatusBadge(status: req.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is AdoptionError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'approved':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = '¡Aprobada! 🎉';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Rechazada';
        icon = Icons.cancel;
        break;
      default:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        text = 'Pendiente';
        icon = Icons.access_time_filled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
