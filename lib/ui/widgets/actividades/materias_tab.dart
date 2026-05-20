import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/data/repositories/subject_repository.dart';
import 'package:planificador_academico_inteligente/entities/subject.dart';
import 'materia_card.dart';
import 'subject_form_dialog.dart';

class MateriasTab extends StatefulWidget {
  const MateriasTab({super.key});

  @override
  State<MateriasTab> createState() => _MateriasTabState();
}

class _MateriasTabState extends State<MateriasTab> {
  final SubjectRepository _repo = SubjectRepository();

  List<Subject> _materias = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final materias = await _repo.getAll();
      if (!mounted) return;
      setState(() {
        _materias = materias;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _materias = [];
        _cargando = false;
      });
    }
  }

  Future<void> _abrirNuevaMateria() async {
    await showDialog(
      context: context,
      builder: (_) => const SubjectFormDialog(),
    );
    await _cargar();
  }

  Future<void> _abrirEditar(Subject materia) async {
    await showDialog(
      context: context,
      builder: (_) => SubjectFormDialog(subject: materia),
    );
    await _cargar();
  }

  Future<void> _eliminar(Subject materia) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text("¿Estás seguro de que quieres eliminar esta materia?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sí"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    if (materia.id == null) return;

    final tareas = await _repo.countTareasAsociadas(materia.nombre);
    if (tareas > 0) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(
            "No se puede eliminar esta materia porque tiene $tareas tarea(s) asociada(s). "
            "Elimina o reasigna esas tareas primero.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Entendido"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await _repo.delete(materia.id!);
      await _cargar();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo eliminar la materia")),
      );
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
                'Gestiona tus asignaturas',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              ElevatedButton.icon(
                onPressed: _abrirNuevaMateria,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nueva materia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildLista()),
        ],
      ),
    );
  }

  Widget _buildLista() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_materias.isEmpty) {
      return const Center(
        child: Text(
          "No hay materias registradas",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        itemCount: _materias.length,
        itemBuilder: (_, index) {
          final m = _materias[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MateriaCard(
              nombre: m.nombre,
              profesor: m.profesor,
              horario: m.horario,
              onEdit: () => _abrirEditar(m),
              onDelete: () => _eliminar(m),
            ),
          );
        },
      ),
    );
  }
}
