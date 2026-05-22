import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';
import 'package:planificador_academico_inteligente/entities/user_preferences.dart';

class PlanResult {
  final List<StudySession> sesiones;
  final List<String> advertencias;

  PlanResult(this.sesiones, this.advertencias);
}

class PlanEstudioGenerator {
  static const Map<int, String> _ordenPrioridad = {
    0: 'alta',
    1: 'media',
    2: 'baja',
  };

  PlanResult generar({
    required List<Activity> tareas,
    required UserPreferences prefs,
    required DateTime hoy,
  }) {
    final hoyUtc = DateTime.utc(hoy.year, hoy.month, hoy.day);

    final candidatas = tareas
        .where((a) =>
            a.id != null &&
            !a.completada &&
            a.horasDedicadas > 0 &&
            !DateTime.utc(
              a.fechaLimite.year,
              a.fechaLimite.month,
              a.fechaLimite.day,
            ).isBefore(hoyUtc))
        .toList();

    candidatas.sort((a, b) {
      final pa = _pesoPrioridad(a.prioridad);
      final pb = _pesoPrioridad(b.prioridad);
      if (pa != pb) return pa.compareTo(pb);
      final fa = a.fechaLimite;
      final fb = b.fechaLimite;
      final cmpFecha = fa.compareTo(fb);
      if (cmpFecha != 0) return cmpFecha;
      return b.horasDedicadas.compareTo(a.horasDedicadas);
    });

    final diasActivos = prefs.diasComoLista;
    final horasPorDia = prefs.horasPorDia;
    final (rangoInicio, _) = _rangoHorarioPreferente(prefs.horarioPreferente);

    final carga = <DateTime, int>{};
    final sesiones = <StudySession>[];
    final advertencias = <String>[];

    for (final tarea in candidatas) {
      final fechaLimiteUtc = DateTime.utc(
        tarea.fechaLimite.year,
        tarea.fechaLimite.month,
        tarea.fechaLimite.day,
      );

      final diasViablesAntes = <DateTime>[];
      var cursor = hoyUtc;
      while (cursor.isBefore(fechaLimiteUtc)) {
        if (_esDiaActivo(cursor, diasActivos)) {
          diasViablesAntes.add(cursor);
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      diasViablesAntes.sort((a, b) => b.compareTo(a));

      final horasNecesarias = tarea.horasDedicadas;
      var horasRestantes = horasNecesarias;
      final asignaciones = <DateTime, int>{};

      for (final dia in diasViablesAntes) {
        if (horasRestantes <= 0) break;
        final ocupado = carga[dia] ?? 0;
        final libre = horasPorDia - ocupado;
        if (libre <= 0) continue;
        final usar = horasRestantes < libre ? horasRestantes : libre;
        asignaciones[dia] = usar;
        horasRestantes -= usar;
      }

      if (horasRestantes > 0) {
        final diaEntregaActivo = _esDiaActivo(fechaLimiteUtc, diasActivos);
        final diaEntregaNoPasado = !fechaLimiteUtc.isBefore(hoyUtc);

        if (diaEntregaNoPasado) {
          if (diaEntregaActivo) {
            final ocupado = carga[fechaLimiteUtc] ?? 0;
            final libre = horasPorDia - ocupado;
            final usar = horasRestantes < libre ? horasRestantes : libre;
            if (usar > 0) {
              asignaciones[fechaLimiteUtc] =
                  (asignaciones[fechaLimiteUtc] ?? 0) + usar;
              horasRestantes -= usar;
            }
          }

          if (horasRestantes > 0) {
            asignaciones[fechaLimiteUtc] =
                (asignaciones[fechaLimiteUtc] ?? 0) + horasRestantes;
            advertencias.add(
              'La tarea "${tarea.nombre}" se agendó como sesión de emergencia '
              'el mismo día de entrega.',
            );
            horasRestantes = 0;
          }
        }
      }

      if (horasRestantes > 0) {
        advertencias.add(
          'No se pudo planificar "${tarea.nombre}" (${horasRestantes}h sin '
          'espacio disponible).',
        );
      }

      for (final entry in asignaciones.entries) {
        final dia = entry.key;
        final horas = entry.value;
        final ocupadoPrevio = carga[dia] ?? 0;
        final esEmergencia = dia.isAtSameMomentAs(fechaLimiteUtc);

        final inicioMin = esEmergencia
            ? (rangoInicio - 4 * 60).clamp(0, 23 * 60)
            : rangoInicio + ocupadoPrevio * 60;
        final finMin = inicioMin + horas * 60;

        sesiones.add(StudySession(
          actividadId: tarea.id!,
          fecha: dia,
          horaInicio: _formatHora(inicioMin),
          horaFin: _formatHora(finMin),
          emergencia: esEmergencia,
        ));

        carga[dia] = ocupadoPrevio + horas;
      }
    }

    return PlanResult(sesiones, advertencias);
  }

  int _pesoPrioridad(String prioridad) {
    final entrada = _ordenPrioridad.entries
        .firstWhere((e) => e.value == prioridad, orElse: () => const MapEntry(3, ''));
    return entrada.key;
  }

  bool _esDiaActivo(DateTime fecha, List<bool> diasActivos) {
    final idx = fecha.weekday - 1;
    if (idx < 0 || idx >= diasActivos.length) return false;
    return diasActivos[idx];
  }

  (int, int) _rangoHorarioPreferente(String preferencia) {
    switch (preferencia) {
      case UserPreferences.horarioManana:
        return (6 * 60, 12 * 60);
      case UserPreferences.horarioNoche:
        return (18 * 60, 24 * 60);
      case UserPreferences.horarioTarde:
      default:
        return (12 * 60, 18 * 60);
    }
  }

  String _formatHora(int minutosDelDia) {
    final m = minutosDelDia.clamp(0, 23 * 60 + 59);
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }
}
