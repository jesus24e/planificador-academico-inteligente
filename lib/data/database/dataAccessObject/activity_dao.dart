import 'package:sqflite/sqflite.dart';
import 'package:planificador_academico_inteligente/data/database/database_helper.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

class ActivityDao {
  final _db = DatabaseHelper.instance;
  static const String _table = DatabaseHelper.tableActividades;

  Future<List<Activity>> getAll() async {
    final db = await _db.database;
    final response = await db.query(_table, orderBy: "fecha_limite ASC");
    return response.map((e) => _fromMap(e)).toList();
  }

  Future<Activity?> getById(int id) async {
    final db = await _db.database;
    final response = await db.query(
      _table,
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (response.isEmpty) return null;
    return _fromMap(response.first);
  }

  Future<List<Activity>> getBySubject(String subject) async {
    final db = await _db.database;
    final response = await db.query(
      _table,
      where: "materia = ?",
      whereArgs: [subject],
      orderBy: "fecha_limite ASC",
    );
    return response.map((e) => _fromMap(e)).toList();
  }

  Future<List<Activity>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _db.database;
    final response = await db.query(
      _table,
      where: "fecha_limite >= ? AND fecha_limite <= ?",
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: "fecha_limite ASC",
    );
    return response.map((e) => _fromMap(e)).toList();
  }

  Future<int> insert(Activity activity) async {
    final db = await _db.database;
    return await db.insert(_table, _toMap(activity));
  }

  Future<void> insertMany(List<Activity> activities) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final activity in activities) {
        batch.insert(_table, _toMap(activity));
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> update(Activity activity) async {
    final db = await _db.database;
    return await db.update(
      _table,
      _toMap(activity),
      where: "id = ?",
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await _db.database;
    return await db.delete(_table, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    final db = await _db.database;
    return await db.transaction<int>((txn) async {
      final deleted = await txn.delete(_table);
      await txn.delete('sqlite_sequence', where: "name = ?", whereArgs: [_table]);
      return deleted;
    });
  }

  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM $_table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<String>> getDistinctTipos() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT tipo FROM $_table ORDER BY tipo ASC',
    );
    return result.map((e) => e['tipo'] as String).toList();
  }

  Future<List<String>> getDistinctMaterias() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT materia FROM $_table ORDER BY materia ASC',
    );
    return result.map((e) => e['materia'] as String).toList();
  }

  Future<int> setCompletada(int id, bool completada) async {
    final db = await _db.database;
    return await db.update(
      _table,
      {'completada': completada ? 1 : 0},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Activity>> getEnPrioridad() async {
    final db = await _db.database;
    final response = await db.query(
      _table,
      where: "prioridad_estado = ?",
      whereArgs: [Activity.prioridadEnLista],
      orderBy: "fecha_limite ASC",
    );
    return response.map((e) => _fromMap(e)).toList();
  }

  Future<int> setPrioridadEstado(int id, int estado) async {
    final db = await _db.database;
    return await db.update(
      _table,
      {'prioridad_estado': estado},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(Activity activity) {
    final map = <String, dynamic>{
      'nombre': activity.nombre,
      'materia': activity.materia,
      'tipo': activity.tipo,
      'descripcion': activity.descripcion,
      'prioridad': activity.prioridad,
      'horas_dedicadas': activity.horasDedicadas,
      'fecha_limite': activity.fechaLimite.toIso8601String(),
      'completada': activity.completada ? 1 : 0,
      'prioridad_estado': activity.prioridadEstado,
    };
    if (activity.id != null) map['id'] = activity.id;
    return map;
  }

  Activity _fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      materia: map['materia'] as String,
      tipo: map['tipo'] as String,
      descripcion: (map['descripcion'] as String?) ?? '',
      prioridad: map['prioridad'] as String,
      horasDedicadas: (map['horas_dedicadas'] as int?) ?? 0,
      fechaLimite: DateTime.parse(map['fecha_limite'] as String),
      completada: ((map['completada'] as int?) ?? 0) == 1,
      prioridadEstado: (map['prioridad_estado'] as int?) ?? 0,
    );
  }
}
