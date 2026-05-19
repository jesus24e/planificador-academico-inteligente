import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/ui/widgets/actividades/tarea_detail_dialog.dart';

class PrioridadDetailDialog extends StatelessWidget {
  final Activity activity;
  final VoidCallback onChanged;

  const PrioridadDetailDialog({
    super.key,
    required this.activity,
    required this.onChanged,
  });

  static const _azul = Color(0xFF1E3A5F);
  static const _gris = Color(0xFF6B7280);

  String _formatFecha(DateTime f) {
    const meses = ['enero','febrero','marzo','abril','mayo','junio','julio',
                    'agosto','septiembre','octubre','noviembre','diciembre'];
    return '${f.day} de ${meses[f.month - 1]} de ${f.year}';
  }

  Future<void> _concluir(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text("¿Has concluido esta tarea?"),
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

    if (activity.id != null) {
      try {
        await ActivityRepository().delete(activity.id!);
      } catch (_) {}
    }
    onChanged();
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _eliminarDePrioridad(BuildContext context) async {
    if (activity.id != null) {
      try {
        await ActivityRepository()
            .setPrioridadEstado(activity.id!, Activity.prioridadDescartada);
      } catch (_) {}
    }
    onChanged();
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _editar(BuildContext context) async {
    Navigator.pop(context);
    await showDialog(
      context: context,
      builder: (_) => TareaDetailDialog(
        activity: activity,
        onChanged: onChanged,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _gris,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(activity.nombre),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Materia", activity.materia),
            _infoRow("Tipo", activity.tipo),
            _infoRow("Prioridad", activity.prioridad),
            _infoRow("Horas", '${activity.horasDedicadas}'),
            _infoRow("Fecha límite", _formatFecha(activity.fechaLimite)),
            _infoRow("Estado", activity.completada ? "Completada" : "Pendiente"),
            if (activity.descripcion.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(activity.descripcion, style: const TextStyle(fontSize: 13)),
            ],
          ],
        ),
      ),
      actionsOverflowButtonSpacing: 4,
      actions: [
        TextButton(
          onPressed: () => _eliminarDePrioridad(context),
          child: const Text("Eliminar de prioridad"),
        ),
        TextButton(
          onPressed: () => _editar(context),
          child: const Text("Editar"),
        ),
        ElevatedButton(
          onPressed: () => _concluir(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _azul,
            foregroundColor: Colors.white,
          ),
          child: const Text("Concluir"),
        ),
      ],
    );
  }
}
