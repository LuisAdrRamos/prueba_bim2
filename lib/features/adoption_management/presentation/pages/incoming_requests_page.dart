import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/adoption_bloc.dart';
import '../bloc/adoption_event.dart';
import '../bloc/adoption_state.dart';

class IncomingRequestsPage extends StatelessWidget {
  final String shelterId;

  const IncomingRequestsPage({super.key, required this.shelterId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdoptionBloc>()..add(LoadShelterRequests(shelterId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Solicitudes Recibidas')),
        body: BlocBuilder<AdoptionBloc, AdoptionState>(
          builder: (context, state) {
            if (state is AdoptionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdoptionListLoaded) {
              if (state.requests.isEmpty) {
                return const Center(
                    child: Text('No tienes solicitudes pendientes.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final req = state.requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(req.petImage ?? '')),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Solicitud para ${req.petName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              _StatusChip(status: req.status),
                            ],
                          ),
                          const Divider(),
                          Text('De: ${req.adopterName ?? "Usuario"}'),
                          Text('Email: ${req.adopterEmail ?? "No disponible"}',
                              style: TextStyle(color: Colors.grey[600])),
                          if (req.message != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text('"${req.message}"',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (req.status == 'pending')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => context
                                      .read<AdoptionBloc>()
                                      .add(UpdateAdoptionStatus(
                                          req.id, 'rejected', shelterId)),
                                  child: const Text('Rechazar',
                                      style: TextStyle(color: Colors.red)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<AdoptionBloc>()
                                      .add(UpdateAdoptionStatus(
                                          req.id, 'approved', shelterId)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: const Text('Aprobar'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is AdoptionError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = Colors.green;
        label = 'Aprobada';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rechazada';
        break;
      default:
        color = Colors.orange;
        label = 'Pendiente';
    }
    return Chip(
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
