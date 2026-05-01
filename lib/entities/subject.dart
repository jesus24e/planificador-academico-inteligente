class Subject {
  final int? id;
  final String nombre;
  final String profesor;
  final String horario;
  final String color;

  Subject({
    this.id,
    required this.nombre,
    this.profesor = "",
    this.horario = "",
    this.color = "",
  });

  Subject copyWith({
    int? id,
    String? nombre,
    String? profesor,
    String? horario,
    String? color,
  }) {
    return Subject(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      profesor: profesor ?? this.profesor,
      horario: horario ?? this.horario,
      color: color ?? this.color,
    );
  }
}
