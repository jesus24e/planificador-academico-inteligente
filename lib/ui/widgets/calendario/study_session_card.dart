import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';

class StudySessionCard extends StatelessWidget {
  final StudySession session;
  final Activity? actividad;

  const StudySessionCard({
    super.key,
    required this.session,
    required this.actividad,
  });

  String get _titulo {
    final a = actividad;
    if (a == null) return 'Sesión de estudio';
    if (a.tipo.toLowerCase() == 'examen') {
      return 'Estudio para examen ${a.nombre}';
    }
    return a.nombre;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: session.emergencia ? const Color(0xFFB91C1C) : Colors.amber,
            width: 4,
          ),
        ),
        boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, size: 16, color: Color(0xFF92400E)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (session.emergencia)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'emergencia',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 13, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                '${session.horaInicio} – ${session.horaFin} '
                '(${session.duracionHoras}h)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              if (actividad != null) ...[
                const Text('  ·  ', style: TextStyle(color: Color(0xFF6B7280))),
                Flexible(
                  child: Text(
                    actividad!.materia,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
