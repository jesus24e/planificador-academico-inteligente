import 'package:flutter/material.dart';
import 'tarea_item.dart';

class TareasTab extends StatefulWidget {
  const TareasTab({super.key});

  @override
  State<TareasTab> createState() => _TareasTabState();
}

class _TareasTabState extends State<TareasTab> {
  String _filtroTipo = 'Tipo';
  String _filtroMateria = 'Materia';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // *Subtítulo + botón
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestiona tus actividades',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // todo: Navigator.push → nueva tarea
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nueva tarea'),
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
          const SizedBox(height: 12),

          // *Filtros + buscador
          _buildFiltros(),
          const SizedBox(height: 16),

          // *Lista de tareas
          Expanded(
            child: ListView(
              children: [
                TareaItem(
                  tipo: "proyecto",
                  nombre:
                      "aplicacion de organizacion academica inteligente, proyecto final de la materia",
                  materia: "programacion movil",
                  fecha: "jueves 7 de mayo",
                  horasDia: "5",
                  prioridad: 1,
                ),
                TareaItem(
                  tipo: "examen",
                  nombre: "primer examen de bd2",
                  materia: "bases de datos 2",
                  fecha: "Martes 14 de abril",
                  horasDia: "2",
                  prioridad: 2,
                ),
                TareaItem(
                  tipo: "tarea",
                  nombre: "comentario de articulo 10",
                  materia: "redes de computadoras 2",
                  fecha: "Martes 12 de mayo",
                  horasDia: "2",
                  prioridad: 3,
                ),
                TareaItem(
                  tipo: "tarea",
                  nombre: "ejemplo de factura cfdi",
                  materia: "Habilidades directivas",
                  fecha: "miercoles 8 de abril",
                  horasDia: "1",
                  prioridad: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Column(
      children: [
        // *Fila 1: Buscador
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar tarea...',
            prefixIcon: const Icon(Icons.search, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),

        // *Fila 2: Dropdowns
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                valor: _filtroTipo,
                onChanged: (val) => setState(() => _filtroTipo = val!),
                items: ['Tipo', 'Examen', 'Tarea', 'Proyecto'],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdown(
                valor: _filtroMateria,
                onChanged: (val) => setState(() => _filtroMateria = val!),
                items: [
                  'Materia',
                  'Bases de datos 2',
                  'Programación móvil',
                  'Redes de computadoras',
                  'Habilidades directivas',
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String valor,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      onChanged: onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}
