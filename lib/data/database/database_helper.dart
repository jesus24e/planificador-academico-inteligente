import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String dbName = "planificador.db";
  static const int dbVersion = 4;

  static const String tableActividades = "actividades";
  static const String tableMaterias = "materias";

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onConfigure: _onConfigure,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableMaterias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE COLLATE NOCASE,
        profesor TEXT NOT NULL DEFAULT '',
        horario TEXT NOT NULL DEFAULT '',
        color TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableActividades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        materia TEXT NOT NULL COLLATE NOCASE,
        tipo TEXT NOT NULL,
        descripcion TEXT NOT NULL DEFAULT '',
        prioridad TEXT NOT NULL CHECK (prioridad IN ('alta','media','baja')),
        horas_dedicadas INTEGER NOT NULL DEFAULT 0 CHECK (horas_dedicadas >= 0),
        fecha_limite TEXT NOT NULL,
        completada INTEGER NOT NULL DEFAULT 0 CHECK (completada IN (0,1)),
        prioridad_estado INTEGER NOT NULL DEFAULT 0 CHECK (prioridad_estado IN (0,1,2)),
        FOREIGN KEY (materia) REFERENCES $tableMaterias(nombre)
          ON UPDATE CASCADE
          ON DELETE RESTRICT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_actividades_materia ON $tableActividades(materia)',
    );
    await db.execute(
      'CREATE INDEX idx_actividades_fecha_limite ON $tableActividades(fecha_limite)',
    );
    await db.execute(
      'CREATE INDEX idx_actividades_prioridad ON $tableActividades(prioridad)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
    if (oldVersion < 4) {
      await _migrateToV4(db);
    }
  }

  Future<void> _migrateToV2(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE $tableMaterias (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL UNIQUE COLLATE NOCASE,
          profesor TEXT NOT NULL DEFAULT '',
          horario TEXT NOT NULL DEFAULT '',
          color TEXT NOT NULL DEFAULT ''
        )
      ''');

      await txn.execute('''
        INSERT INTO $tableMaterias (nombre)
        SELECT DISTINCT materia FROM $tableActividades
      ''');

      await txn.execute('''
        CREATE TABLE actividades_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          materia TEXT NOT NULL COLLATE NOCASE,
          tipo TEXT NOT NULL,
          descripcion TEXT NOT NULL DEFAULT '',
          prioridad TEXT NOT NULL CHECK (prioridad IN ('alta','media','baja')),
          horas_dedicadas INTEGER NOT NULL DEFAULT 0 CHECK (horas_dedicadas >= 0),
          fecha_limite TEXT NOT NULL,
          FOREIGN KEY (materia) REFERENCES $tableMaterias(nombre)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
        )
      ''');

      await txn.execute('''
        INSERT INTO actividades_new
          (id, nombre, materia, tipo, descripcion, prioridad, horas_dedicadas, fecha_limite)
        SELECT id, nombre, materia, tipo, descripcion, prioridad, horas_dedicadas, fecha_limite
        FROM $tableActividades
      ''');

      await txn.execute('DROP TABLE $tableActividades');
      await txn.execute('ALTER TABLE actividades_new RENAME TO $tableActividades');

      await txn.execute(
        'CREATE INDEX idx_actividades_materia ON $tableActividades(materia)',
      );
      await txn.execute(
        'CREATE INDEX idx_actividades_fecha_limite ON $tableActividades(fecha_limite)',
      );
      await txn.execute(
        'CREATE INDEX idx_actividades_prioridad ON $tableActividades(prioridad)',
      );
    });
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV3(Database db) async {
    await db.execute(
      'ALTER TABLE $tableActividades ADD COLUMN completada INTEGER NOT NULL DEFAULT 0 CHECK (completada IN (0,1))',
    );
  }

  Future<void> _migrateToV4(Database db) async {
    await db.execute(
      'ALTER TABLE $tableActividades ADD COLUMN prioridad_estado INTEGER NOT NULL DEFAULT 0 CHECK (prioridad_estado IN (0,1,2))',
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
