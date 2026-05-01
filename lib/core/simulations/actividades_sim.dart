import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

final Map<DateTime, List<Activity>> mapDateActivity = {
  DateTime.utc(2026, 4, 17): [
    Activity(
      nombre: "examen de bases de datos 2",
      materia: "bases de datos 2",
      tipo: "examen",
      prioridad: "alta",
      fechaLimite: DateTime.utc(2026, 4, 17),
    ),
  ],
  DateTime.utc(2026, 5, 7): [
    Activity(
      tipo: "proyecto",
      nombre:
          "aplicacion de organizacion academica inteligente, proyecto final de la materia",
      materia: "programacion movil",
      fechaLimite: DateTime.utc(2026, 5, 7),
      horasDedicadas: 5,
      prioridad: "alta",
    ),
  ],
  DateTime.utc(2026, 4, 14): [
    Activity(
      tipo: "examen",
      nombre: "primer examen de bd2",
      materia: "bases de datos 2",
      fechaLimite: DateTime.utc(2026, 4, 14),
      horasDedicadas: 2,
      prioridad: "alta",
    ),
  ],
  DateTime.utc(2026, 5, 12): [
    Activity(
      tipo: "tarea",
      nombre: "comentario de articulo 10",
      materia: "redes de computadoras 2",
      fechaLimite: DateTime.utc(2026, 5, 12),
      horasDedicadas: 2,
      prioridad: "media",
    ),
    Activity(
      tipo: "tarea",
      nombre: "comentario de articulo 11",
      materia: "redes de computadoras 2",
      fechaLimite: DateTime.utc(2026, 5, 12),
      horasDedicadas: 2,
      prioridad: "media",
    ),
  ],
  DateTime.utc(2026, 4, 8): [
    Activity(
      tipo: "tarea",
      nombre: "ejemplo de factura cfdi",
      materia: "habilidades directivas",
      fechaLimite: DateTime.utc(2026, 4, 8),
      horasDedicadas: 1,
      prioridad: "media",
    ),
  ],
  DateTime.utc(2026, 4, 22): [
    Activity(
      tipo: "tarea",
      nombre: "practica de laboratorio 3",
      materia: "redes de computadoras 2",
      fechaLimite: DateTime.utc(2026, 4, 22),
      horasDedicadas: 3,
      prioridad: "baja",
    ),
  ],
  DateTime.utc(2026, 4, 28): [
    Activity(
      tipo: "examen",
      nombre: "examen parcial de redes",
      materia: "redes de computadoras 2",
      fechaLimite: DateTime.utc(2026, 4, 28),
      horasDedicadas: 4,
      prioridad: "alta",
    ),
    Activity(
      tipo: "tarea",
      nombre: "resumen capitulo 5 de sistemas operativos",
      materia: "sistemas operativos",
      fechaLimite: DateTime.utc(2026, 4, 28),
      horasDedicadas: 1,
      prioridad: "baja",
    ),
  ],
  DateTime.utc(2026, 5, 3): [
    Activity(
      tipo: "proyecto",
      nombre: "prototipo de interfaz para proyecto de movil",
      materia: "programacion movil",
      fechaLimite: DateTime.utc(2026, 5, 3),
      horasDedicadas: 6,
      prioridad: "alta",
    ),
  ],
  DateTime.utc(2026, 5, 19): [
    Activity(
      tipo: "tarea",
      nombre: "ejercicios de normalizacion",
      materia: "bases de datos 2",
      fechaLimite: DateTime.utc(2026, 5, 19),
      horasDedicadas: 2,
      prioridad: "media",
    ),
  ],
};

final List<Activity> activityList = [
  Activity(
    tipo: "tarea",
    nombre: "comentario de articulo 10",
    materia: "redes de computadoras 2",
    fechaLimite: DateTime.utc(2026, 5, 12),
    horasDedicadas: 2,
    prioridad: "media",
  ),
  Activity(
    tipo: "tarea",
    nombre: "resumen capitulo 5 de sistemas operativos",
    materia: "sistemas operativos",
    fechaLimite: DateTime.utc(2026, 4, 28),
    horasDedicadas: 1,
    prioridad: "baja",
  ),
  Activity(
    tipo: "examen",
    nombre: "examen parcial de redes",
    materia: "redes de computadoras 2",
    fechaLimite: DateTime.utc(2026, 4, 28),
    horasDedicadas: 4,
    prioridad: "alta",
  ),
  Activity(
    tipo: "tarea",
    nombre: "ejemplo de factura cfdi",
    materia: "habilidades directivas",
    fechaLimite: DateTime.utc(2026, 4, 8),
    horasDedicadas: 1,
    prioridad: "media",
  ),
  Activity(
    tipo: "proyecto",
    nombre:
        "aplicacion de organizacion academica inteligente, proyecto final de la materia",
    materia: "programacion movil",
    fechaLimite: DateTime.utc(2026, 5, 7),
    horasDedicadas: 5,
    prioridad: "alta",
  ),
  Activity(
    tipo: "tarea",
    nombre: "practica de laboratorio 3",
    materia: "redes de computadoras 2",
    fechaLimite: DateTime.utc(2026, 4, 22),
    horasDedicadas: 3,
    prioridad: "baja",
  ),
  Activity(
    nombre: "examen de bases de datos 2",
    materia: "bases de datos 2",
    tipo: "examen",
    prioridad: "alta",
    fechaLimite: DateTime.utc(2026, 4, 17),
  ),
  Activity(
    tipo: "tarea",
    nombre: "ejercicios de normalizacion",
    materia: "bases de datos 2",
    fechaLimite: DateTime.utc(2026, 5, 19),
    horasDedicadas: 2,
    prioridad: "media",
  ),
  Activity(
    tipo: "proyecto",
    nombre: "prototipo de interfaz para proyecto de movil",
    materia: "programacion movil",
    fechaLimite: DateTime.utc(2026, 5, 3),
    horasDedicadas: 6,
    prioridad: "alta",
  ),
  Activity(
    tipo: "examen",
    nombre: "primer examen de bd2",
    materia: "bases de datos 2",
    fechaLimite: DateTime.utc(2026, 4, 14),
    horasDedicadas: 2,
    prioridad: "alta",
  ),
  Activity(
    tipo: "tarea",
    nombre: "comentario de articulo 11",
    materia: "redes de computadoras 2",
    fechaLimite: DateTime.utc(2026, 5, 12),
    horasDedicadas: 2,
    prioridad: "media",
  ),
];

final ActivityRepository _activityRepository = ActivityRepository();

Future<void> insertActivities() async {
  try {
    await _activityRepository.insertMany(activityList);
  } catch (_) {}
}

Future<void> seedIfEmpty() async {
  try {
    final existing = await _activityRepository.count();
    if (existing == 0) {
      await _activityRepository.insertMany(activityList);
    }
  } catch (_) {}
}
Future<void> deleteAllActivities() async {
  try {
      await _activityRepository.deleteAll();
  } catch (_) {}
}


