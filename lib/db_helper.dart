import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cogela_suave.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            apodo TEXT,
            contrasena TEXT,
            email TEXT,
            nombre TEXT,
            apellido TEXT,
            fecha_nacimiento TEXT,
            carrera TEXT,
            descripcion_personal TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE eventos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            titulo TEXT,
            fecha TEXT,
            color INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE event_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER,
            user_id INTEGER,
            nombre TEXT,
            fecha TEXT,
            hora TEXT,
            descripcion TEXT,
            color INTEGER,
            tag TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE event_entries (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              event_id INTEGER,
              user_id INTEGER,
              nombre TEXT,
              fecha TEXT,
              hora TEXT,
              descripcion TEXT,
              color INTEGER
            )
          ''');
          oldVersion = 2;
        }
        if (oldVersion < 3) {
          // Add tag column to event_entries for categorization
          try {
            await db.execute('ALTER TABLE event_entries ADD COLUMN tag TEXT');
          } catch (e) {
            // If ALTER TABLE fails (older sqlite versions), ignore; table will have tag on fresh installs
          }
        }
      },
    );
  }

  // Insertar usuario
  static Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    final dbClient = await db;
    return await dbClient.insert('usuarios', usuario);
  }

  // Obtener todos los usuarios
  static Future<List<Map<String, dynamic>>> getUsuarios() async {
    final dbClient = await db;
    return await dbClient.query('usuarios');
  }

  // Obtener nombre para mostrar del usuario por id
  static Future<String?> getDisplayName(int userId) async {
    final dbClient = await db;
    final rows = await dbClient.query('usuarios', where: 'id = ?', whereArgs: [userId], limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
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

  // Obtener solo el apodo (nickname) del usuario
  static Future<String?> getApodo(int userId) async {
    final dbClient = await db;
    final rows = await dbClient.query('usuarios', where: 'id = ?', whereArgs: [userId], columns: ['apodo'], limit: 1);
    if (rows.isEmpty) return null;
    return (rows.first['apodo'] as String?)?.trim();
  }

  // Insertar evento
  static Future<int> insertEvento(Map<String, dynamic> evento) async {
    final dbClient = await db;
    return await dbClient.insert('eventos', evento);
  }

  // Insertar entrada de evento (actividad)
  static Future<int> insertEventEntry(Map<String, dynamic> entry) async {
    final dbClient = await db;
    try {
      final id = await dbClient.insert('event_entries', entry);
      // simple debug print
      // ignore: avoid_print
      print('Inserted event_entry id=$id entry=$entry');
      return id;
    } catch (e) {
      // ignore: avoid_print
      print('Error inserting event_entry: $e entry=$entry');
      rethrow;
    }
  }

  // Obtener entradas por usuario (historial)
  static Future<List<Map<String, dynamic>>> getEventEntries(int userId) async {
    final dbClient = await db;
    return await dbClient.query(
      'event_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'fecha DESC, hora DESC',
    );
  }

  // Obtener todas las tags usadas por un usuario
  static Future<List<String>> getTags(int userId) async {
    final dbClient = await db;
    final rows = await dbClient.rawQuery('SELECT DISTINCT tag FROM event_entries WHERE user_id = ? AND tag IS NOT NULL', [userId]);
    return rows.map((r) => r['tag'] as String).toList();
  }

  // Obtener entradas filtradas por tag
  static Future<List<Map<String, dynamic>>> getEventEntriesByTag(int userId, String tag) async {
    final dbClient = await db;
    return await dbClient.query(
      'event_entries',
      where: 'user_id = ? AND tag = ?',
      whereArgs: [userId, tag],
      orderBy: 'fecha DESC, hora DESC',
    );
  }

  // Obtener eventos por usuario
  static Future<List<Map<String, dynamic>>> getEventos(int userId) async {
    final dbClient = await db;
    return await dbClient.query('eventos', where: 'user_id = ?', whereArgs: [userId]);
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