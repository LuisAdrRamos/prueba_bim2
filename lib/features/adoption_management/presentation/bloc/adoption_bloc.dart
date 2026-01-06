import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
// import '../../domain/entities/adoption_request.dart';
import '../../domain/repositories/adoption_repository.dart';
import 'adoption_event.dart';
import 'adoption_state.dart';

@injectable
class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  final AdoptionRepository repository;

  AdoptionBloc(this.repository) : super(AdoptionInitial()) {
    on<SubmitAdoptionRequest>(_onSubmitRequest);
    on<LoadAdopterRequests>(_onLoadAdopterRequests);
    on<LoadShelterRequests>(_onLoadShelterRequests);
    on<UpdateAdoptionStatus>(_onUpdateStatus);
  }

  // 1. Enviar Solicitud
  Future<void> _onSubmitRequest(
    SubmitAdoptionRequest event,
    Emitter<AdoptionState> emit,
  ) async {
    emit(AdoptionLoading());

    final result = await repository.submitRequest(
      petId: event.petId,
      adopterId: event.adopterId,
      shelterId: event.shelterId,
      message: event.message,
      adopterName: event.adopterName,
      adopterEmail: event.adopterEmail,
    );

    result.fold(
      (failure) => emit(AdoptionError(failure.message)),
      (_) => emit(const AdoptionSuccess('¡Solicitud enviada con éxito!')),
    );
  }

  // 2. Cargar Solicitudes del Adoptante
  Future<void> _onLoadAdopterRequests(
      LoadAdopterRequests event, Emitter<AdoptionState> emit) async {
    emit(AdoptionLoading());
    final result = await repository.getAdopterRequests(event.userId);
    result.fold(
      (failure) => emit(AdoptionError(failure.message)),
      (requests) => emit(AdoptionListLoaded(requests)),
    );
  }

  // 3. Cargar Solicitudes del Refugio
  Future<void> _onLoadShelterRequests(
      LoadShelterRequests event, Emitter<AdoptionState> emit) async {
    emit(AdoptionLoading());
    final result = await repository.getShelterRequests(event.shelterId);
    result.fold(
      (failure) => emit(AdoptionError(failure.message)),
      (requests) => emit(AdoptionListLoaded(requests)),
    );
  }

  // 4. Actualizar Estado
  Future<void> _onUpdateStatus(
      UpdateAdoptionStatus event, Emitter<AdoptionState> emit) async {
    final result =
        await repository.updateRequestStatus(event.requestId, event.status);

    result.fold(
      (failure) => emit(AdoptionError(failure.message)),
      (_) {
        // Recargamos la lista para refrescar la UI
        add(LoadShelterRequests(event.shelterIdRef));
      },
    );
  }
}
