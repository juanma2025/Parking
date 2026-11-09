import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/env_config.dart';
import 'pasto_landmarks_data.dart';

class AiChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  const AiChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}

class GeminiChatService {
  String? _conversationId;

  String _getInternalApiKey() {
    return EnvConfig.geminiApiKey.trim();
  }

  String _buildSystemPrompt() {
    final buffer = StringBuffer();
    buffer.writeln(
      'Eres "Parking Pasto AI", el asistente inteligente oficial de movilidad y parqueaderos en San Juan de Pasto, Nariño (Colombia).',
    );
    buffer.writeln(
      'Responde siempre en español de forma amable, concisa (máximo 3-4 líneas por respuesta) y útil.',
    );
    buffer.writeln(
      'Aquí tienes el catálogo actualizado en tiempo real de puntos clave y parqueaderos verificados en Pasto:',
    );

    for (final landmark in PastoDataService.getLandmarks()) {
      buffer.writeln(
        '- Zona: ${landmark.name} (${landmark.shortName}) en ${landmark.address} [Coords: ${landmark.latitude}, ${landmark.longitude}]:',
      );
      for (final lot in landmark.nearbyParkingLots) {
        buffer.writeln(
          '  * ${lot.name} (${lot.address}): Tarifa ${lot.formattedPrice}, ${lot.carSpaces} cupos auto, ${lot.motoSpaces} cupos moto, a ${lot.distanceMeters}m, horario ${lot.openingHours}.',
        );
      }
    }

    buffer.writeln(
      'Si el usuario pregunta por cómo reservar, indícale que puede tocar cualquier tarjeta de parqueadero, elegir su vehículo y horario, pagar por Nequi, transferencia o efectivo y recibir su código QR de ingreso sin filas.',
    );
    return buffer.toString();
  }

  Future<String> sendMessage({
    required String userMessage,
    required List<AiChatMessage> history,
  }) async {
    await _persistMessageToSupabase(sender: 'user', message: userMessage);

    final apiKey = _getInternalApiKey();
    String reply;

    if (apiKey.isEmpty || apiKey == 'your-gemini-api-key') {
      reply = _buildSmartLocalReply(userMessage);
    } else {
      try {
        reply = await _callGeminiRestApi(
          apiKey: apiKey,
          userMessage: userMessage,
          history: history,
        );
      } catch (_) {
        reply = _buildSmartLocalReply(userMessage);
      }
    }

    await _persistMessageToSupabase(sender: 'ai', message: reply);
    return reply;
  }

  Future<String> _callGeminiRestApi({
    required String apiKey,
    required String userMessage,
    required List<AiChatMessage> history,
  }) async {
    final models = ['gemini-2.5-flash', 'gemini-2.0-flash'];
    Object? lastError;

    for (final model in models) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final recentHistory = history.length > 8
            ? history.sublist(history.length - 8)
            : history;

        final contents = <Map<String, dynamic>>[
          for (final msg in recentHistory)
            {
              'role': msg.isUser ? 'user' : 'model',
              'parts': [
                {'text': msg.text}
              ],
            },
          {
            'role': 'user',
            'parts': [
              {'text': userMessage}
            ],
          },
        ];

        final payload = {
          'system_instruction': {
            'parts': [
              {'text': _buildSystemPrompt()}
            ],
          },
          'contents': contents,
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 320,
          },
        };

        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 12);
        final request = await client.postUrl(uri);
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          'application/json; charset=utf-8',
        );
        request.add(utf8.encode(jsonEncode(payload)));

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        client.close(force: false);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
          final candidates = decoded['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content =
                candidates.first['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = (parts.first['text'] as String?)?.trim();
              if (text != null && text.isNotEmpty) {
                return text;
              }
            }
          }
        }
        lastError = HttpException('Status ${response.statusCode}');
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? Exception('Error al conectar con Gemini API');
  }

  String _buildSmartLocalReply(String query) {
    final q = query.toLowerCase();
    final allLots = PastoDataService.getAllParkingLots();

    for (final landmark in PastoDataService.getLandmarks()) {
      if (q.contains(landmark.shortName.toLowerCase()) ||
          q.contains(landmark.id.toLowerCase()) ||
          q.contains(landmark.name.toLowerCase())) {
        final lots = landmark.nearbyParkingLots;
        final lotSummaries = lots
            .map((l) =>
                '• ${l.name} (${l.formattedPrice}, ${l.carSpaces} cupos auto / ${l.motoSpaces} moto, a ${l.distanceMeters}m)')
            .join('\n');
        return 'Cerca a ${landmark.name} tienes estas opciones disponibles ahora:\n$lotSummaries';
      }
    }

    if (q.contains('barato') ||
        q.contains('económico') ||
        q.contains('economico') ||
        q.contains('precio') ||
        q.contains('tarifa')) {
      final sorted = [...allLots]
        ..sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
      final top2 = sorted.take(2).toList();
      return 'Los parqueaderos más económicos en Pasto hoy son:\n'
          '• ${top2[0].name}: ${top2[0].formattedPrice} (${top2[0].totalSpaces} cupos libres)\n'
          '• ${top2[1].name}: ${top2[1].formattedPrice} (${top2[1].totalSpaces} cupos libres)';
    }

    if (q.contains('24 horas') || q.contains('noche') || q.contains('madrugada')) {
      final open24 = allLots
          .where((l) => l.openingHours.toLowerCase().contains('24'))
          .take(3)
          .map((l) => '• ${l.name} (${l.formattedPrice})')
          .join('\n');
      return 'Estos parqueaderos en Pasto prestan servicio las 24 Horas:\n$open24';
    }

    if (q.contains('reservar') || q.contains('pago') || q.contains('nequi') || q.contains('qr')) {
      return 'Para reservar, selecciona cualquier parqueadero en el mapa o en las tarjetas, elige tu vehículo y horario, y confirma con Nequi, transferencia o efectivo para generar tu código QR.';
    }

    if (q.contains('hospital') || q.contains('clínica') || q.contains('clinica')) {
      return 'Contamos con parqueaderos verificados junto a Hospital San Pedro, Hospital Infantil, Hospital Departamental (HUDN) y Clínica Pasto desde \$2.200 COP/h.';
    }

    return 'En San Juan de Pasto tenemos ${allLots.length} parqueaderos activos cerca a Unicentro, Único Outlet, Nova Centro, Belalcázar y hospitales con tarifas desde \$1.800 COP/h. ¿Qué zona buscas hoy?';
  }

  Future<void> _persistMessageToSupabase({
    required String sender,
    required String message,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      if (_conversationId == null) {
        final conv = await Supabase.instance.client
            .from('ai_conversations')
            .insert({
              'user_id': user.id,
              'title': 'Asistente Parking Pasto',
            })
            .select('id')
            .maybeSingle();
        _conversationId = conv?['id'] as String?;
      }

      if (_conversationId != null) {
        await Supabase.instance.client.from('ai_messages').insert({
          'conversation_id': _conversationId,
          'sender': sender,
          'message': message,
        });
      }
    } catch (_) {
      // Silencioso en caso de modo offline o entorno de test
    }
  }
}
