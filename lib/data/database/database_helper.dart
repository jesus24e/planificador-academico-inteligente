import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String dbName = "planificador.db";
  static const int dbVersion = 7;

  static const String tableActividades = "actividades";
  static const String tableMaterias = "materias";
  static const String tablePreferences = "user_preferences";
  static const String tableSesiones = "sesiones_estudio";

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

    await db.execute(_sqlCreatePreferences());
    await db.execute(_sqlSeedPreferences());
    await db.execute(_sqlCreateSesiones());
    await db.execute(
      'CREATE INDEX idx_sesiones_actividad ON $tableSesiones(actividad_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sesiones_fecha ON $tableSesiones(fecha)',
    );
  }

  static String _sqlCreateSesiones() => '''
    CREATE TABLE $tableSesiones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      actividad_id INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      hora_inicio TEXT NOT NULL,
      hora_fin TEXT NOT NULL,
      completada INTEGER NOT NULL DEFAULT 0 CHECK (completada IN (0,1)),
      emergencia INTEGER NOT NULL DEFAULT 0 CHECK (emergencia IN (0,1)),
      FOREIGN KEY (actividad_id) REFERENCES $tableActividades(id)
        ON DELETE CASCADE
    )
  ''';

  static String _sqlCreatePreferences() => '''
    CREATE TABLE $tablePreferences (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      horas_por_dia INTEGER NOT NULL DEFAULT 3 CHECK (horas_por_dia BETWEEN 1 AND 12),
      dia_lunes INTEGER NOT NULL DEFAULT 1 CHECK (dia_lunes IN (0,1)),
      dia_martes INTEGER NOT NULL DEFAULT 1 CHECK (dia_martes IN (0,1)),
      dia_miercoles INTEGER NOT NULL DEFAULT 0 CHECK (dia_miercoles IN (0,1)),
      dia_jueves INTEGER NOT NULL DEFAULT 1 CHECK (dia_jueves IN (0,1)),
      dia_viernes INTEGER NOT NULL DEFAULT 0 CHECK (dia_viernes IN (0,1)),
      dia_sabado INTEGER NOT NULL DEFAULT 0 CHECK (dia_sabado IN (0,1)),
      dia_domingo INTEGER NOT NULL DEFAULT 0 CHECK (dia_domingo IN (0,1)),
      horario_preferente TEXT NOT NULL DEFAULT 'tarde' CHECK (horario_preferente IN ('manana','tarde','noche')),
      recordatorio_sesiones INTEGER NOT NULL DEFAULT 1 CHECK (recordatorio_sesiones IN (0,1)),
      alertas_evaluaciones INTEGER NOT NULL DEFAULT 1 CHECK (alertas_evaluaciones IN (0,1)),
      riesgo_academico INTEGER NOT NULL DEFAULT 0 CHECK (riesgo_academico IN (0,1)),
      hora_notificacion TEXT NOT NULL DEFAULT '08:00'
    )
  ''';

  static String _sqlSeedPreferences() =>
      'INSERT OR IGNORE INTO $tablePreferences (id) VALUES (1)';

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
    if (oldVersion < 5) {
      await _migrateToV5(db);
    }
    if (oldVersion < 6) {
      await _migrateToV6(db);
    }
    if (oldVersion < 7) {
      await _migrateToV7(db);
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

  Future<void> _migrateToV5(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');
    await db.transaction((txn) async {
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
          completada INTEGER NOT NULL DEFAULT 0 CHECK (completada IN (0,1)),
          prioridad_estado INTEGER NOT NULL DEFAULT 0 CHECK (prioridad_estado IN (0,1,2)),
          FOREIGN KEY (materia) REFERENCES $tableMaterias(nombre)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
        )
      ''');

      await txn.execute('''
        INSERT INTO actividades_new
          (id, nombre, materia, tipo, descripcion, prioridad, horas_dedicadas,
           fecha_limite, completada, prioridad_estado)
        SELECT id, nombre, materia, tipo, descripcion, prioridad, horas_dedicadas,
               fecha_limite, completada, prioridad_estado
        FROM $tableActividades
      ''');

      await txn.execute('DROP TABLE $tableActividades');
      await txn.execute(
        'ALTER TABLE actividades_new RENAME TO $tableActividades',
      );

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

  Future<void> _migrateToV6(Database db) async {
    await db.execute(_sqlCreatePreferences());
    await db.execute(_sqlSeedPreferences());
  }

  Future<void> _migrateToV7(Database db) async {
    await db.execute(_sqlCreateSesiones());
    await db.execute(
      'CREATE INDEX idx_sesiones_actividad ON $tableSesiones(actividad_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sesiones_fecha ON $tableSesiones(fecha)',
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
