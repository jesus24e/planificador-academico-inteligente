import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/services/notification_service.dart';
import 'package:planificador_academico_inteligente/ui/screens/actividades/activities_screen.dart';
import 'package:planificador_academico_inteligente/ui/screens/ajustes/settings_screen.dart';
import 'package:planificador_academico_inteligente/ui/screens/calendario/calendar_screen.dart';
import '../screens/home/home_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 2;

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<CalendarScreenState> _calendarKey =
      GlobalKey<CalendarScreenState>();

  late final List<Widget> _screens = [
    CalendarScreen(key: _calendarKey),
    const ActivitieScreen(),
    HomeScreen(key: _homeKey),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupNotificaciones());
  }

  Future<void> _setupNotificaciones() async {
    final service = NotificationService();
    await service.pedirPermisos();
    await service.reprogramarTodo();
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      _calendarKey.currentState?.refrescar();
    } else if (index == 2) {
      _homeKey.currentState?.refrescar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
