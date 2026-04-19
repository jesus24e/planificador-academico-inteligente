class Activity {
  final int? id;
  final String nombre;
  final String materia;
  final String tipo;
  final String descripcion;
  final String prioridad;
  final int horasDedicadas;
  final DateTime fechaLimite;
  

  Activity({
    required this.id,
    required this.nombre,
    required this.materia,
    required this.tipo,
    this.descripcion = "",
    required this.prioridad,
    this.horasDedicadas = 0,
    required this.fechaLimite,
  });
}