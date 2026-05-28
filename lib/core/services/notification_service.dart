import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/study_session_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/user_preferences_repository.dart';
import 'package:planificador_academico_inteligente/entities/user_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelIdSesiones = 'sesiones_estudio';
  static const String _channelIdEvaluaciones = 'evaluaciones';
  static const String _channelIdRiesgo = 'riesgo_academico';

  static const int _idBaseSesionInicio = 1000;
  static const int _idBaseSesionFin = 2000;
  static const int _idBaseEval12 = 3000;
  static const int _idBaseEval2359 = 4000;
  static const int _idRiesgo = 9000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _activityRepo = ActivityRepository();
  final _sessionRepo = StudySessionRepository();
  final _prefsRepo = UserPreferencesRepository();

  bool _inicializado = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> init({GlobalKey<NavigatorState>? navigatorKey}) async {
    if (_inicializado) return;
    _navigatorKey = navigatorKey;

    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelIdSesiones,
          'Sesiones de estudio',
          description: 'Recordatorios de tus sesiones de estudio del día',
          importance: Importance.high,
        ),
      );
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelIdEvaluaciones,
          'Evaluaciones próximas',
          description: 'Alertas sobre tareas y exámenes que vencen pronto',
          importance: Importance.high,
        ),
      );
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelIdRiesgo,
          'Riesgo académico',
          description: 'Avisos cuando no realizas tu sesión del día',
          importance: Importance.high,
        ),
      );
    }

    _inicializado = true;
  }

  Future<bool> pedirPermisos() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return true;

    final notifGranted = await androidImpl.requestNotificationsPermission();
    final exactGranted = await androidImpl.requestExactAlarmsPermission();
    return (notifGranted ?? false) || (exactGranted ?? false);
  }

  void _onTap(NotificationResponse response) {
    final key = _navigatorKey;
    if (key == null) return;
    key.currentState?.popUntil((route) => route.isFirst);
  }

  Future<void> reprogramarTodo() async {
    if (!_inicializado) return;
    await _plugin.cancelAll();

    final prefs = await _prefsRepo.get();

    if (prefs.recordatorioSesiones) {
      await _programarRecordatoriosSesiones(prefs);
    }
    if (prefs.alertasEvaluaciones) {
      await _programarAlertasEvaluaciones();
    }
    if (prefs.riesgoAcademico) {
      await _programarIndicadorRiesgo();
    }
  }

  Future<void> _programarRecordatoriosSesiones(UserPreferences prefs) async {
    final pendientes = await _sessionRepo.getPendientes();
    if (pendientes.isEmpty) return;

    final mapa = <String, int>{};
    for (final s in pendientes) {
      final clave = _fechaKey(s.fecha);
      mapa[clave] = (mapa[clave] ?? 0) + 1;
    }

    final (inicioMin, finMin) = _rangoHorario(prefs.horarioPreferente);
    final inicioH = inicioMin ~/ 60;
    final inicioM = inicioMin % 60;
    final finRecordatorioMin = finMin - 2 * 60;
    final fin2hH = (finRecordatorioMin ~/ 60).clamp(0, 23);
    final fin2hM = finRecordatorioMin % 60;

    final ahora = tz.TZDateTime.now(tz.local);

    int idxDia = 0;
    for (final entrada in mapa.entries) {
      final partes = entrada.key.split('-');
      final fecha = DateTime(
        int.parse(partes[0]),
        int.parse(partes[1]),
        int.parse(partes[2]),
      );
      final n = entrada.value;

      final inicio = tz.TZDateTime(
        tz.local,
        fecha.year,
        fecha.month,
        fecha.day,
        inicioH,
        inicioM,
      );
      final finRecordatorio = tz.TZDateTime(
        tz.local,
        fecha.year,
        fecha.month,
        fecha.day,
        fin2hH,
        fin2hM,
      );

      if (inicio.isAfter(ahora)) {
        await _programar(
          id: _idBaseSesionInicio + idxDia,
          fecha: inicio,
          canal: _channelIdSesiones,
          titulo: '¡Es hora de estudiar!',
          cuerpo: n == 1
              ? 'Hoy tienes 1 sesión pendiente. Abre la app para comenzar.'
              : 'Hoy tienes $n sesiones pendientes. Abre la app para comenzar.',
        );
      }

      if (finRecordatorio.isAfter(ahora)) {
        await _programar(
          id: _idBaseSesionFin + idxDia,
          fecha: finRecordatorio,
          canal: _channelIdSesiones,
          titulo: 'Tu horario de estudio termina pronto',
          cuerpo: n == 1
              ? 'Aún tienes 1 sesión pendiente. ¡No la dejes para mañana!'
              : 'Aún tienes $n sesiones pendientes. ¡No las dejes para mañana!',
        );
      }

      idxDia++;
      if (idxDia >= 14) break;
    }
  }

  Future<void> _programarAlertasEvaluaciones() async {
    final actividades = await _activityRepo.getAll();
    final hoy = DateTime.now();
    final mananaKey = _fechaKey(hoy.add(const Duration(days: 1)));

    final manana = actividades.where((a) {
      if (a.completada) return false;
      return _fechaKey(a.fechaLimite) == mananaKey;
    }).toList();

    if (manana.isEmpty) return;

    final ahora = tz.TZDateTime.now(tz.local);
    final hoy12 = tz.TZDateTime(
      tz.local, hoy.year, hoy.month, hoy.day, 12, 0,
    );
    final hoy2359 = tz.TZDateTime(
      tz.local, hoy.year, hoy.month, hoy.day, 23, 59,
    );

    final n = manana.length;
    final cuerpo = n == 1
        ? '"${manana.first.nombre}" vence mañana. ¿Ya estás listo?'
        : 'Tienes $n entregas que vencen mañana. Prepárate.';

    if (hoy12.isAfter(ahora)) {
      await _programar(
        id: _idBaseEval12,
        fecha: hoy12,
        canal: _channelIdEvaluaciones,
        titulo: 'Mañana vence una entrega',
        cuerpo: cuerpo,
      );
    }
    if (hoy2359.isAfter(ahora)) {
      await _programar(
        id: _idBaseEval2359,
        fecha: hoy2359,
        canal: _channelIdEvaluaciones,
        titulo: 'Última llamada: entrega para mañana',
        cuerpo: cuerpo,
      );
    }
  }

  Future<void> _programarIndicadorRiesgo() async {
    final hoy = DateTime.now();
    final hoyUtc = DateTime.utc(hoy.year, hoy.month, hoy.day);
    final sesionesHoy = await _sessionRepo.getByFecha(hoyUtc);
    final pendientesHoy = sesionesHoy.where((s) => !s.completada).toList();
    if (pendientesHoy.isEmpty) return;

    final ahora = tz.TZDateTime.now(tz.local);
    final disparo = tz.TZDateTime(
      tz.local, hoy.year, hoy.month, hoy.day, 22, 0,
    );
    if (!disparo.isAfter(ahora)) return;

    final n = pendientesHoy.length;
    await _programar(
      id: _idRiesgo,
      fecha: disparo,
      canal: _channelIdRiesgo,
      titulo: 'No realizaste tu sesión del día',
      cuerpo: n == 1
          ? 'No completaste tu sesión de hoy. Estás en riesgo de no terminar a tiempo.'
          : 'Te quedaron $n sesiones sin completar hoy. Estás en riesgo de no terminar a tiempo.',
    );
  }

  Future<void> _programar({
    required int id,
    required tz.TZDateTime fecha,
    required String canal,
    required String titulo,
    required String cuerpo,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        canal,
        canal,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        titulo,
        cuerpo,
        fecha,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id,
          titulo,
          cuerpo,
          fecha,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {}
    }
  }

  Future<void> cancelarTodas() async {
    if (!_inicializado) return;
    await _plugin.cancelAll();
  }

  String _fechaKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  (int, int) _rangoHorario(String pref) {
    switch (pref) {
      case UserPreferences.horarioManana:
        return (6 * 60, 12 * 60);
      case UserPreferences.horarioNoche:
        return (18 * 60, 24 * 60);
      case UserPreferences.horarioTarde:
      default:
        return (12 * 60, 18 * 60);
    }
  }
}
