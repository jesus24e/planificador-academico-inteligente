import 'package:flutter/material.dart';

class TareaItem extends StatelessWidget {
  final String tipo;
  final String materia;
  final String nombre;
  final String fecha;
  final String? horasDia;
  final int prioridad;

  const TareaItem({
    super.key,
    required this.tipo,
    required this.materia,
    required this.nombre,
    required this.fecha,
    this.horasDia,
    required this.prioridad,
  });

  Color get _colorPrioridad {
    switch (prioridad) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.amberAccent;
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8,horizontal: 4),
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

          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chips tipo y materia
                Row(
                  children: [
                    _buildMiniLabel(tipo),
                    const SizedBox(width: 6),
                    _buildMiniLabel(materia),
                  ],
                ),
                const SizedBox(height: 6),

                // Nombre
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),

                // Fecha + horas (horas es opcional)
                Text(
                  'vence: $fecha${horasDia != null ? ' │ $horasDia hrs/día' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // * Botón eliminar
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
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
      ),
    );
  }
}
