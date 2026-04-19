import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

class TareaItem extends StatelessWidget {
  final Activity activity;

  const TareaItem({super.key, required this.activity});

  Color get _colorPrioridad {
    switch (activity.prioridad) {
      case 'alta': return Colors.redAccent;
      case 'media': return Colors.amberAccent;
      default: return Colors.greenAccent;
    }
  }

  String get _fechaFormateada {
    const meses = ['ene','feb','mar','abr','may','jun',
                    'jul','ago','sep','oct','nov','dic'];
    final fechaLim = activity.fechaLimite;
    return '${fechaLim.day} ${meses[fechaLim.month - 1]} ${fechaLim.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 70,
            decoration: BoxDecoration(
              color: _colorPrioridad,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildMiniLabel(activity.tipo),
                    const SizedBox(width: 6),
                    _buildMiniLabel(activity.materia),
                  ],
                ),
                const SizedBox(height: 6),
                Text(activity.nombre,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'vence: $_fechaFormateada${activity.horasDedicadas > 0 ? ' │ ${activity.horasDedicadas} hrs' : ''}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
    );
  }
}