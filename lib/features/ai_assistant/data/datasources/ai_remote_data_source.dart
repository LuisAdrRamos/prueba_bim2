import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/message_entity.dart';

abstract class AIRemoteDataSource {
  Future<String> sendMessage(String message, List<MessageEntity> history);
}

@LazySingleton(as: AIRemoteDataSource)
class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  final http.Client client;

  AIRemoteDataSourceImpl(this.client);

  @override
  Future<String> sendMessage(
      String currentMessage, List<MessageEntity> history) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final baseUrl = dotenv.env['GEMINI_BASE_URL'];

    if (apiKey == null || baseUrl == null) {
      throw Exception("Faltan configurar las variables en el .env");
    }

    final url = Uri.parse("$baseUrl?key=$apiKey");

    // --- AQUÍ ESTÁ EL TRUCO DEL EXPERTO VETERINARIO ---
    // Preparamos el historial para Gemini
    final contents = history.map((msg) {
      return {
        "role": msg.isUser ? "user" : "model",
        "parts": [
          {"text": msg.text}
        ],
      };
    }).toList();

    // Inyectamos el System Prompt como si fuera el primer mensaje del contexto (hack compatible con todas las versiones)
    if (history.isEmpty) {
      contents.insert(0, {
        "role": "user",
        "parts": [
          {
            "text":
                "Eres un asistente veterinario experto, amable y conciso. Responde dudas sobre mascotas."
          }
        ]
      });
      contents.insert(1, {
        "role": "model",
        "parts": [
          {
            "text":
                "Entendido. Soy un veterinario experto. ¿En qué puedo ayudarte con tu mascota hoy?"
          }
        ]
      });
    }

    // Añadimos el mensaje actual
    contents.add({
      "role": "user",
      "parts": [
        {"text": currentMessage}
      ],
    });

    final body = jsonEncode({
      "contents": contents,
      "generationConfig": {"temperature": 0.7, "maxOutputTokens": 4000},
    });

    try {
      final response = await client
          .post(url, headers: {'Content-Type': 'application/json; charset=utf-8'}, body: utf8.encode(body))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidate = data["candidates"]?[0];

        if (candidate != null && candidate["content"] != null) {
          final parts = candidate["content"]["parts"] as List;
          if (parts.isNotEmpty) {
            return parts[0]["text"] ?? "No pude generar una respuesta.";
          }
        }
        return "Sin respuesta de la IA.";
      } else {
        throw Exception("Error API: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }
}
