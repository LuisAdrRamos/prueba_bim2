import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/pet_repository.dart';
import 'pet_event.dart';
import 'pet_state.dart';

@injectable
class PetBloc extends Bloc<PetEvent, PetState> {
  final PetRepository repository;

  PetBloc(this.repository) : super(PetInitial()) {
    on<LoadPets>(_onLoadPets);
    on<LoadMyPets>(_onLoadMyPets);
    on<CreatePet>(_onCreatePet);
    on<UpdatePet>(_onUpdatePet);
    on<DeletePet>(_onDeletePet);
  }

  Future<void> _onLoadPets(LoadPets event, Emitter<PetState> emit) async {
    emit(PetLoading());
    final result = await repository.getPets();
    result.fold(
      (failure) => emit(PetError(failure.message)),
      (allPets) {
        // 1. Filtrar por Especie
        var filteredPets = event.filter == 'Todos'
            ? allPets
            : allPets.where((pet) => pet.species == event.filter).toList();

        // 2. Filtrar por Buscador (NUEVO)
        if (event.searchQuery.isNotEmpty) {
          final query = event.searchQuery.toLowerCase();
          filteredPets = filteredPets.where((pet) {
            return pet.name.toLowerCase().contains(query);
          }).toList();
        }

        emit(PetLoaded(filteredPets));
      },
    );
  }

  Future<void> _onLoadMyPets(LoadMyPets event, Emitter<PetState> emit) async {
    emit(PetLoading());
    final result = await repository.getMyPets(event.shelterId);

    result.fold(
      (failure) => emit(PetError(failure.message)),
      (allPets) {
        // 1. Filtrar por Especie
        var filteredPets = event.filter == 'Todos'
            ? allPets
            : allPets.where((pet) => pet.species == event.filter).toList();

        // 2. Filtrar por Buscador (Nombre)
        if (event.searchQuery.isNotEmpty) {
          final query = event.searchQuery.toLowerCase();
          filteredPets = filteredPets.where((pet) {
            return pet.name.toLowerCase().contains(query);
          }).toList();
        }

        emit(PetLoaded(filteredPets));
      },
    );
  }

  Future<void> _onCreatePet(CreatePet event, Emitter<PetState> emit) async {
    emit(PetLoading());
    final result =
        await repository.createPet(pet: event.pet, imageFile: event.imageFile);
    result.fold(
      (failure) => emit(PetError(failure.message)),
      (_) => emit(const PetOperationSuccess('Mascota publicada exitosamente')),
    );
  }

  Future<void> _onUpdatePet(UpdatePet event, Emitter<PetState> emit) async {
    emit(PetLoading());
    final result =
        await repository.updatePet(pet: event.pet, newImage: event.newImage);
    result.fold(
      (failure) => emit(PetError(failure.message)),
      (_) =>
          emit(const PetOperationSuccess('Mascota actualizada correctamente')),
    );
  }

  Future<void> _onDeletePet(DeletePet event, Emitter<PetState> emit) async {
    emit(PetLoading());
    final result = await repository.deletePet(event.petId, event.imageUrl);
    result.fold(
      (failure) => emit(PetError(failure.message)),
      (_) {
        // Después de borrar, recargamos la lista automáticamente
        add(LoadMyPets(event.shelterId));
      },
    );
  }
}
