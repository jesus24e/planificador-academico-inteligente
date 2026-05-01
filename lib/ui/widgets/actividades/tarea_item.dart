import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

class TareaItem extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TareaItem({
    super.key,
    required this.activity,
    this.onTap,
    this.onDelete,
  });

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
    final completada = activity.completada;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: completada ? const Color(0xFFF3F4F6) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
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
                        Flexible(child: _buildMiniLabel(activity.materia)),
                        if (completada) ...[
                          const SizedBox(width: 6),
                          _buildMiniLabel('completada', color: const Color(0xFFD1FAE5)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activity.nombre,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: completada ? TextDecoration.lineThrough : null,
                        color: completada ? const Color(0xFF6B7280) : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'vence: $_fechaFormateada${activity.horasDedicadas > 0 ? ' │ ${activity.horasDedicadas} hrs' : ''}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniLabel(String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
      ),
    );
  }
}
