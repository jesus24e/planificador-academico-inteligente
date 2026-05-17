import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/simulations/actividades_sim.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/cardsRow.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/header.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/priorityList.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/aniadirTarea.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //*variables para el calendario de la semana

  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Activity>> eventosCalendario = {};

  @override
  void initState() {
    super.initState();
    eventosCalendario = mapDateActivity;
  }
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 16),
            _buildWeekcalendar(),
            const SizedBox(height: 20),
            buildCardsRow(),
            const SizedBox(height: 20),
            buildPrioritiesList(),
            const SizedBox(height: 15),
            buildAddTaskBtn(),
            
          ],
        ),
      ),
    );
  }

  Widget _buildWeekcalendar() {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 8)],
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
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 60,
        calendarStyle: CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
        eventLoader: _getEventosDelDia,
      ),
    );
  }

  List<Activity> _getEventosDelDia(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return eventosCalendario[key] ?? [];
  }

  Widget buildAddTaskBtn() {
  return Container(
    alignment: Alignment.centerRight,
    child: FilledButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => AniadirTareaDialog(
          onCreated: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tarea guardada")),
            );
          },
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      child: const Text("Añadir tarea"),
    ),
  );
}
}
