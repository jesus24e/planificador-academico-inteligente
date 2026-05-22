class StudySession {
  final int? id;
  final int actividadId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final bool completada;
  final bool emergencia;

  const StudySession({
    this.id,
    required this.actividadId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.completada = false,
    this.emergencia = false,
  });

  int get duracionHoras {
    final i = _toMin(horaInicio);
    final f = _toMin(horaFin);
    final diff = f - i;
    return diff <= 0 ? 0 : (diff / 60).round();
  }

  static int _toMin(String hhmm) {
    final p = hhmm.split(':');
    if (p.length != 2) return 0;
    final h = int.tryParse(p[0]) ?? 0;
    final m = int.tryParse(p[1]) ?? 0;
    return h * 60 + m;
  }

  StudySession copyWith({
    int? id,
    int? actividadId,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    bool? completada,
    bool? emergencia,
  }) {
    return StudySession(
      id: id ?? this.id,
      actividadId: actividadId ?? this.actividadId,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      completada: completada ?? this.completada,
      emergencia: emergencia ?? this.emergencia,
    );
  }
}
