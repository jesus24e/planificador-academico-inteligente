class Activity {
  static const int prioridadNinguno = 0;
  static const int prioridadEnLista = 1;
  static const int prioridadDescartada = 2;

  final int? id;
  final String nombre;
  final String materia;
  final String tipo;
  final String descripcion;
  final String prioridad;
  final int horasDedicadas;
  final DateTime fechaLimite;
  final bool completada;
  final int prioridadEstado;

  Activity({
    this.id,
    required this.nombre,
    required this.materia,
    required this.tipo,
    this.descripcion = "",
    required this.prioridad,
    this.horasDedicadas = 0,
    required this.fechaLimite,
    this.completada = false,
    this.prioridadEstado = prioridadNinguno,
  });

  bool get enPrioridad => prioridadEstado == prioridadEnLista;

  Activity copyWith({
    int? id,
    String? nombre,
    String? materia,
    String? tipo,
    String? descripcion,
    String? prioridad,
    int? horasDedicadas,
    DateTime? fechaLimite,
    bool? completada,
    int? prioridadEstado,
  }) {
    return Activity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      materia: materia ?? this.materia,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      horasDedicadas: horasDedicadas ?? this.horasDedicadas,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      completada: completada ?? this.completada,
      prioridadEstado: prioridadEstado ?? this.prioridadEstado,
    );
  }
}
