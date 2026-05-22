import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/services/plan_estudio_service.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/study_session_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';

class EditarPlanDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const EditarPlanDialog({super.key, required this.onSaved});

  @override
  State<EditarPlanDialog> createState() => _EditarPlanDialogState();
}

class _EditarPlanDialogState extends State<EditarPlanDialog> {
  final PlanEstudioService _service = PlanEstudioService();
  final ActivityRepository _activityRepo = ActivityRepository();
  final StudySessionRepository _sessionRepo = StudySessionRepository();

  List<StudySession> _sesiones = [];
  Map<int, Activity> _actividades = {};
  Set<int> _sesionesEliminadas = {};
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final sesiones = await _sessionRepo.getPendientes();
      final actividades = await _service.getActividadesPorId();
      if (!mounted) return;
      setState(() {
        _sesiones = sesiones;
        _actividades = actividades;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  Map<DateTime, List<StudySession>> _agruparPorDia() {
    final mapa = <DateTime, List<StudySession>>{};
    for (final s in _sesiones) {
      if (_sesionesEliminadas.contains(s.id)) continue;
      mapa.putIfAbsent(s.fecha, () => []).add(s);
    }
    final ordenado = <DateTime, List<StudySession>>{};
    final claves = mapa.keys.toList()..sort();
    for (final k in claves) {
      ordenado[k] = mapa[k]!..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    }
    return ordenado;
  }

  String _etiquetaTarea(Activity a) {
    if (a.tipo.toLowerCase() == 'examen') {
      return 'Estudio para examen ${a.nombre}';
    }
    return a.nombre;
  }

  String _formatFecha(DateTime f) {
    const dias = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
    const meses = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${dias[f.weekday - 1]} ${f.day} ${meses[f.month - 1]}';
  }

  Future<void> _editarFecha(StudySession s) async {
    final nuevaFecha = await showDatePicker(
      context: context,
      initialDate: s.fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (nuevaFecha == null) return;
    final idx = _sesiones.indexWhere((x) => x.id == s.id);
    if (idx == -1) return;
    setState(() {
      _sesiones[idx] = s.copyWith(
        fecha: DateTime.utc(nuevaFecha.year, nuevaFecha.month, nuevaFecha.day),
      );
    });
  }

  Future<void> _editarDuracion(StudySession s) async {
    final actual = s.duracionHoras;
    final nueva = await showDialog<int>(
      context: context,
      builder: (ctx) {
        int valor = actual.clamp(1, 12);
        return StatefulBuilder(
          builder: (_, setLocal) => AlertDialog(
            title: const Text("Duración (horas)"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: valor > 1 ? () => setLocal(() => valor--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('$valor h',
                      style: const TextStyle(fontSize: 18)),
                ),
                IconButton(
                  onPressed: valor < 12 ? () => setLocal(() => valor++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, valor),
                child: const Text("Aceptar"),
              ),
            ],
          ),
        );
      },
    );
    if (nueva == null) return;
    final idx = _sesiones.indexWhere((x) => x.id == s.id);
    if (idx == -1) return;
    final inicioMin = _toMin(s.horaInicio);
    final nuevoFinMin = inicioMin + nueva * 60;
    setState(() {
      _sesiones[idx] = s.copyWith(horaFin: _formatMin(nuevoFinMin));
    });
  }

  void _quitarSesion(StudySession s) {
    if (s.id == null) return;
    setState(() => _sesionesEliminadas.add(s.id!));
  }

  int _toMin(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  String _formatMin(int m) {
    final mc = m.clamp(0, 23 * 60 + 59);
    final h = (mc ~/ 60).toString().padLeft(2, '0');
    final mm = (mc % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }

  Future<void> _abrirAgregarTareas() async {
    final tareasIncluidasIds = _sesiones
        .where((s) => !_sesionesEliminadas.contains(s.id))
        .map((s) => s.actividadId)
        .toSet();

    final disponibles = (await _activityRepo.getAll())
        .where((a) =>
            a.id != null &&
            !a.completada &&
            a.horasDedicadas > 0 &&
            !tareasIncluidasIds.contains(a.id))
        .toList();

    if (!mounted) return;

    if (disponibles.isEmpty) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: const Text(
            "No hay tareas disponibles para agregar al plan.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Entendido"),
            ),
          ],
        ),
      );
      return;
    }

    final seleccionadas = await showDialog<Set<int>>(
      context: context,
      builder: (ctx) {
        final sel = <int>{};
        return StatefulBuilder(
          builder: (_, setLocal) => AlertDialog(
            title: const Text("Añadir tarea"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: disponibles.map((a) {
                  final checked = sel.contains(a.id);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: checked,
                    title: Text(_etiquetaTarea(a)),
                    subtitle: Text(
                      '${a.materia} · ${a.horasDedicadas}h · vence ${_formatFecha(a.fechaLimite)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    onChanged: (v) => setLocal(() {
                      if (v == true) {
                        sel.add(a.id!);
                      } else {
                        sel.remove(a.id);
                      }
                    }),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: sel.isEmpty ? null : () => Navigator.pop(ctx, sel),
                child: const Text("Añadir"),
              ),
            ],
          ),
        );
      },
    );

    if (seleccionadas == null || seleccionadas.isEmpty) return;

    setState(() => _guardando = true);
    try {
      await _guardarCambiosPendientes();
      final advertencias =
          await _service.agregarTareasAlPlan(seleccionadas.toList());
      await _cargar();
      _sesionesEliminadas.clear();
      if (!mounted) return;
      setState(() => _guardando = false);
      if (advertencias.isNotEmpty) {
        await _mostrarAdvertencias(advertencias);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudieron añadir las tareas")),
      );
    }
  }

