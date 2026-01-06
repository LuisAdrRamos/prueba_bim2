import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AIRepository repository;

  ChatBloc(this.repository) : super(const ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<ClearChat>((event, emit) => emit(const ChatInitial()));
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    final currentMessages = List<MessageEntity>.from(state.messages);

    // 1. Añadir mensaje del usuario inmediatamente
    currentMessages.add(MessageEntity(text: event.text, isUser: true));
    emit(ChatLoading(currentMessages));

    // 2. Llamar a la IA
    final result = await repository.sendMessage(event.text, state.messages);

    // 3. Manejar respuesta
    result.fold(
      (failure) => emit(ChatError(currentMessages, failure.message)),
      (response) {
        currentMessages.add(MessageEntity(text: response, isUser: false));
        emit(ChatLoaded(
            List.from(currentMessages))); // Nueva lista para forzar update
      },
    );
  }
}
