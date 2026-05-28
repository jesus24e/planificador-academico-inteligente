import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/services/notification_service.dart';
import 'package:planificador_academico_inteligente/data/repositories/user_preferences_repository.dart';
import 'package:planificador_academico_inteligente/entities/user_preferences.dart';

const _gris = Color(0xFF6B7280);
const _azul = Color(0xFF1E3A5F);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<SettingsScreen> {
  static const _opcionesHorario = {
    UserPreferences.horarioManana: 'Mañana (6AM - 12PM)',
    UserPreferences.horarioTarde: 'Tarde (12PM - 6PM)',
    UserPreferences.horarioNoche: 'Noche (6PM - 12AM)',
  };

  final UserPreferencesRepository _repo = UserPreferencesRepository();

  UserPreferences _prefs = const UserPreferences();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final p = await _repo.get();
      if (!mounted) return;
      setState(() {
        _prefs = p;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  void _actualizar(UserPreferences nuevas) {
    setState(() => _prefs = nuevas);
    _repo.save(nuevas).then((_) {
      NotificationService().reprogramarTodo();
    }).catchError((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la preferencia')),
      );
    });
  }

  TimeOfDay get _horaNotificacionTOD {
    final partes = _prefs.horaNotificacion.split(':');
    final h = int.tryParse(partes.isNotEmpty ? partes[0] : '') ?? 8;
    final m = int.tryParse(partes.length > 1 ? partes[1] : '') ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _titulo(),
                  const SizedBox(height: 16),
                  _seccion('Disponibilidad horaria', [
                    _horasEstudio(),
                    const SizedBox(height: 14),
                    _diasDisponibles(),
                    const SizedBox(height: 14),
                    _horarioPreferente(),
                  ]),
                  const SizedBox(height: 12),
                  _seccion('Notificaciones', [
                    _toggle(
                      'Recordatorio de sesiones de estudio',
                      _prefs.recordatorioSesiones,
                      (v) => _actualizar(
                        _prefs.copyWith(recordatorioSesiones: v),
                      ),
                    ),
                    _toggle(
                      'Alertas de evaluaciones próximas',
                      _prefs.alertasEvaluaciones,
                      (v) => _actualizar(
                        _prefs.copyWith(alertasEvaluaciones: v),
                      ),
                    ),
                    _toggle(
                      'Indicador de riesgo académico',
                      _prefs.riesgoAcademico,
                      (v) => _actualizar(
                        _prefs.copyWith(riesgoAcademico: v),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _horaNotificaciones(),
                  ]),
                  const SizedBox(height: 12),
                ],
              ),
      ),
    );
  }

  Widget _titulo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ajustes',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          'Personaliza tu experiencia',
          style: TextStyle(fontSize: 13, color: _gris),
        ),
      ],
    );
  }

  Widget _seccion(String titulo, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: _gris,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _horasEstudio() {
    return Row(
      children: [
        const Text(
          'Horas de estudio por día',
          style: TextStyle(fontSize: 13, color: _gris),
        ),
        const Spacer(),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (_prefs.horasPorDia > 1) {
                  _actualizar(
                    _prefs.copyWith(horasPorDia: _prefs.horasPorDia - 1),
                  );
                }
              },
              icon: const Icon(Icons.remove, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${_prefs.horasPorDia}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                if (_prefs.horasPorDia < 12) {
                  _actualizar(
                    _prefs.copyWith(horasPorDia: _prefs.horasPorDia + 1),
                  );
                }
              },
              icon: const Icon(Icons.add, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _diasDisponibles() {
    final entradas = <(String, bool, UserPreferences Function(bool))>[
      ('L', _prefs.diaLunes, (v) => _prefs.copyWith(diaLunes: v)),
      ('M', _prefs.diaMartes, (v) => _prefs.copyWith(diaMartes: v)),
      ('X', _prefs.diaMiercoles, (v) => _prefs.copyWith(diaMiercoles: v)),
      ('J', _prefs.diaJueves, (v) => _prefs.copyWith(diaJueves: v)),
      ('V', _prefs.diaViernes, (v) => _prefs.copyWith(diaViernes: v)),
      ('S', _prefs.diaSabado, (v) => _prefs.copyWith(diaSabado: v)),
      ('D', _prefs.diaDomingo, (v) => _prefs.copyWith(diaDomingo: v)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Días disponibles',
          style: TextStyle(fontSize: 13, color: _gris),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: entradas.map((e) {
            final (letra, activo, mutator) = e;
            return GestureDetector(
              onTap: () => _actualizar(mutator(!activo)),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: activo ? _azul : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letra,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: activo ? Colors.white : _gris,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _horarioPreferente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horario preferente',
          style: TextStyle(fontSize: 13, color: _gris),
        ),
        const SizedBox(height: 6),
        DropdownButton<String>(
          value: _prefs.horarioPreferente,
          isExpanded: true,
          items: _opcionesHorario.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _actualizar(_prefs.copyWith(horarioPreferente: value));
            }
          },
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _horaNotificaciones() {
    return Row(
      children: [
        const Text(
          'Hora para notificaciones',
          style: TextStyle(fontSize: 13, color: _gris),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _horaNotificacionTOD,
            );
            if (time != null) {
              _actualizar(
                _prefs.copyWith(horaNotificacion: _formatTimeOfDay(time)),
              );
            }
          },
          icon: const Icon(Icons.schedule, size: 16),
          label: Text(
            _horaNotificacionTOD.format(context),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
