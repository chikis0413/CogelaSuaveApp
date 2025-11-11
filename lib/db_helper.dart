import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cogela_suave.db');
    return await openDatabase(
      path,
      version: 3, // Cambiado de 2 a 3 para forzar recreación
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        apodo TEXT NOT NULL,
        email TEXT NOT NULL,
        contrasena TEXT NOT NULL,
        nombre TEXT,
        apellido TEXT,
        fecha_nacimiento TEXT,
        carrera TEXT,
        descripcion_personal TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE actividades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT,
        descripcion TEXT,
        color INTEGER,
        tag TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE emotion_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        emotion TEXT NOT NULL,
        intensity INTEGER NOT NULL,
        notes TEXT,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS emotion_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          emotion TEXT NOT NULL,
          intensity INTEGER NOT NULL,
          notes TEXT,
          timestamp TEXT NOT NULL
        )
      ''');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS actividades (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          nombre TEXT NOT NULL,
          fecha TEXT NOT NULL,
          hora TEXT,
          descripcion TEXT,
          color INTEGER,
          tag TEXT,
          created_at TEXT
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Recrear tabla actividades si existe
      await db.execute('DROP TABLE IF EXISTS actividades');
      await db.execute('''
        CREATE TABLE actividades (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          nombre TEXT NOT NULL,
          fecha TEXT NOT NULL,
          hora TEXT,
          descripcion TEXT,
          color INTEGER,
          tag TEXT,
          created_at TEXT
        )
      ''');
    }
  }

  static Future<int> insertActividad({
    required int userId,
    required String nombre,
    required String fecha,
    required String hora,
    required String descripcion,
    required int color,
    String? tag,
  }) async {
    final database = await db;
    
    final Map<String, dynamic> data = {
      'user_id': userId,
      'nombre': nombre,
      'fecha': fecha,
      'hora': hora,
      'descripcion': descripcion,
      'color': color,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    // Solo agregar tag si no es null
    if (tag != null) {
      data['tag'] = tag;
    }
    
    return await database.insert(
      'actividades',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getEventEntries(int userId) async {
    final database = await db;
    return await database.query(
      'actividades',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'fecha DESC, hora DESC',
    );
  }

  static Future<int> insertEmotionEntry({
    required int userId,
    required String emotion,
    required int intensity,
    required String notes,
    required String timestamp,
  }) async {
    final database = await db;
    return await database.insert(
      'emotion_entries',
      {
        'user_id': userId,
        'emotion': emotion,
        'intensity': intensity,
        'notes': notes,
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getEmotionEntries(int userId) async {
    final database = await db;
    return await database.query(
      'emotion_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
  }
}