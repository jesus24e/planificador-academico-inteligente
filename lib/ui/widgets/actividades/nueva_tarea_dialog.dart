// ARCHIVO NO USADO / DEPRECADO
// Este dialogo fue reemplazado por AniadirTareaDialog (lib/ui/widgets/home/aniadirTarea.dart),
// que es la implementacion oficial integrada tras el merge del equipo.
// Se conserva comentado unicamente como referencia historica. No se importa en ningun lado.
/*
import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/subject_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/subject.dart';

class NuevaTareaDialog extends StatefulWidget {
  final VoidCallback onCreated;

  const NuevaTareaDialog({super.key, required this.onCreated});

  @override
  State<NuevaTareaDialog> createState() => _NuevaTareaDialogState();
}

class _NuevaTareaDialogState extends State<NuevaTareaDialog> {
  final ActivityRepository _activityRepo = ActivityRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();

  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _materiaCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController(text: 'tarea');

  String _prioridad = 'media';
  int _horas = 0;
  DateTime _fecha = DateTime.now();

  List<Subject> _subjects = [];
  String? _materiaSeleccionada;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _materiaCtrl.dispose();
    _tipoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarMaterias() async {
    try {
      final subjects = await _subjectRepo.getAll();
      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _materiaSeleccionada = subjects.isNotEmpty ? subjects.first.nombre : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _subjects = [];
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _fecha = DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    final nombre = _nombreCtrl.text.trim();
    final tipo = _tipoCtrl.text.trim().toLowerCase();
    final materia = _materiaSeleccionada;

    if (nombre.isEmpty || tipo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre y tipo')),
      );
      return;
    }

    if (materia == null || materia.isEmpty) {
      _mostrarMateriaRequerida();
      return;
    }

    final existe = await _subjectRepo.getByName(materia);
    if (existe == null) {
      _mostrarMateriaRequerida(nombreFaltante: materia);
      return;
    }

    setState(() => _saving = true);
    final nueva = Activity(
      nombre: nombre,
      materia: materia,
      tipo: tipo,
      descripcion: _descripcionCtrl.text.trim(),
      prioridad: _prioridad,
      horasDedicadas: _horas,
      fechaLimite: _fecha,
    );
    try {
      await _activityRepo.insert(nueva);
      widget.onCreated();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear la tarea')),
      );
    }
  }

  void _mostrarMateriaRequerida({String? nombreFaltante}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Materia no registrada'),
        content: Text(
          nombreFaltante != null
              ? 'La materia "$nombreFaltante" no existe en tu lista de materias. Debes registrarla primero antes de crear tareas asociadas a ella.'
              : 'Debes registrar al menos una materia antes de crear tareas. Ve a "Mis materias" y agrega una.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime f) {
    const meses = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${f.day} ${meses[f.month - 1]} ${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Nueva tarea',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descripcionCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_subjects.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'No tienes materias registradas. Registra una en "Mis materias" antes de crear tareas.',
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _materiaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Materia',
                          border: OutlineInputBorder(),
                        ),
                        items: _subjects
                            .map((s) => DropdownMenuItem(
                                  value: s.nombre,
                                  child: Text(s.nombre),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _materiaSeleccionada = v),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _tipoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tipo (tarea, examen, proyecto, ...)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Prioridad', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: ['alta', 'media', 'baja'].map((p) {
                        return ChoiceChip(
                          label: Text(p),
                          selected: _prioridad == p,
                          onSelected: (_) => setState(() => _prioridad = p),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Horas: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        IconButton(
                          onPressed: _horas > 0 ? () => setState(() => _horas--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_horas'),
                        IconButton(
                          onPressed: () => setState(() => _horas++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Fecha: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Expanded(child: Text(_formatFecha(_fecha))),
                        TextButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Cambiar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _saving ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: (_saving || _subjects.isEmpty) ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Crear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
*/
