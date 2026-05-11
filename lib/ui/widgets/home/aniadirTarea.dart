import 'package:flutter/material.dart';

class AniadirTareaDialog extends StatefulWidget {
  const AniadirTareaDialog({super.key});

  @override
  State<AniadirTareaDialog> createState() => _AniadirTareaDialogState();
}

class _AniadirTareaDialogState extends State<AniadirTareaDialog> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _materiaCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _horasCtrl = TextEditingController(text: "0");

  String _tipo = "tarea";
  String _prioridad = "media";
  DateTime _fechaLimite = DateTime.now();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _materiaCtrl.dispose();
    _descripcionCtrl.dispose();
    _horasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nueva tarea"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Nombre
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            const SizedBox(height: 10),

            // Materia
            TextField(
              controller: _materiaCtrl,
              decoration: const InputDecoration(labelText: "Materia"),
            ),
            const SizedBox(height: 10),

            // Descripción
            TextField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(labelText: "Descripción"),
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            // Tipo
            const Text("Tipo"),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "tarea",    child: Text("Tarea")),
                DropdownMenuItem(value: "examen",   child: Text("Examen")),
                DropdownMenuItem(value: "proyecto", child: Text("Proyecto")),
              ],
              onChanged: (value) => setState(() => _tipo = value!),
            ),
            const SizedBox(height: 14),

            // Prioridad
            const Text("Prioridad"),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _prioridad,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "alta",  child: Text("Alta")),
                DropdownMenuItem(value: "media", child: Text("Media")),
                DropdownMenuItem(value: "baja",  child: Text("Baja")),
              ],
              onChanged: (value) => setState(() => _prioridad = value!),
            ),
            const SizedBox(height: 14),

            // Horas dedicadas
            TextField(
              controller: _horasCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Horas dedicadas"),
            ),
            const SizedBox(height: 14),

            // Fecha límite
            const Text("Fecha límite"),
            const SizedBox(height: 6),
            MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                final DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: _fechaLimite,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (fecha != null) {
                  setState(() => _fechaLimite = fecha);
                }
              },
              child: Text(
                "Fecha límite: ${_fechaLimite.day}/${_fechaLimite.month}/${_fechaLimite.year}",
                style: const TextStyle(color: Colors.white),
              ),
            ),

          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            //  guardar datos
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}