  Future<void> _mostrarAdvertencias(List<String> advertencias) async {
    if (advertencias.isEmpty) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Avisos del plan"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: advertencias
                .map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $a', style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarCambiosPendientes() async {
    for (final id in _sesionesEliminadas) {
      await _sessionRepo.delete(id);
    }
    final vigentes =
        _sesiones.where((s) => !_sesionesEliminadas.contains(s.id)).toList();
    await _service.guardarCambiosSesiones(vigentes);
  }

  Future<void> _guardarYSalir() async {
    setState(() => _guardando = true);
    try {
      await _guardarCambiosPendientes();
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudieron guardar los cambios")),
      );
    }
  }

  Widget _buildContenido() {
    final grupos = _agruparPorDia();
    if (grupos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "El plan está vacío. Añade una tarea para empezar.",
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: grupos.entries.map((entry) {
        final dia = entry.key;
        final sesionesDelDia = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                _formatFecha(dia),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            ...sesionesDelDia.map((s) {
              final actividad = _actividades[s.actividadId];
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  title: Text(
                    actividad != null
                        ? _etiquetaTarea(actividad)
                        : 'Tarea #${s.actividadId}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    '${s.horaInicio} – ${s.horaFin} '
                    '(${s.duracionHoras}h)'
                    '${s.emergencia ? "  ·  emergencia" : ""}',
                    style: TextStyle(
                      fontSize: 11,
                      color: s.emergencia
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (v) {
                      if (v == 'fecha') _editarFecha(s);
                      if (v == 'duracion') _editarDuracion(s);
                      if (v == 'quitar') _quitarSesion(s);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'fecha',
                        child: Text("Cambiar fecha"),
                      ),
                      PopupMenuItem(
                        value: 'duracion',
                        child: Text("Cambiar duración"),
                      ),
                      PopupMenuItem(
                        value: 'quitar',
                        child: Text("Quitar del plan"),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar plan de estudio"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _buildContenido(),
      ),
      actionsOverflowButtonSpacing: 4,
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: _guardando ? null : _abrirAgregarTareas,
          child: const Text("Añadir tarea"),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardarYSalir,
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Guardar"),
        ),
      ],
    );
  }
}
