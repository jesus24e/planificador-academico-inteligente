import 'package:planificador_academico_inteligente/data/database/database_helper.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

class ActivityDao {
  final _db = DatabaseHelper.instance;

  Future<List<Activity>> getAll() async {
    final db = await _db.database;
    final response = await db.query("actividades");
    return response.map((e) => _fromMap(e)).toList();
  }

  Future<Activity> getById(int id) async {
    final db = await _db.database;
    final response = await db.query(
      "actividades",
      where: "id = ?",
      whereArgs: [id],
    );
    return _fromMap(response.first);
  }

  Future<List<Activity>> getBySubject(String subject) async {
    final db = await _db.database;
    final response = await db.query(
      "actividades",
      where: "materia = ?",
      whereArgs: [subject],
    );
    return response.map((e) => _fromMap(e)).toList();
  }

  Future<int> insert(Activity activity) async {
    final db = await _db.database;
    return await db.database.insert(
      "actividades",
      _toMap(activity),
    ); //retorna el id del registro insertado
  }

  Future<int> update(Activity activity) async {
    final db = await _db.database;
    return await db.update(
      "actividades",
      _toMap(activity),
      where: "id = ?",
      whereArgs: [activity.id],
    ); //retorna el id del registro actualizado
  }

  Future<int> deleteById(int id) async {
    final db = await _db.database;
    return await db.delete("actividades", where: "id = ?", whereArgs: [id]);
  } //retorna el id del registro eliminado

  Future<int> deleteAll() async {
    final db = await _db.database;
    return await db.delete("actividades");
  } //retorna el id del registro eliminado

  Map<String, dynamic> _toMap(Activity activity) {
    return {
      'nombre': activity.nombre,
      'materia': activity.materia,
      'tipo': activity.tipo,
      'descripcion': activity.descripcion,
      'prioridad': activity.prioridad,
      'horas_dedicadas': activity.horasDedicadas,
      'fecha_limite': activity.fechaLimite.toIso8601String(),
    };
  }

  Activity _fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      nombre: map['nombre'],
      materia: map['materia'],
      tipo: map['tipo'],
      descripcion: map['descripcion'] ?? '',
      prioridad: map['prioridad'],
      horasDedicadas: map['horas_dedicadas'] ?? 0,
      fechaLimite: DateTime.parse(map['fecha_limite']),
    );
  }
}
