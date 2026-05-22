import 'package:sqflite/sqflite.dart';
import 'package:planificador_academico_inteligente/data/database/database_helper.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';

class StudySessionDao {
  final _db = DatabaseHelper.instance;
  static const String _table = DatabaseHelper.tableSesiones;

  Future<List<StudySession>> getAll() async {
    final db = await _db.database;
    final r = await db.query(_table, orderBy: 'fecha ASC, hora_inicio ASC');
    return r.map(_fromMap).toList();
  }

  Future<List<StudySession>> getPendientes() async {
    final db = await _db.database;
    final r = await db.query(
      _table,
      where: 'completada = 0',
      orderBy: 'fecha ASC, hora_inicio ASC',
    );
    return r.map(_fromMap).toList();
  }

  Future<List<StudySession>> getByFecha(DateTime fecha) async {
    final db = await _db.database;
    final clave = _fechaKey(fecha);
    final r = await db.query(
      _table,
      where: 'fecha = ?',
      whereArgs: [clave],
      orderBy: 'hora_inicio ASC',
    );
    return r.map(_fromMap).toList();
  }

  Future<int> insert(StudySession s) async {
    final db = await _db.database;
    return await db.insert(_table, _toMap(s));
  }

  Future<void> insertMany(List<StudySession> sesiones) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final s in sesiones) {
        batch.insert(_table, _toMap(s));
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> update(StudySession s) async {
    final db = await _db.database;
    return await db.update(
      _table,
      _toMap(s),
      where: 'id = ?',
      whereArgs: [s.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await _db.database;
    return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePendientes() async {
    final db = await _db.database;
    return await db.delete(_table, where: 'completada = 0');
  }

  Future<int> deleteAll() async {
    final db = await _db.database;
    return await db.delete(_table);
  }

  Future<int> countPendientes() async {
    final db = await _db.database;
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM $_table WHERE completada = 0',
    );
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<int> setCompletada(int id, bool completada) async {
    final db = await _db.database;
    return await db.update(
      _table,
      {'completada': completada ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  String _fechaKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Map<String, dynamic> _toMap(StudySession s) {
    final m = <String, dynamic>{
      'actividad_id': s.actividadId,
      'fecha': _fechaKey(s.fecha),
      'hora_inicio': s.horaInicio,
      'hora_fin': s.horaFin,
      'completada': s.completada ? 1 : 0,
      'emergencia': s.emergencia ? 1 : 0,
    };
    if (s.id != null) m['id'] = s.id;
    return m;
  }

  StudySession _fromMap(Map<String, dynamic> m) {
    final fechaStr = m['fecha'] as String;
    final partes = fechaStr.split('-');
    final fecha = DateTime.utc(
      int.parse(partes[0]),
      int.parse(partes[1]),
      int.parse(partes[2]),
    );
    return StudySession(
      id: m['id'] as int?,
      actividadId: m['actividad_id'] as int,
      fecha: fecha,
      horaInicio: m['hora_inicio'] as String,
      horaFin: m['hora_fin'] as String,
      completada: ((m['completada'] as int?) ?? 0) == 1,
      emergencia: ((m['emergencia'] as int?) ?? 0) == 1,
    );
  }
}
