import 'package:planificador_academico_inteligente/data/repositories/subject_repository.dart';
import 'package:planificador_academico_inteligente/entities/subject.dart';

final List<Subject> subjectList = [
  Subject(
    nombre: "bases de datos 2",
    profesor: "Gallo",
    horario: "Lun/Mié 10:00am",
  ),
  Subject(
    nombre: "programacion movil",
    profesor: "Reyes",
    horario: "Mar/Jue 12:00pm",
  ),
  Subject(
    nombre: "redes de computadoras 2",
    profesor: "Lopez",
    horario: "Lun/Mié 8:00am",
  ),
  Subject(
    nombre: "sistemas operativos",
    profesor: "Ramirez",
    horario: "Mar/Jue 10:00am",
  ),
  Subject(
    nombre: "habilidades directivas",
    profesor: "Mendoza",
    horario: "Vie 9:00am",
  ),
];

final SubjectRepository _subjectRepository = SubjectRepository();

Future<void> insertSubjects() async {
  try {
    await _subjectRepository.insertMany(subjectList);
  } catch (_) {}
}

Future<void> seedSubjectsIfEmpty() async {
  try {
    final existing = await _subjectRepository.count();
    if (existing == 0) {
      await _subjectRepository.insertMany(subjectList);
    }
  } catch (_) {}
}

Future<void> deleteAllSubjects() async {
  try {
    await _subjectRepository.deleteAll();
  } catch (_) {}
}
