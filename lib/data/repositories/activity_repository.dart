import 'package:planificador_academico_inteligente/data/database/dataAccessObject/activity_dao.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

class ActivityRepository {
  final _dao = ActivityDao();

  Future<List<Activity>> getAll() => _dao.getAll();
  Future<Activity> getById(int id) => _dao.getById(id);
  Future<List<Activity>> getBySubject(String subject) => _dao.getBySubject(subject);
  Future<int> insert(Activity activity) => _dao.insert(activity);
  Future<int> update(Activity activity) => _dao.update(activity);
  Future<int> delete(int id) => _dao.deleteById(id);
  Future<int> deleteAll() => _dao.deleteAll(); 
}