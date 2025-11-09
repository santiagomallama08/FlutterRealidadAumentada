// lib/data/services/sqlite_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteService {
  static Database? _db;

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('local_ai_preview.db');
    return _db!;
  }

  /// Inicializa la base de datos y crea la tabla
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT,
            type TEXT,
            prompt TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  /// Inserta un registro en una tabla
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  /// Obtiene todos los registros de una tabla
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  /// Borra todos los registros (opcional)
  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }
}
