import 'package:sqflite/sqflite.dart';
import 'package:planificador_academico_inteligente/data/database/database_helper.dart';
import 'package:planificador_academico_inteligente/entities/subject.dart';

class SubjectDao {
  final _db = DatabaseHelper.instance;
  static const String _table = DatabaseHelper.tableMaterias;

  Future<List<Subject>> getAll() async {
    final db = await _db.database;
    final response = await db.query(_table, orderBy: "nombre ASC");
    return response.map((e) => _fromMap(e)).toList();
  }

  Future<Subject?> getById(int id) async {
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

  Future<Subject?> getByName(String nombre) async {
    final db = await _db.database;
    final response = await db.query(
      _table,
      where: "nombre = ?",
      whereArgs: [nombre],
      limit: 1,
    );
    if (response.isEmpty) return null;
    return _fromMap(response.first);
  }

  Future<Subject?> findByNombreYProfesor(
    String nombre,
    String profesor, {
    int? excluirId,
  }) async {
    final db = await _db.database;
    final where = excluirId == null
        ? "nombre = ? COLLATE NOCASE AND profesor = ? COLLATE NOCASE"
        : "nombre = ? COLLATE NOCASE AND profesor = ? COLLATE NOCASE AND id != ?";
    final args = excluirId == null
        ? [nombre, profesor]
        : [nombre, profesor, excluirId];
    final response = await db.query(
      _table,
      where: where,
      whereArgs: args,
      limit: 1,
    );
    if (response.isEmpty) return null;
    return _fromMap(response.first);
  }

  Future<int> insert(Subject subject) async {
    final db = await _db.database;
    return await db.insert(_table, _toMap(subject));
  }

  Future<void> insertMany(List<Subject> subjects) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final s in subjects) {
        batch.insert(
          _table,
          _toMap(s),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> update(Subject subject) async {
    final db = await _db.database;
    return await db.update(
      _table,
      _toMap(subject),
      where: "id = ?",
      whereArgs: [subject.id],
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

  Future<int> countTareasAsociadas(String nombreMateria) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${DatabaseHelper.tableActividades} WHERE materia = ? COLLATE NOCASE',
      [nombreMateria],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Map<String, dynamic> _toMap(Subject subject) {
    final map = <String, dynamic>{
      'nombre': subject.nombre,
      'profesor': subject.profesor,
      'horario': subject.horario,
      'color': subject.color,
    };
    if (subject.id != null) map['id'] = subject.id;
    return map;
  }

  Subject _fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      profesor: (map['profesor'] as String?) ?? '',
      horario: (map['horario'] as String?) ?? '',
      color: (map['color'] as String?) ?? '',
    );
  }
}
