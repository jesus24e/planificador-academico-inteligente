import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/study_session_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/contador_sesion_dialog.dart';

class SesionDelDiaDialog extends StatefulWidget {
  final VoidCallback onChanged;

  const SesionDelDiaDialog({super.key, required this.onChanged});

  @override
  State<SesionDelDiaDialog> createState() => _SesionDelDiaDialogState();
}

class _SesionDelDiaDialogState extends State<SesionDelDiaDialog> {
  final StudySessionRepository _sessionRepo = StudySessionRepository();
  final ActivityRepository _activityRepo = ActivityRepository();

  List<StudySession> _sesiones = [];
  Map<int, Activity> _actividadesPorId = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final hoy = DateTime.now();
      final hoyUtc = DateTime.utc(hoy.year, hoy.month, hoy.day);
      final sesiones = await _sessionRepo.getByFecha(hoyUtc);
      final pendientesHoy = sesiones.where((s) => !s.completada).toList();
      final actividades = await _activityRepo.getAll();
      if (!mounted) return;
      setState(() {
        _sesiones = pendientesHoy;
        _actividadesPorId = {
          for (final a in actividades)
            if (a.id != null) a.id!: a,
        };
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sesiones = [];
        _cargando = false;
      });
    }
  }

  Future<void> _iniciarSesion(StudySession s, {int? index}) async {
    final indiceActual = index != null ? index + 1 : null;
    final total = index != null ? _sesiones.length : null;

    final completada = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ContadorSesionDialog(
        session: s,
        actividad: _actividadesPorId[s.actividadId],
        indiceActual: indiceActual,
        totalSesiones: total,
        onSesionCompletada: widget.onChanged,
      ),
    );

    if (!mounted) return;

    if (completada == true) {
      await _ofrecerSiguiente();
    } else {
      await _cargar();
    }
  }

  Future<void> _ofrecerSiguiente() async {
    if (!mounted) return;
    final hoy = DateTime.now();
    final hoyUtc = DateTime.utc(hoy.year, hoy.month, hoy.day);
    final sesionesActualizadas = await _sessionRepo.getByFecha(hoyUtc);
    final pendientes =
        sesionesActualizadas.where((s) => !s.completada).toList();

    if (!mounted) return;

    if (pendientes.isEmpty) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("¡Día completado!"),
          content: const Text(
            "Terminaste todas tus sesiones de estudio de hoy.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Excelente"),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
      return;
    }

    if (!mounted) return;
    final iniciar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sesión completada"),
        content: Text(
          'Te quedan ${pendientes.length} sesión(es) pendientes hoy. '
          '¿Comenzamos la siguiente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Más tarde"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Iniciar siguiente"),
          ),
        ],
      ),
    );

    if (!mounted) return;
    await _cargar();
    if (iniciar == true && _sesiones.isNotEmpty) {
      await _iniciarSesion(_sesiones.first, index: 0);
    }
  }

  String _tituloSesion(StudySession s) {
    final a = _actividadesPorId[s.actividadId];
    if (a == null) return 'Sesión de estudio';
    if (a.tipo.toLowerCase() == 'examen') {
      return 'Estudio para examen ${a.nombre}';
    }
    return a.nombre;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Estas son tus actividades de la sesión de hoy"),
      content: SizedBox(
        width: double.maxFinite,
        child: _cargando
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : _sesiones.isEmpty
                ? const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        "No hay sesiones pendientes para hoy.",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _sesiones.length,
                    itemBuilder: (_, i) {
                      final s = _sesiones[i];
                      final actividad = _actividadesPorId[s.actividadId];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: s.emergencia
                                  ? const Color(0xFFB91C1C)
                                  : Colors.amber,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tituloSesion(s),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${s.horaInicio} – ${s.horaFin} '
                                    '(${s.duracionHoras}h)'
                                    '${actividad != null ? "  ·  ${actividad.materia}" : ""}'
                                    '${s.emergencia ? "  ·  emergencia" : ""}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: s.emergencia
                                          ? const Color(0xFFB91C1C)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () => _iniciarSesion(s, index: i),
                              icon: const Icon(Icons.play_arrow, size: 16),
                              label: const Text("Iniciar"),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A5F),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
