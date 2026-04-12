import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/presentation/widgets/home/cardsRow.dart';
import 'package:planificador_academico_inteligente/presentation/widgets/home/header.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //*variables para el calendario de la semana

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

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
            const SizedBox(height: 16),
            buildCardsRow()
          ],
        ),
      ),
    );
  }

  Widget _buildWeekcalendar() {
    return Container(
      color: const Color.fromARGB(255, 223, 223, 223),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        calendarFormat: CalendarFormat.twoWeeks,
        availableCalendarFormats: {CalendarFormat.twoWeeks: 'semana'},
        locale: 'es_ES',
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });},
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 60,
        calendarStyle: CalendarStyle(),
        headerStyle: HeaderStyle(titleCentered: true),
      ),
    );
  }
}
