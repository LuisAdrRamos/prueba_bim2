import 'package:equatable/equatable.dart';
import '../../domain/entities/adoption_request.dart';

abstract class AdoptionState extends Equatable {
  const AdoptionState();
  @override
  List<Object?> get props => [];
}

class AdoptionInitial extends AdoptionState {}

class AdoptionLoading extends AdoptionState {}

class AdoptionSuccess extends AdoptionState {
  final String message;
  const AdoptionSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class AdoptionError extends AdoptionState {
  final String message;
  const AdoptionError(this.message);
  @override
  List<Object> get props => [message];
}

// --- NUEVO ESTADO PARA LISTAS ---
class AdoptionListLoaded extends AdoptionState {
  final List<AdoptionRequest> requests;
  const AdoptionListLoaded(this.requests);
  @override
  List<Object> get props => [requests];
}
