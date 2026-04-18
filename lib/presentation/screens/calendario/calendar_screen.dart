import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/presentation/widgets/calendario/activityCard.dart';
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
    eventosCalendario = {
      DateTime.utc(2026, 4, 17): [
        Activity(
          nombre: "examen de bases de datos 2",
          materia: "bases de datos 2",
          tipo: "examen",
          prioridad: "alta",
          fechaLimite: DateTime.utc(2026, 4, 17),
        ),
      ],
      DateTime.utc(2026, 5, 7): [
        Activity(
          tipo: "proyecto",
          nombre:
              "aplicacion de organizacion academica inteligente, proyecto final de la materia",
          materia: "programacion movil",
          fechaLimite: DateTime.utc(2026, 5, 7),
          horasDedicadas: 5,
          prioridad: "alta",
        ),
      ],
      DateTime.utc(2026, 4, 14): [
        Activity(
          tipo: "examen",
          nombre: "primer examen de bd2",
          materia: "bases de datos 2",
          fechaLimite: DateTime.utc(2026, 4, 14),
          horasDedicadas: 2,
          prioridad: "alta",
        ),
      ],
      DateTime.utc(2026, 5, 12): [
        Activity(
          tipo: "tarea",
          nombre: "comentario de articulo 10",
          materia: "redes de computadoras 2",
          fechaLimite: DateTime.utc(2026, 5, 12),
          horasDedicadas: 2,
          prioridad: "media",
        ),
        Activity(
          tipo: "tarea",
          nombre: "comentario de articulo 11",
          materia: "redes de computadoras 2",
          fechaLimite: DateTime.utc(2026, 5, 12),
          horasDedicadas: 2,
          prioridad: "media",
        ),
      ],
      DateTime.utc(2026, 4, 8): [
        Activity(
          tipo: "tarea",
          nombre: "ejemplo de factura cfdi",
          materia: "Habilidades directivas",
          fechaLimite: DateTime.utc(2026, 4, 8),
          horasDedicadas: 1,
          prioridad: "media",
        ),
      ],
    };
  }

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
          _buildMonthCalendar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Eventos del ${dia.day} de ${meses[dia.month - 1]}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
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
        borderRadius: BorderRadius.circular(12)
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
        headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
      ),
    );
  }

  List<Activity> _getEventosDelDia(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return eventosCalendario[key] ?? [];
  }

  Widget _buildEventList() {
    final eventos = _getEventosDelDia(_selectedDay ?? _focusedDay);
    return ListView.builder(
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        final actividad = eventos[index];
        return ActivityCard(activity: actividad);
      },
    );
  }
}
