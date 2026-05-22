import 'package:planificador_academico_inteligente/core/services/plan_estudio_generator.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/study_session_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/user_preferences_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';

class PlanEstudioService {
  final _activityRepo = ActivityRepository();
  final _sessionRepo = StudySessionRepository();
  final _prefsRepo = UserPreferencesRepository();
  final _generator = PlanEstudioGenerator();

  Future<bool> existePlanActivo() async {
    final count = await _sessionRepo.countPendientes();
    return count > 0;
  }

  Future<List<StudySession>> getPlanActivo() => _sessionRepo.getPendientes();

  Future<Map<int, Activity>> getActividadesPorId() async {
    final all = await _activityRepo.getAll();
    return {for (final a in all) if (a.id != null) a.id!: a};
  }

  Future<List<String>> generarPlan({List<int>? tareasIncluidasIds}) async {
    final prefs = await _prefsRepo.get();
    final todas = await _activityRepo.getAll();

    final candidatas = tareasIncluidasIds == null
        ? todas
        : todas.where((a) => a.id != null && tareasIncluidasIds.contains(a.id!)).toList();

    final result = _generator.generar(
      tareas: candidatas,
      prefs: prefs,
      hoy: DateTime.now(),
    );

    await _sessionRepo.deletePendientes();
    if (result.sesiones.isNotEmpty) {
      await _sessionRepo.insertMany(result.sesiones);
    }

    return result.advertencias;
  }

  Future<List<String>> agregarTareasAlPlan(List<int> tareasIds) async {
    final actuales = await _sessionRepo.getPendientes();
    final idsActuales = actuales.map((s) => s.actividadId).toSet();
    final combinado = {...idsActuales, ...tareasIds}.toList();
    return generarPlan(tareasIncluidasIds: combinado);
  }

  Future<void> guardarCambiosSesiones(List<StudySession> sesiones) async {
    for (final s in sesiones) {
      if (s.id != null) {
        await _sessionRepo.update(s);
      }
    }
  }

  Future<void> quitarTareaDelPlan(int actividadId) async {
    final sesiones = await _sessionRepo.getPendientes();
    for (final s in sesiones) {
      if (s.actividadId == actividadId && s.id != null) {
        await _sessionRepo.delete(s.id!);
      }
    }
  }
}
