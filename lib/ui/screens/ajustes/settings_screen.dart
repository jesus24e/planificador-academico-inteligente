import 'package:flutter/material.dart';

const _gris = Color(0xFF6B7280);
const _azul = Color(0xFF1E3A5F);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<SettingsScreen> {
  int _horasPorDia = 3;
  final Map<String, bool> _dias = {
    'L': true,
    'M': true,
    'X': false,
    'J': true,
    'V': false,
    'S': false,
    'D': false,
  };
  String _horario = 'Tarde (12PM - 6PM)';
  bool _recordatorioSesiones = true;
  bool _alertasEvaluaciones = true;
  bool _riesgoAcademico = false;
  TimeOfDay _horaNotificacion = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: ListView(
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
                _recordatorioSesiones,
                (value) => setState(() => _recordatorioSesiones = value),
              ),
              _toggle(
                'Alertas de evaluaciones próximas',
                _alertasEvaluaciones,
                (value) => setState(() => _alertasEvaluaciones = value),
              ),
              _toggle(
                'Indicador de riesgo académico',
                _riesgoAcademico,
                (value) => setState(() => _riesgoAcademico = value),
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(),
            style: TextStyle(
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
        Text(
          'Horas de estudio por día',
          style: TextStyle(fontSize: 13, color: _gris),
        ),
        const Spacer(),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                if (_horasPorDia > 1) _horasPorDia--;
              }),
              icon: const Icon(Icons.remove, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '$_horasPorDia',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                if (_horasPorDia < 12) _horasPorDia++;
              }),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Días disponibles', style: TextStyle(fontSize: 13, color: _gris)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _dias.entries.map((entry) {
            return GestureDetector(
              onTap: () => setState(() => _dias[entry.key] = !entry.value),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: entry.value ? _azul : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: entry.value ? Colors.white : _gris,
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
    const opciones = [
      'Mañana (6AM - 12PM)',
      'Tarde (12PM - 6PM)',
      'Noche (6PM - 12AM)',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horario preferente',
          style: TextStyle(fontSize: 13, color: _gris),
        ),
        const SizedBox(height: 6),
        DropdownButton(
          value: _horario,
          isExpanded: true,
          items: opciones
              .map(
                (opcion) => DropdownMenuItem(
                  value: opcion,
                  child: Text(opcion, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _horario = value ?? ""),
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
        Text(
          'Hora para notificaciones',
          style: TextStyle(fontSize: 13, color: _gris),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _horaNotificacion,
            );
            if (time != null) setState(() => _horaNotificacion = time);
          },
          icon: const Icon(Icons.schedule, size: 16),
          label: Text(
            _horaNotificacion.format(context),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
