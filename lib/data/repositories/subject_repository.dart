import 'package:planificador_academico_inteligente/data/database/dataAccessObject/subject_dao.dart';
import 'package:planificador_academico_inteligente/entities/subject.dart';

class SubjectRepository {
  final _dao = SubjectDao();

  Future<List<Subject>> getAll() => _dao.getAll();
  Future<Subject?> getById(int id) => _dao.getById(id);
  Future<Subject?> getByName(String nombre) => _dao.getByName(nombre);
  Future<int> insert(Subject subject) => _dao.insert(subject);
  Future<void> insertMany(List<Subject> subjects) => _dao.insertMany(subjects);
  Future<int> update(Subject subject) => _dao.update(subject);
  Future<int> delete(int id) => _dao.deleteById(id);
  Future<int> deleteAll() => _dao.deleteAll();
  Future<int> count() => _dao.count();
}
