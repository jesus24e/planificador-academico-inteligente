import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/services/plan_estudio_service.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/study_session_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/subject_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/cardsRow.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/editar_plan_dialog.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/header.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/plan_existente_dialog.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/priorityList.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/agregar_prioridad_dialog.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/sesion_del_dia_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ActivityRepository _activityRepo = ActivityRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();
  final StudySessionRepository _sessionRepo = StudySessionRepository();
  final PlanEstudioService _planService = PlanEstudioService();

  DateTime _focusedDay = DateTime.now();

  List<Activity> _prioridades = [];
  Map<DateTime, List<Activity>> _eventosCalendario = {};
  List<StudySession> _sesionesPendientes = [];
  int _vencenHoy = 0;
  int _materiasActivas = 0;
  int _sesionesHoyPendientes = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> refrescar() => _cargar();

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final todas = await _activityRepo.getAll();
      await _quitarVencidasDePrioridad(todas);
      await _autoAgregarPorCalendario(todas);

      final actualizadas = await _activityRepo.getAll();
      final subjects = await _subjectRepo.getAll();
      final sesionesPendientes = await _sessionRepo.getPendientes();
      final hoy = DateTime.now();
      final sesionesHoy = sesionesPendientes.where((s) =>
          s.fecha.year == hoy.year &&
          s.fecha.month == hoy.month &&
          s.fecha.day == hoy.day).length;

      if (!mounted) return;
      setState(() {
        _prioridades = actualizadas
            .where((a) => a.prioridadEstado == Activity.prioridadEnLista)
            .toList();
        _eventosCalendario = _mapearEventos(actualizadas);
        _sesionesPendientes = sesionesPendientes;
        _vencenHoy = _contarVencenHoy(actualizadas);
        _materiasActivas = subjects.length;
        _sesionesHoyPendientes = sesionesHoy;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _prioridades = [];
        _eventosCalendario = {};
        _sesionesPendientes = [];
        _vencenHoy = 0;
        _materiasActivas = 0;
        _sesionesHoyPendientes = 0;
        _cargando = false;
      });
    }
  }

  Future<void> _quitarVencidasDePrioridad(List<Activity> todas) async {
    final ahora = DateTime.now();
    final hoy = DateTime.utc(ahora.year, ahora.month, ahora.day);
    for (final a in todas) {
      if (a.id == null) continue;
      if (a.prioridadEstado != Activity.prioridadEnLista) continue;
      final f = a.fechaLimite;
      final fecha = DateTime.utc(f.year, f.month, f.day);
      if (fecha.isBefore(hoy)) {
        await _activityRepo.setPrioridadEstado(
          a.id!,
          Activity.prioridadNinguno,
        );
      }
    }
  }

  Future<void> _autoAgregarPorCalendario(List<Activity> todas) async {
    final inicio = _inicioRangoCalendario();
    final fin = inicio.add(const Duration(days: 14));
    for (final a in todas) {
      if (a.id == null) continue;
      if (a.prioridadEstado != Activity.prioridadNinguno) continue;
      if (a.completada) continue;
      final fecha = a.fechaLimite;
      final dentro = !fecha.isBefore(inicio) && fecha.isBefore(fin);
      if (dentro) {
        await _activityRepo.setPrioridadEstado(
          a.id!,
          Activity.prioridadEnLista,
        );
      }
    }
  }

  DateTime _inicioRangoCalendario() {
    final f = _focusedDay;
    final base = DateTime.utc(f.year, f.month, f.day);
    return base.subtract(Duration(days: base.weekday - 1));
  }

  Map<DateTime, List<Activity>> _mapearEventos(List<Activity> actividades) {
    final mapa = <DateTime, List<Activity>>{};
    for (final a in actividades) {
      final f = a.fechaLimite;
      final key = DateTime.utc(f.year, f.month, f.day);
      mapa.putIfAbsent(key, () => []).add(a);
    }
    return mapa;
  }

  int _contarVencenHoy(List<Activity> actividades) {
    final hoy = DateTime.now();
    return actividades.where((a) {
      final f = a.fechaLimite;
      return f.year == hoy.year && f.month == hoy.month && f.day == hoy.day;
    }).length;
  }

  void _abrirSesionDelDia() {
    showDialog(
      context: context,
      builder: (_) => SesionDelDiaDialog(onChanged: _cargar),
    );
  }

  List<Activity> _getEventosDelDia(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _eventosCalendario[key] ?? [];
  }

  Widget? _buildMarcadores(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    final hayTareas = (_eventosCalendario[key] ?? []).isNotEmpty;
    final haySesiones = _sesionesPendientes.any((s) =>
        s.fecha.year == day.year &&
        s.fecha.month == day.month &&
        s.fecha.day == day.day);

    if (!hayTareas && !haySesiones) return null;

    final puntos = <Widget>[];
    if (haySesiones) {
      puntos.add(Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
      ));
    }
    if (hayTareas) {
      if (puntos.isNotEmpty) puntos.add(const SizedBox(width: 3));
      puntos.add(Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
      ));
    }

    return Positioned(
      bottom: 4,
      child: Row(mainAxisSize: MainAxisSize.min, children: puntos),
    );
  }

  void _abrirAgregarTarea() {
    showDialog(
      context: context,
      builder: (_) => AgregarPrioridadDialog(onAgregada: _cargar),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 16),
            _buildWeekcalendar(),
            const SizedBox(height: 20),
            CardsRow(
              pendientes: _prioridades.length,
              vencenHoy: _vencenHoy,
              materiasActivas: _materiasActivas,
            ),
            const SizedBox(height: 20),
            if (_sesionesHoyPendientes > 0) ...[
              _buildSesionDelDiaBtn(),
              const SizedBox(height: 12),
            ],
            PriorityList(
              actividades: _prioridades,
              cargando: _cargando,
              onChanged: _cargar,
            ),
            const SizedBox(height: 15),
            _buildAccionesRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekcalendar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        calendarFormat: CalendarFormat.twoWeeks,
        locale: 'es_ES',
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _cargar();
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 60,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) => _buildMarcadores(day),
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
        eventLoader: _getEventosDelDia,
      ),
    );
  }

  Widget _buildSesionDelDiaBtn() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _abrirSesionDelDia,
        icon: const Icon(Icons.menu_book),
        label: Text(
          _sesionesHoyPendientes == 1
              ? 'REALIZA TU SESIÓN DEL DÍA'
              : 'REALIZA TUS SESIONES DEL DÍA ($_sesionesHoyPendientes)',
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAccionesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FilledButton(
          onPressed: _abrirPlanEstudio,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A5F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Plan de estudio"),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _abrirAgregarTarea,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Agregar tarea"),
        ),
      ],
    );
  }

  Future<void> _abrirPlanEstudio() async {
    final existe = await _planService.existePlanActivo();
    if (!mounted) return;

    if (!existe) {
      await _generarPlanConFeedback();
      return;
    }

    final accion = await showDialog<PlanExistenteAccion>(
      context: context,
      builder: (_) => const PlanExistenteDialog(),
    );

    if (accion == PlanExistenteAccion.regenerar) {
      await _generarPlanConFeedback();
    } else if (accion == PlanExistenteAccion.editar) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => EditarPlanDialog(onSaved: _cargar),
      );
    }
  }

  Future<void> _generarPlanConFeedback() async {
    final advertencias = await _planService.generarPlan();
    if (!mounted) return;
    await _cargar();
    if (advertencias.isNotEmpty) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Plan generado con avisos"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: advertencias
                  .map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child:
                            Text('• $a', style: const TextStyle(fontSize: 13)),
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
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plan de estudio generado")),
      );
    }
  }
}
