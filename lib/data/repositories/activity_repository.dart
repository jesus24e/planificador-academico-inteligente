import 'package:planificador_academico_inteligente/data/database/dataAccessObject/activity_dao.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

class ActivityRepository {
  final _dao = ActivityDao();

  Future<List<Activity>> getAll() => _dao.getAll();
  Future<Activity?> getById(int id) => _dao.getById(id);
  Future<List<Activity>> getBySubject(String subject) => _dao.getBySubject(subject);
  Future<List<Activity>> getByDateRange(DateTime start, DateTime end) =>
      _dao.getByDateRange(start, end);
  Future<int> insert(Activity activity) => _dao.insert(activity);
  Future<void> insertMany(List<Activity> activities) => _dao.insertMany(activities);
  Future<int> update(Activity activity) => _dao.update(activity);
  Future<int> delete(int id) => _dao.deleteById(id);
  Future<int> deleteAll() => _dao.deleteAll();
  Future<int> count() => _dao.count();
  Future<List<String>> getDistinctTipos() => _dao.getDistinctTipos();
  Future<List<String>> getDistinctMaterias() => _dao.getDistinctMaterias();
  Future<int> setCompletada(int id, bool completada) =>
      _dao.setCompletada(id, completada);
  Future<List<Activity>> getEnPrioridad() => _dao.getEnPrioridad();
  Future<int> setPrioridadEstado(int id, int estado) =>
      _dao.setPrioridadEstado(id, estado);
}
