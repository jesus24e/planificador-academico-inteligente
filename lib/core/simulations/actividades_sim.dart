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
      materia: "Habilidades directivas",
      fechaLimite: DateTime.utc(2026, 4, 8),
      horasDedicadas: 1,
      prioridad: "media",
    ),
  ],
};

final List<Activity> activityList = [
  Activity(
    nombre: "examen de bases de datos 2",
    materia: "bases de datos 2",
    tipo: "examen",
    prioridad: "alta",
    fechaLimite: DateTime.utc(2026, 4, 17),
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
    tipo: "examen",
    nombre: "primer examen de bd2",
    materia: "bases de datos 2",
    fechaLimite: DateTime.utc(2026, 4, 14),
    horasDedicadas: 2,
    prioridad: "alta",
  ),
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
  Activity(
    tipo: "tarea",
    nombre: "ejemplo de factura cfdi",
    materia: "Habilidades directivas",
    fechaLimite: DateTime.utc(2026, 4, 8),
    horasDedicadas: 1,
    prioridad: "media",
  ),
];
