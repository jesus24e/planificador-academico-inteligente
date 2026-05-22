import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/utils/activity_utils.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/study_session_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';
import 'package:planificador_academico_inteligente/ui/widgets/calendario/activityCard.dart';
import 'package:planificador_academico_inteligente/ui/widgets/calendario/study_session_card.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Activity> eventosCalendario = [];
  List<StudySession> _sesiones = [];
  Map<int, Activity> _actividadesPorId = {};

  final ActivityRepository _activityRepository = ActivityRepository();
  final StudySessionRepository _sessionRepository = StudySessionRepository();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadActivities();
  }

  Future<void> refrescar() => _loadActivities();

  Future<void> _loadActivities() async {
    try {
      final actividades = await _activityRepository.getAll();
      final sesiones = await _sessionRepository.getPendientes();
      if (!mounted) return;
      setState(() {
        eventosCalendario = sortByPriority(actividades);
        _sesiones = sesiones;
        _actividadesPorId = {
          for (final a in actividades)
            if (a.id != null) a.id!: a,
        };
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        eventosCalendario = [];
        _sesiones = [];
        _actividadesPorId = {};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dia = _selectedDay ?? _focusedDay;
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];

    return SafeArea(
      child: Column(
        children: [
          const Text(
            'Calendario académico',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const Text(
            'Vista general de tus fechas límite',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          _buildMonthCalendar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Eventos del ${dia.day} de ${meses[dia.month - 1]}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(color: Colors.black38, indent: 24, endIndent: 24),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: _getEventosDelDia,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        locale: "es_ES",
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) => _buildMarcadores(day),
        ),
      ),
    );
  }

  Widget? _buildMarcadores(DateTime day) {
    final hayTareas = eventosCalendario.any((a) =>
        a.fechaLimite.year == day.year &&
        a.fechaLimite.month == day.month &&
        a.fechaLimite.day == day.day);
    final haySesiones = _sesiones.any((s) =>
        s.fecha.year == day.year &&
        s.fecha.month == day.month &&
        s.fecha.day == day.day);

    if (!hayTareas && !haySesiones) return null;

    final puntos = <Widget>[];
    if (haySesiones) {
      puntos.add(_punto(Colors.amber));
    }
    if (hayTareas) {
      if (puntos.isNotEmpty) puntos.add(const SizedBox(width: 3));
      puntos.add(_punto(Colors.redAccent));
    }

    return Positioned(
      bottom: 4,
      child: Row(mainAxisSize: MainAxisSize.min, children: puntos),
    );
  }

  Widget _punto(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  List<Activity> _getEventosDelDia(DateTime day) {
    return eventosCalendario
        .where((a) =>
            a.fechaLimite.year == day.year &&
            a.fechaLimite.month == day.month &&
            a.fechaLimite.day == day.day)
        .toList();
  }

  List<StudySession> _getSesionesDelDia(DateTime day) {
    return _sesiones
        .where((s) =>
            s.fecha.year == day.year &&
            s.fecha.month == day.month &&
            s.fecha.day == day.day)
        .toList()
      ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final dia = _selectedDay ?? _focusedDay;
    final sesiones = _getSesionesDelDia(dia);
    final tareas = _getEventosDelDia(dia);

    if (sesiones.isEmpty && tareas.isEmpty) {
      return const Center(child: Text("Sin actividades para este día"));
    }

    final children = <Widget>[];

    if (sesiones.isNotEmpty) {
      children.add(const Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 6),
        child: Text(
          'Plan de estudio',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF92400E),
            letterSpacing: 0.4,
          ),
        ),
      ));
      for (final s in sesiones) {
        final actividad = _actividadesPorId[s.actividadId];
        children.add(StudySessionCard(session: s, actividad: actividad));
      }
    }

    if (tareas.isNotEmpty) {
      if (sesiones.isNotEmpty) {
        children.add(const SizedBox(height: 8));
      }
      children.add(const Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 6),
        child: Text(
          'Tareas que vencen',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            letterSpacing: 0.4,
          ),
        ),
      ));
      for (final a in tareas) {
        children.add(ActivityCard(activity: a));
      }
    }

    return ListView(children: children);
  }
}
