import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/utils/activity_utils.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/ui/widgets/calendario/activityCard.dart';
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
  final ActivityRepository _activityRepository = ActivityRepository();
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
      if (!mounted) return;
      setState(() {
        eventosCalendario = sortByPriority(actividades);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        eventosCalendario = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dia = _selectedDay ?? _focusedDay;
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return SafeArea(
      child: Column(
        children: [
          const Text(
            'Calendario académico',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          Text(
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
          Divider(color: Colors.black38, indent: 24, endIndent: 24),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar() {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: _getEventosDelDia,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        locale: "es_ES",
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  List<Activity> _getEventosDelDia(DateTime day) {
    final listaEventos = eventosCalendario
        .where(
          (a) =>
              a.fechaLimite.year == day.year &&
              a.fechaLimite.month == day.month &&
              a.fechaLimite.day == day.day,
        )
        .toList();
    return listaEventos;
  }

  Widget _buildEventList() {
    final eventos = _getEventosDelDia(_selectedDay ?? _focusedDay);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (eventos.isNotEmpty) {
      return ListView.builder(
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final actividad = eventos[index];
          return ActivityCard(activity: actividad);
        },
      );
    } else {
      return Center(child: Text("Sin actividades para este día"));
    }
  }
}
