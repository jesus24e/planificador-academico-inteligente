import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/subject_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/cardsRow.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/header.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/priorityList.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/agregar_prioridad_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ActivityRepository _activityRepo = ActivityRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();

  DateTime _focusedDay = DateTime.now();

  List<Activity> _prioridades = [];
  Map<DateTime, List<Activity>> _eventosCalendario = {};
  int _vencenHoy = 0;
  int _materiasActivas = 0;
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

      if (!mounted) return;
      setState(() {
        _prioridades = actualizadas
            .where((a) => a.prioridadEstado == Activity.prioridadEnLista)
            .toList();
        _eventosCalendario = _mapearEventos(actualizadas);
        _vencenHoy = _contarVencenHoy(actualizadas);
        _materiasActivas = subjects.length;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _prioridades = [];
        _eventosCalendario = {};
        _vencenHoy = 0;
        _materiasActivas = 0;
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

  List<Activity> _getEventosDelDia(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _eventosCalendario[key] ?? [];
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
            PriorityList(
              actividades: _prioridades,
              cargando: _cargando,
              onChanged: _cargar,
            ),
            const SizedBox(height: 15),
            _buildAddTaskBtn(),
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
        calendarStyle: const CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
        eventLoader: _getEventosDelDia,
      ),
    );
  }

  Widget _buildAddTaskBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FilledButton(
        onPressed: _abrirAgregarTarea,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text("Agregar tarea"),
      ),
    );
  }
}
