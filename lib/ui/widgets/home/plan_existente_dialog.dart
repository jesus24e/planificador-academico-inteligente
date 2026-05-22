import 'package:flutter/material.dart';

enum PlanExistenteAccion { regenerar, cancelar, editar }

class PlanExistenteDialog extends StatelessWidget {
  const PlanExistenteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text(
        "¿Estás seguro que quieres generar otro plan? "
        "Parece que actualmente ya hay uno activo.",
      ),
      actionsOverflowButtonSpacing: 4,
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, PlanExistenteAccion.cancelar),
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, PlanExistenteAccion.editar),
          child: const Text("Editar"),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.pop(context, PlanExistenteAccion.regenerar),
          child: const Text("Sí"),
        ),
      ],
    );
  }
}
