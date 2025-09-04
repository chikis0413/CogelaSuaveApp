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
      version: 1,
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

  // Insertar evento
  static Future<int> insertEvento(Map<String, dynamic> evento) async {
    final dbClient = await db;
    return await dbClient.insert('eventos', evento);
  }

  // Obtener eventos por usuario
  static Future<List<Map<String, dynamic>>> getEventos(int userId) async {
    final dbClient = await db;
    return await dbClient.query('eventos', where: 'user_id = ?', whereArgs: [userId]);
  }
}