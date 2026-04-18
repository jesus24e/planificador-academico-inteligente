import 'package:flutter/material.dart';
import 'materia_card.dart';

class MateriasTab extends StatelessWidget {
  const MateriasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // * Subtítulo + botón
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestiona tus asignaturas',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // *nueva materia
                },
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

          // *Grid de materias
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MateriaCard(
                  nombre: 'Bases de datos',
                  profesor: 'GALLO',
                  horario: 'Lun/Mié 10:00am',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
