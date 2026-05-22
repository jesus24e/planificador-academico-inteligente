class UserPreferences {
  static const String horarioManana = 'manana';
  static const String horarioTarde = 'tarde';
  static const String horarioNoche = 'noche';

  final int horasPorDia;
  final bool diaLunes;
  final bool diaMartes;
  final bool diaMiercoles;
  final bool diaJueves;
  final bool diaViernes;
  final bool diaSabado;
  final bool diaDomingo;
  final String horarioPreferente;
  final bool recordatorioSesiones;
  final bool alertasEvaluaciones;
  final bool riesgoAcademico;
  final String horaNotificacion;

  const UserPreferences({
    this.horasPorDia = 3,
    this.diaLunes = true,
    this.diaMartes = true,
    this.diaMiercoles = false,
    this.diaJueves = true,
    this.diaViernes = false,
    this.diaSabado = false,
    this.diaDomingo = false,
    this.horarioPreferente = horarioTarde,
    this.recordatorioSesiones = true,
    this.alertasEvaluaciones = true,
    this.riesgoAcademico = false,
    this.horaNotificacion = '08:00',
  });

  List<bool> get diasComoLista => [
        diaLunes,
        diaMartes,
        diaMiercoles,
        diaJueves,
        diaViernes,
        diaSabado,
        diaDomingo,
      ];

  UserPreferences copyWith({
    int? horasPorDia,
    bool? diaLunes,
    bool? diaMartes,
    bool? diaMiercoles,
    bool? diaJueves,
    bool? diaViernes,
    bool? diaSabado,
    bool? diaDomingo,
    String? horarioPreferente,
    bool? recordatorioSesiones,
    bool? alertasEvaluaciones,
    bool? riesgoAcademico,
    String? horaNotificacion,
  }) {
    return UserPreferences(
      horasPorDia: horasPorDia ?? this.horasPorDia,
      diaLunes: diaLunes ?? this.diaLunes,
      diaMartes: diaMartes ?? this.diaMartes,
      diaMiercoles: diaMiercoles ?? this.diaMiercoles,
      diaJueves: diaJueves ?? this.diaJueves,
      diaViernes: diaViernes ?? this.diaViernes,
      diaSabado: diaSabado ?? this.diaSabado,
      diaDomingo: diaDomingo ?? this.diaDomingo,
      horarioPreferente: horarioPreferente ?? this.horarioPreferente,
      recordatorioSesiones: recordatorioSesiones ?? this.recordatorioSesiones,
      alertasEvaluaciones: alertasEvaluaciones ?? this.alertasEvaluaciones,
      riesgoAcademico: riesgoAcademico ?? this.riesgoAcademico,
      horaNotificacion: horaNotificacion ?? this.horaNotificacion,
    );
  }
}
