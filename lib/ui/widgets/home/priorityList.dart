import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/simulations/actividades_sim.dart';
import 'package:planificador_academico_inteligente/core/utils/activity_utils.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

final sortedList = sortByPriority(activityList);

Column buildPrioritiesList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.circular(12),
          color: const Color.fromARGB(255, 204, 204, 204),
        ),
        child: Text(
          "Lista de prioridades",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 8),

      SizedBox(
        height: 300,
        child: Expanded(
          child: ListView(
            children: [
              ...sortedList.map((a) => buildPriorityItem(a))
            ],
          ),
        ),
      ),
    ],
  );
}

Widget buildPriorityItem(Activity activity) {
  final colores = {
    'alta': Colors.red,
    'media': Colors.orange,
    'baja': Colors.green,
  };
  final color = colores[activity.prioridad] ?? Colors.grey;

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 6),
      ],
      border: Border(left: BorderSide(color: color, width: 3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                activity.tipo,
                style: TextStyle(fontSize: 11, color: color),
              ),
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
  );
}

String _formatFecha(DateTime fecha) {
  const dias = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];
  const meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  return '${dias[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]}';
}
