import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), "planificador.db");
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    db.execute('''
      CREATE TABLE actividades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        materia TEXT NOT NULL,
        tipo TEXT NOT NULL,
        descripcion TEXT DEFAULT '',
        prioridad TEXT NOT NULL,
        horas_dedicadas INTEGER DEFAULT 0,
        fecha_limite TEXT NOT NULL
      )
    ''');
  }
}
