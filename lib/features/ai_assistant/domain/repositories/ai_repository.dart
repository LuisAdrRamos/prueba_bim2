import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';

abstract class AIRepository {
  Future<Either<Failure, String>> sendMessage(
      String message, List<MessageEntity> history);
}
