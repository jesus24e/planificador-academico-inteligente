import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/utils/activity_utils.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/ui/widgets/home/prioridad_detail_dialog.dart';

class PriorityList extends StatelessWidget {
  final List<Activity> actividades;
  final bool cargando;
  final VoidCallback onChanged;

  const PriorityList({
    super.key,
    required this.actividades,
    required this.cargando,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ordenadas = sortByPriority(actividades);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color.fromARGB(255, 204, 204, 204),
          ),
          child: const Text(
            "Lista de prioridades",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: cargando
              ? const Center(child: CircularProgressIndicator())
              : ordenadas.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay tareas en la lista de prioridades",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    )
                  : ListView(
                      children: ordenadas
                          .map((a) => _PriorityItem(
                                activity: a,
                                onChanged: onChanged,
                              ))
                          .toList(),
                    ),
        ),
      ],
    );
  }
}

class _PriorityItem extends StatelessWidget {
  final Activity activity;
  final VoidCallback onChanged;

  const _PriorityItem({required this.activity, required this.onChanged});

  static const _colores = {
    'alta': Colors.red,
    'media': Colors.orange,
    'baja': Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colores[activity.prioridad] ?? Colors.grey;

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) => PrioridadDetailDialog(
          activity: activity,
          onChanged: onChanged,
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  activity.tipo,
                  style: TextStyle(fontSize: 11, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  activity.materia,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              activity.nombre,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'vence: ${_formatFecha(activity.fechaLimite)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const Text('  |  ', style: TextStyle(color: Color(0xFF6B7280))),
                Text(
                  '${activity.horasDedicadas} hrs',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatFecha(DateTime fecha) {
  const dias = [
    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
  ];
  const meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  return '${dias[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]}';
}
