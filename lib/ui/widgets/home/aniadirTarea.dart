import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/subject_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/subject.dart';

class AniadirTareaDialog extends StatefulWidget {
  final VoidCallback? onCreated;

  const AniadirTareaDialog({super.key, this.onCreated});

  @override
  State<AniadirTareaDialog> createState() => _AniadirTareaDialogState();
}

class _AniadirTareaDialogState extends State<AniadirTareaDialog> {
  static const String _opcionNuevaMateria = "__nueva_materia__";

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _horasCtrl = TextEditingController(text: "0");

  final ActivityRepository _activityRepo = ActivityRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();

  String _tipo = "tarea";
  String _prioridad = "media";
  DateTime _fechaLimite = DateTime.now();
  bool _guardando = false;

  List<Subject> _materias = [];
  String? _materiaSeleccionada;
  bool _cargandoMaterias = true;

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _horasCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarMaterias({String? seleccionar}) async {
    setState(() => _cargandoMaterias = true);
    try {
      final materias = await _subjectRepo.getAll();
      if (!mounted) return;
      setState(() {
        _materias = materias;
        if (seleccionar != null &&
            materias.any((m) => m.nombre == seleccionar)) {
          _materiaSeleccionada = seleccionar;
        } else if (_materiaSeleccionada == null ||
            !materias.any((m) => m.nombre == _materiaSeleccionada)) {
          _materiaSeleccionada =
              materias.isNotEmpty ? materias.first.nombre : null;
        }
        _cargandoMaterias = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _materias = [];
        _materiaSeleccionada = null;
        _cargandoMaterias = false;
      });
    }
  }

  Future<void> _abrirNuevaMateria() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Agregar nueva materia"),
        content: const Text("En desarrollo"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
    await _cargarMaterias();
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    final materia = _materiaSeleccionada;
    final descripcion = _descripcionCtrl.text.trim();
    final horas = int.tryParse(_horasCtrl.text.trim()) ?? 0;

    if (nombre.isEmpty || materia == null || materia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa el nombre y la materia")),
      );
      return;
    }

    if (horas < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las horas no pueden ser negativas")),
      );
      return;
    }

    setState(() => _guardando = true);

    final nueva = Activity(
      nombre: nombre,
      materia: materia,
      tipo: _tipo,
      descripcion: descripcion,
      prioridad: _prioridad,
      horasDedicadas: horas,
      fechaLimite: DateTime.utc(
        _fechaLimite.year,
        _fechaLimite.month,
        _fechaLimite.day,
      ),
    );

    try {
      await _activityRepo.insert(nueva);
      widget.onCreated?.call();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo guardar la tarea")),
      );
    }
  }

  Widget _buildSelectorMateria() {
    if (_cargandoMaterias) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final items = <DropdownMenuItem<String>>[
      ..._materias.map(
        (m) => DropdownMenuItem(value: m.nombre, child: Text(m.nombre)),
      ),
      const DropdownMenuItem(
        value: _opcionNuevaMateria,
        child: Row(
          children: [
            Icon(Icons.add, size: 16),
            SizedBox(width: 6),
            Text("Agregar nueva materia"),
          ],
        ),
      ),
    ];

    return DropdownButtonFormField<String>(
      initialValue: _materiaSeleccionada,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: "Materia",
        border: OutlineInputBorder(),
      ),
      hint: const Text("Selecciona una materia"),
      items: items,
      onChanged: (value) {
        if (value == _opcionNuevaMateria) {
          _abrirNuevaMateria();
        } else {
          setState(() => _materiaSeleccionada = value);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nueva tarea"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Nombre
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            const SizedBox(height: 14),

            // Materia
            const Text("Materia"),
            const SizedBox(height: 6),
            _buildSelectorMateria(),
            const SizedBox(height: 10),

            // Descripción
            TextField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(labelText: "Descripción"),
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            // Tipo
            const Text("Tipo"),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "tarea",     child: Text("Tarea")),
                DropdownMenuItem(value: "actividad", child: Text("Actividad")),
                DropdownMenuItem(value: "examen",    child: Text("Examen")),
                DropdownMenuItem(value: "proyecto",  child: Text("Proyecto")),
              ],
              onChanged: (value) => setState(() => _tipo = value!),
            ),
            const SizedBox(height: 14),

            // Prioridad
            const Text("Prioridad"),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _prioridad,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "alta",  child: Text("Alta")),
                DropdownMenuItem(value: "media", child: Text("Media")),
                DropdownMenuItem(value: "baja",  child: Text("Baja")),
              ],
              onChanged: (value) => setState(() => _prioridad = value!),
            ),
            const SizedBox(height: 14),

            // Horas dedicadas
            TextField(
              controller: _horasCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Horas dedicadas"),
            ),
            const SizedBox(height: 14),

            // Fecha límite
            const Text("Fecha límite"),
            const SizedBox(height: 6),
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                final DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _fechaLimite,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                  setState(() => _fechaLimite = fecha);
                }
              },
              child: Text(
                "Fecha límite: ${_fechaLimite.day}/${_fechaLimite.month}/${_fechaLimite.year}",
                style: const TextStyle(color: Colors.white),
              ),
            ),

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
              : const Text("Guardar"),
        ),
      ],
    );
  }
}
