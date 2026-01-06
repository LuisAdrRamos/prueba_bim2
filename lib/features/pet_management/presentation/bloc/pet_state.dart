import 'package:equatable/equatable.dart';
import '../../domain/entities/pet_entity.dart';

abstract class PetState extends Equatable {
  const PetState();
  @override
  List<Object?> get props => [];
}

class PetInitial extends PetState {}

class PetLoading extends PetState {}

class PetLoaded extends PetState {
  final List<PetEntity> pets;
  const PetLoaded(this.pets);
  @override
  List<Object> get props => [pets];
}

class PetOperationSuccess extends PetState {
  final String message;
  const PetOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class PetError extends PetState {
  final String message;
  const PetError(this.message);
  @override
  List<Object> get props => [message];
}