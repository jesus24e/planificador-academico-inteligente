import 'package:flutter/material.dart';

class CardsRow extends StatelessWidget {
  final int pendientes;
  final int vencenHoy;
  final int materiasActivas;

  const CardsRow({
    super.key,
    required this.pendientes,
    required this.vencenHoy,
    required this.materiasActivas,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _card("actividades\npendientes", '$pendientes')),
        const SizedBox(width: 12),
        Expanded(child: _card("vencen\nhoy", '$vencenHoy')),
        const SizedBox(width: 12),
        Expanded(child: _card("materias\nactivas", '$materiasActivas')),
      ],
    );
  }

  Widget _card(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.amberAccent,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, textAlign: TextAlign.center),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
