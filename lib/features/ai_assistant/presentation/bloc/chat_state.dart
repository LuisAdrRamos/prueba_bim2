import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  final List<MessageEntity> messages;
  const ChatState(this.messages);
  @override
  List<Object> get props => [messages];
}

class ChatInitial extends ChatState {
  const ChatInitial() : super(const []);
}

class ChatLoading extends ChatState {
  const ChatLoading(super.messages);
}

class ChatLoaded extends ChatState {
  const ChatLoaded(super.messages);
}

class ChatError extends ChatState {
  final String message;
  const ChatError(super.messages, this.message);
}
