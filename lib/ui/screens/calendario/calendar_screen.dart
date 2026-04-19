import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/simulations/actividades_sim.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/ui/widgets/calendario/activityCard.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Activity>> eventosCalendario = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    eventosCalendario = mapDateActivity;
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
    final key = DateTime.utc(day.year, day.month, day.day);
    return eventosCalendario[key] ?? [];
  }

  Widget _buildEventList() {
    final eventos = _getEventosDelDia(_selectedDay ?? _focusedDay);

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
