import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/aniadirTarea.dart';

class AgregarPrioridadDialog extends StatefulWidget {
  final VoidCallback onAgregada;

  const AgregarPrioridadDialog({super.key, required this.onAgregada});

  @override
  State<AgregarPrioridadDialog> createState() => _AgregarPrioridadDialogState();
}

class _AgregarPrioridadDialogState extends State<AgregarPrioridadDialog> {
  final ActivityRepository _repo = ActivityRepository();

  List<Activity> _disponibles = [];
  bool _cargando = true;
  int? _procesandoId;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final todas = await _repo.getAll();
      if (!mounted) return;
      setState(() {
        _disponibles = todas
            .where((a) =>
                a.id != null &&
                !a.completada &&
                a.prioridadEstado != Activity.prioridadEnLista)
            .toList();
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _disponibles = [];
        _cargando = false;
      });
    }
  }

  Future<void> _agregar(Activity activity) async {
    setState(() => _procesandoId = activity.id);
    try {
      await _repo.setPrioridadEstado(
        activity.id!,
        Activity.prioridadEnLista,
      );
      widget.onAgregada();
      await _cargar();
      if (mounted) setState(() => _procesandoId = null);
    } catch (_) {
      if (!mounted) return;
      setState(() => _procesandoId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo agregar la tarea")),
      );
    }
  }

  Future<void> _abrirNuevaTarea() async {
    await showDialog(
      context: context,
      builder: (_) => AniadirTareaDialog(onCreated: widget.onAgregada),
    );
    await _cargar();
  }

  String _formatFecha(DateTime f) {
    const meses = ['ene','feb','mar','abr','may','jun',
                    'jul','ago','sep','oct','nov','dic'];
    return '${f.day} ${meses[f.month - 1]} ${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Agrega la tarea"),
      content: SizedBox(
        width: double.maxFinite,
        child: _cargando
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : _buildContenido(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }

  Widget _buildContenido() {
    return ListView(
      shrinkWrap: true,
      children: [
        if (_disponibles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "No hay tareas disponibles para agregar",
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          )
        else
          ..._disponibles.map((a) {
            final procesando = _procesandoId == a.id;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(a.nombre),
              subtitle: Text(
                '${a.materia} · vence ${_formatFecha(a.fechaLimite)}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: procesando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_circle_outline),
              onTap: procesando ? null : () => _agregar(a),
            );
          }),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.add, color: Color(0xFF1E3A5F)),
          title: const Text(
            "Nueva tarea",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: _abrirNuevaTarea,
        ),
      ],
    );
  }
}
