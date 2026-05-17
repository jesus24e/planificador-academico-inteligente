import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/utils/activity_utils.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/data/repositories/subject_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'tarea_item.dart';
import 'tarea_detail_dialog.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/aniadirTarea.dart';

class TareasTab extends StatefulWidget {
  const TareasTab({super.key});

  @override
  State<TareasTab> createState() => _TareasTabState();
}

class _TareasTabState extends State<TareasTab> {
  static const String _todosTipos = 'Tipo';
  static const String _todasMaterias = 'Materia';

  static const List<String> _tiposFijos = [
    _todosTipos,
    'Tarea',
    'Actividad',
    'Examen',
    'Proyecto',
  ];

  final ActivityRepository _activityRepo = ActivityRepository();
  final SubjectRepository _subjectRepo = SubjectRepository();

  String _filtroTipo = _todosTipos;
  String _filtroMateria = _todasMaterias;
  String _busqueda = '';

  List<Activity> _actividades = [];
  List<String> _tipos = _tiposFijos;
  List<String> _materias = [_todasMaterias];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final actividades = await _activityRepo.getAll();
      final subjects = await _subjectRepo.getAll();

      final materiasSet = <String>{};
      for (final a in actividades) {
        materiasSet.add(a.materia);
      }
      for (final s in subjects) {
        materiasSet.add(s.nombre);
      }

      final materiasOrdenadas = materiasSet.toList()..sort();

      if (!mounted) return;
      setState(() {
        _actividades = sortByPriority(actividades);
        _materias = [_todasMaterias, ...materiasOrdenadas];
        if (!_materias.contains(_filtroMateria)) _filtroMateria = _todasMaterias;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _actividades = [];
        _materias = [_todasMaterias];
        _loading = false;
      });
    }
  }

  List<Activity> get _actividadesFiltradas {
    return _actividades.where((a) {
      final pasaTipo = _filtroTipo == _todosTipos ||
          a.tipo.toLowerCase() == _filtroTipo.toLowerCase();
      final pasaMateria = _filtroMateria == _todasMaterias ||
          a.materia.toLowerCase() == _filtroMateria.toLowerCase();
      final pasaBusqueda = _busqueda.isEmpty ||
          a.nombre.toLowerCase().contains(_busqueda.toLowerCase());
      return pasaTipo && pasaMateria && pasaBusqueda;
    }).toList();
  }

  void _abrirDetalle(Activity activity) {
    showDialog(
      context: context,
      builder: (_) => TareaDetailDialog(
        activity: activity,
        onChanged: _cargar,
      ),
    );
  }

  void _abrirNuevaTarea() {
    showDialog(
      context: context,
      builder: (_) => AniadirTareaDialog(onCreated: _cargar),
    );
  }

  Future<void> _eliminar(Activity activity) async {
    if (activity.id == null) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${activity.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar == true) {
      await _activityRepo.delete(activity.id!);
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestiona tus actividades',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              ElevatedButton.icon(
                onPressed: _abrirNuevaTarea,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nueva tarea'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFiltros(),
          const SizedBox(height: 16),
          Expanded(child: _buildLista()),
        ],
      ),
    );
  }

  Widget _buildLista() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final filtradas = _actividadesFiltradas;
    if (filtradas.isEmpty) {
      return const Center(
        child: Text('No hay tareas que coincidan',
            style: TextStyle(color: Color(0xFF6B7280))),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        itemCount: filtradas.length,
        itemBuilder: (_, i) {
          final a = filtradas[i];
          return TareaItem(
            activity: a,
            onTap: () => _abrirDetalle(a),
            onDelete: () => _eliminar(a),
          );
        },
      ),
    );
  }

  Widget _buildFiltros() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar tarea...',
            prefixIcon: const Icon(Icons.search, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (v) => setState(() => _busqueda = v),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                valor: _filtroTipo,
                onChanged: (val) => setState(() => _filtroTipo = val ?? _todosTipos),
                items: _tipos,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdown(
                valor: _filtroMateria,
                onChanged: (val) => setState(() => _filtroMateria = val ?? _todasMaterias),
                items: _materias,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String valor,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(valor) ? valor : items.first,
      onChanged: onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis)))
          .toList(),
    );
  }
}
