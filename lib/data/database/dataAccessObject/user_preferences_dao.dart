import 'package:sqflite/sqflite.dart';
import 'package:planificador_academico_inteligente/data/database/database_helper.dart';
import 'package:planificador_academico_inteligente/entities/user_preferences.dart';

class UserPreferencesDao {
  final _db = DatabaseHelper.instance;
  static const String _table = DatabaseHelper.tablePreferences;
  static const int _singletonId = 1;

  Future<UserPreferences> get() async {
    final db = await _db.database;
    final result = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [_singletonId],
      limit: 1,
    );
    if (result.isEmpty) return const UserPreferences();
    return _fromMap(result.first);
  }

  Future<void> save(UserPreferences prefs) async {
    final db = await _db.database;
    final map = _toMap(prefs)..['id'] = _singletonId;
    await db.insert(
      _table,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, dynamic> _toMap(UserPreferences p) {
    return {
      'horas_por_dia': p.horasPorDia,
      'dia_lunes': p.diaLunes ? 1 : 0,
      'dia_martes': p.diaMartes ? 1 : 0,
      'dia_miercoles': p.diaMiercoles ? 1 : 0,
      'dia_jueves': p.diaJueves ? 1 : 0,
      'dia_viernes': p.diaViernes ? 1 : 0,
      'dia_sabado': p.diaSabado ? 1 : 0,
      'dia_domingo': p.diaDomingo ? 1 : 0,
      'horario_preferente': p.horarioPreferente,
      'recordatorio_sesiones': p.recordatorioSesiones ? 1 : 0,
      'alertas_evaluaciones': p.alertasEvaluaciones ? 1 : 0,
      'riesgo_academico': p.riesgoAcademico ? 1 : 0,
      'hora_notificacion': p.horaNotificacion,
    };
  }

  UserPreferences _fromMap(Map<String, dynamic> m) {
    return UserPreferences(
      horasPorDia: (m['horas_por_dia'] as int?) ?? 3,
      diaLunes: ((m['dia_lunes'] as int?) ?? 1) == 1,
      diaMartes: ((m['dia_martes'] as int?) ?? 1) == 1,
      diaMiercoles: ((m['dia_miercoles'] as int?) ?? 0) == 1,
      diaJueves: ((m['dia_jueves'] as int?) ?? 1) == 1,
      diaViernes: ((m['dia_viernes'] as int?) ?? 0) == 1,
      diaSabado: ((m['dia_sabado'] as int?) ?? 0) == 1,
      diaDomingo: ((m['dia_domingo'] as int?) ?? 0) == 1,
      horarioPreferente: (m['horario_preferente'] as String?) ?? 'tarde',
      recordatorioSesiones:
          ((m['recordatorio_sesiones'] as int?) ?? 1) == 1,
      alertasEvaluaciones:
          ((m['alertas_evaluaciones'] as int?) ?? 1) == 1,
      riesgoAcademico: ((m['riesgo_academico'] as int?) ?? 0) == 1,
      horaNotificacion: (m['hora_notificacion'] as String?) ?? '08:00',
    );
  }
}
