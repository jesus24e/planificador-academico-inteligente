import 'package:planificador_academico_inteligente/data/database/dataAccessObject/study_session_dao.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';

class StudySessionRepository {
  final _dao = StudySessionDao();

  Future<List<StudySession>> getAll() => _dao.getAll();
  Future<List<StudySession>> getPendientes() => _dao.getPendientes();
  Future<List<StudySession>> getByFecha(DateTime fecha) =>
      _dao.getByFecha(fecha);
  Future<int> insert(StudySession s) => _dao.insert(s);
  Future<void> insertMany(List<StudySession> sesiones) =>
      _dao.insertMany(sesiones);
  Future<int> update(StudySession s) => _dao.update(s);
  Future<int> delete(int id) => _dao.deleteById(id);
  Future<int> deletePendientes() => _dao.deletePendientes();
  Future<int> deleteAll() => _dao.deleteAll();
  Future<int> countPendientes() => _dao.countPendientes();
  Future<int> setCompletada(int id, bool completada) =>
      _dao.setCompletada(id, completada);
}
