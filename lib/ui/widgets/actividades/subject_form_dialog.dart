import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/data/repositories/subject_repository.dart';
import 'package:planificador_academico_inteligente/entities/subject.dart';

class SubjectFormDialog extends StatefulWidget {
  final Subject? subject;
  final void Function(Subject creada)? onSaved;

  const SubjectFormDialog({super.key, this.subject, this.onSaved});

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog> {
  static const List<String> _diasNombres = [
    'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom',
  ];

  final SubjectRepository _repo = SubjectRepository();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _profesorCtrl;

  List<bool> _diasSeleccionados = List.filled(7, false);
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  String? _horarioPrevioNoEstandar;

  bool _guardando = false;

  bool get _esEdicion => widget.subject != null;

  @override
  void initState() {
    super.initState();
    final s = widget.subject;
    _nombreCtrl = TextEditingController(text: s?.nombre ?? '');
    _profesorCtrl = TextEditingController(text: s?.profesor ?? '');
    _parsearHorarioExistente(s?.horario);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _profesorCtrl.dispose();
    super.dispose();
  }

  void _parsearHorarioExistente(String? horario) {
    if (horario == null || horario.trim().isEmpty) return;
    final partes = horario.split('·');
    if (partes.length != 2) {
      _horarioPrevioNoEstandar = horario.trim();
      return;
    }

    final diasStr = partes[0].trim();
    final rangoStr = partes[1].trim();

    final diasTokens = diasStr.split(',').map((s) => s.trim()).toList();
    final dias = List.filled(7, false);
    for (final t in diasTokens) {
      final idx = _diasNombres.indexOf(t);
      if (idx == -1) {
        _horarioPrevioNoEstandar = horario.trim();
        return;
      }
      dias[idx] = true;
    }

    final rangoPartes = rangoStr.split('-');
    if (rangoPartes.length != 2) {
      _horarioPrevioNoEstandar = horario.trim();
      return;
    }

    final inicio = _parsearHora(rangoPartes[0].trim());
    final fin = _parsearHora(rangoPartes[1].trim());
    if (inicio == null || fin == null) {
      _horarioPrevioNoEstandar = horario.trim();
      return;
    }

    _diasSeleccionados = dias;
    _horaInicio = inicio;
    _horaFin = fin;
  }

  TimeOfDay? _parsearHora(String s) {
    final partes = s.split(':');
    if (partes.length != 2) return null;
    final h = int.tryParse(partes[0]);
    final m = int.tryParse(partes[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatHora(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _construirHorario() {
    final diasActivos = <String>[];
    for (int i = 0; i < 7; i++) {
      if (_diasSeleccionados[i]) diasActivos.add(_diasNombres[i]);
    }

    final hayDias = diasActivos.isNotEmpty;
    final hayHoras = _horaInicio != null && _horaFin != null;

    if (!hayDias && !hayHoras) return '';
    if (hayDias && hayHoras) {
      return '${diasActivos.join(', ')} · '
          '${_formatHora(_horaInicio!)}-${_formatHora(_horaFin!)}';
    }
    if (hayDias) return diasActivos.join(', ');
    return '${_formatHora(_horaInicio!)}-${_formatHora(_horaFin!)}';
  }

  Future<void> _pickHora({required bool esInicio}) async {
    final inicial = esInicio
        ? (_horaInicio ?? const TimeOfDay(hour: 8, minute: 0))
        : (_horaFin ?? const TimeOfDay(hour: 10, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: inicial,
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          _horaInicio = picked;
        } else {
          _horaFin = picked;
        }
      });
    }
  }

  int _minutosDelDia(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    final profesor = _profesorCtrl.text.trim();

    if (nombre.isEmpty || profesor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre y profesor son obligatorios")),
      );
      return;
    }

    final hayInicio = _horaInicio != null;
    final hayFin = _horaFin != null;
    if (hayInicio != hayFin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Define ambas horas o deja ambas vacías")),
      );
      return;
    }
    if (hayInicio && hayFin) {
      if (_minutosDelDia(_horaInicio!) >= _minutosDelDia(_horaFin!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("La hora de inicio debe ser anterior a la de fin"),
          ),
        );
        return;
      }
    }

    final horario = _construirHorario();

    setState(() => _guardando = true);

    final duplicada = await _repo.findByNombreYProfesor(
      nombre,
      profesor,
      excluirId: widget.subject?.id,
    );
    if (duplicada != null) {
      if (!mounted) return;
      setState(() => _guardando = false);
      await _alertaDuplicada();
      return;
    }

    try {
      Subject guardada;
      if (_esEdicion) {
        guardada = widget.subject!.copyWith(
          nombre: nombre,
          profesor: profesor,
          horario: horario,
        );
        await _repo.update(guardada);
      } else {
        final nueva = Subject(
          nombre: nombre,
          profesor: profesor,
          horario: horario,
        );
        final id = await _repo.insert(nueva);
        guardada = nueva.copyWith(id: id);
      }
      widget.onSaved?.call(guardada);
      if (mounted) Navigator.pop(context, guardada);
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo guardar la materia")),
      );
    }
  }

  Future<void> _alertaDuplicada() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(
          "La materia solicitada ya existe, no es necesario crear otra.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorDias() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(7, (i) {
        return FilterChip(
          label: Text(_diasNombres[i]),
          selected: _diasSeleccionados[i],
          onSelected: (val) {
            setState(() => _diasSeleccionados[i] = val);
          },
        );
      }),
    );
  }

  Widget _buildSelectorHoras() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickHora(esInicio: true),
            child: Text(
              _horaInicio != null ? _formatHora(_horaInicio!) : "Inicio",
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("–"),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickHora(esInicio: false),
            child: Text(
              _horaFin != null ? _formatHora(_horaFin!) : "Fin",
            ),
          ),
        ),
        if (_horaInicio != null || _horaFin != null)
          IconButton(
            tooltip: "Limpiar horario",
            onPressed: () {
              setState(() {
                _horaInicio = null;
                _horaFin = null;
              });
            },
            icon: const Icon(Icons.close, size: 18),
          ),
      ],
    );
  }

  Widget _buildAvisoFormatoAnterior() {
    if (_horarioPrevioNoEstandar == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Horario anterior: "$_horarioPrevioNoEstandar". '
        'Se reemplazará al guardar.',
        style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_esEdicion ? "Editar materia" : "Nueva materia"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre *"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _profesorCtrl,
              decoration: const InputDecoration(labelText: "Profesor *"),
            ),
            const SizedBox(height: 14),
            const Text(
              "Días",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _buildSelectorDias(),
            const SizedBox(height: 14),
            const Text(
              "Horario",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _buildSelectorHoras(),
            _buildAvisoFormatoAnterior(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_esEdicion ? "Guardar" : "Crear"),
        ),
      ],
    );
  }
}
