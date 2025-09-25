import 'dart:convert';

import 'package:http/http.dart' as http;

import 'Config/api.dart';

class DBHelper {
  // Nota: Aunque el nombre del archivo y la clase siguen siendo `DBHelper`,
  // ahora funciona como cliente HTTP hacia el backend. Mantengo las mismas
  // firmas públicas mínimas para que el resto de la app cambie poco.

  // Insertar usuario -> POST /users (o endpoint apropiado)
  static Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users');
    final resp = await http
        .post(uri, headers: ApiConfig.defaultHeaders, body: jsonEncode(usuario))
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      // asumir que backend devuelve {"id": 123, ...}
      return body['id'] as int? ?? 0;
    }
    throw Exception('Failed to insert usuario: ${resp.statusCode} ${resp.body}');
  }

  // Obtener todos los usuarios -> GET /users
  static Future<List<Map<String, dynamic>>> getUsuarios() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users');
    final resp = await http
        .get(uri, headers: ApiConfig.defaultHeaders)
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as List<dynamic>;
      return body.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to get usuarios: ${resp.statusCode} ${resp.body}');
  }

  // Obtener nombre para mostrar del usuario por id -> GET /users/{id}
  static Future<String?> getDisplayName(int userId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/$userId');
    final resp = await http
        .get(uri, headers: ApiConfig.defaultHeaders)
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 200) {
      final row = jsonDecode(resp.body) as Map<String, dynamic>;
      final nombre = (row['nombre'] as String?)?.trim();
      final apellido = (row['apellido'] as String?)?.trim();
      final apodo = (row['apodo'] as String?)?.trim();
      final email = (row['email'] as String?)?.trim();
      if (nombre != null && nombre.isNotEmpty) {
        if (apellido != null && apellido.isNotEmpty) return '$nombre $apellido';
        return nombre;
      }
      if (apodo != null && apodo.isNotEmpty) return apodo;
      return email;
    }
    return null;
  }

  // Obtener solo el apodo (nickname) del usuario
  static Future<String?> getApodo(int userId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/$userId');
    final resp = await http
        .get(uri, headers: ApiConfig.defaultHeaders)
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 200) {
      final row = jsonDecode(resp.body) as Map<String, dynamic>;
      return (row['apodo'] as String?)?.trim();
    }
    return null;
  }

  // Insertar evento -> POST /events
  static Future<int> insertEvento(Map<String, dynamic> evento) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/events');
    final resp = await http
        .post(uri, headers: ApiConfig.defaultHeaders, body: jsonEncode(evento))
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      return body['id'] as int? ?? 0;
    }
    throw Exception('Failed to insert evento: ${resp.statusCode} ${resp.body}');
  }

  // Insertar entrada de evento (actividad) -> POST /event_entries
  static Future<int> insertEventEntry(Map<String, dynamic> entry) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/event_entries');
    final resp = await http
        .post(uri, headers: ApiConfig.defaultHeaders, body: jsonEncode(entry))
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      return body['id'] as int? ?? 0;
    }
    throw Exception('Failed to insert event_entry: ${resp.statusCode} ${resp.body}');
  }

  // Obtener entradas por usuario (historial) -> GET /event_entries?user_id={}
  static Future<List<Map<String, dynamic>>> getEventEntries(int userId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/event_entries?user_id=$userId');
    final resp = await http
        .get(uri, headers: ApiConfig.defaultHeaders)
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as List<dynamic>;
      return body.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to get event_entries: ${resp.statusCode} ${resp.body}');
  }

  // Obtener todas las tags usadas por un usuario
  static Future<List<String>> getTags(int userId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/event_entries/tags?user_id=$userId');
    final resp = await http
        .get(uri, headers: ApiConfig.defaultHeaders)
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as List<dynamic>;
      return body.cast<String>();
    }
    throw Exception('Failed to get tags: ${resp.statusCode} ${resp.body}');
  }

  // Obtener entradas filtradas por tag
  static Future<List<Map<String, dynamic>>> getEventEntriesByTag(int userId, String tag) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/event_entries?user_id=$userId&tag=${Uri.encodeQueryComponent(tag)}');
    final resp = await http
        .get(uri, headers: ApiConfig.defaultHeaders)
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as List<dynamic>;
      return body.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to get event_entries by tag: ${resp.statusCode} ${resp.body}');
  }

  // Obtener eventos por usuario
  static Future<List<Map<String, dynamic>>> getEventos(int userId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/events?user_id=$userId');
    final resp = await http
        .get(uri, headers: ApiConfig.defaultHeaders)
        .timeout(ApiConfig.requestTimeout);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as List<dynamic>;
      return body.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to get eventos: ${resp.statusCode} ${resp.body}');
  }

  // Convenience: insertar actividad (wrapper)
  static Future<int> insertActividad({required int userId, required String nombre, String? fecha, String? hora, String? descripcion, int? color, String? tag}) async {
    final entry = {
      'event_id': null,
      'user_id': userId,
      'nombre': nombre,
      'fecha': fecha ?? '',
      'hora': hora ?? '',
      'descripcion': descripcion ?? '',
      'color': color ?? 0xFF2196F3,
      'tag': tag,
    };
    return await insertEventEntry(entry);
  }

  // Convenience: insertar emocion
  static Future<int> insertEmocion({required int userId, required String emocion, required int intensidad, String? notas, int? color}) async {
    final now = DateTime.now();
    final hora = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final entry = {
      'event_id': null,
      'user_id': userId,
      'nombre': 'Emoción: $emocion',
      'fecha': now.toIso8601String().split('T').first,
      'hora': hora,
      'descripcion': 'Intensidad: $intensidad\nNotas: ${notas ?? ''}',
      'color': color ?? 0xFFE91E63,
      'tag': 'emocion',
    };
    return await insertEventEntry(entry);
  }
}