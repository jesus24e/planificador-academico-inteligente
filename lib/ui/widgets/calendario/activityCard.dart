import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  Color _prioridadColor() {
    switch (activity.prioridad) {
      case 'alta': return Colors.red;
      case 'media': return Colors.orange;
      default: return Colors.green;
    }
  }

  String _formatFecha(DateTime fecha) {
    const meses = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 2)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: _prioridadColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activity.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 2, bottom: 8),
            child: Text(
              activity.materia,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Text(activity.descripcion, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _infoText('Tipo', activity.tipo),
              ),
              _infoText('Prioridad', activity.prioridad, color: _prioridadColor()),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _infoText('Horas estimadas', '${activity.horasDedicadas}h'),
              ),
              _infoText('Fecha límite', _formatFecha(activity.fechaLimite), color: Colors.orange[800]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoText(String label, String value, {Color? color}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Colors.grey),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}