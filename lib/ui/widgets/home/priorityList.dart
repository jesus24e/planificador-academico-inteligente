import 'package:flutter/material.dart';

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
              buildPriorityItem(
                tipo: "proyecto",
                nombre:
                    "aplicacion de organizacion academica inteligente, proyecto final de la materia",
                materia: "programacion movil",
                fechaLimite: "jueves 7 de mayo",
                horasDedicadas: "5",
                prioridad: 1,
              ),
              buildPriorityItem(
                tipo: "examen",
                nombre: "primer examen de bd2",
                materia: "bases de datos 2",
                fechaLimite: "Martes 14 de abril",
                horasDedicadas: "2",
                prioridad: 2,
              ),
              buildPriorityItem(
                tipo: "tarea",
                nombre: "comentario de articulo 10",
                materia: "redes de computadoras 2",
                fechaLimite: "Martes 12 de mayo",
                horasDedicadas: "2",
                prioridad: 3,
              ),
              buildPriorityItem(
                tipo: "tarea",
                nombre: "ejemplo de factura cfdi",
                materia: "Habilidades directivas",
                fechaLimite: "miercoles 8 de abril",
                horasDedicadas: "1",
                prioridad: 3,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Container buildPriorityItem({
  required String tipo,
  required String materia,
  required String nombre,
  required String fechaLimite,
  String? horasDedicadas,
  required int prioridad,
}) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: BoxBorder.all(color: Colors.black38),
    ),
    child: Row(
      children: [
        Container(color: _getBarColor(prioridad), width: 6, height: 64),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  //*etiqueta tipo de tarea -----------------------------------------------------------------
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: BoxBorder.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      tipo,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  //*----------------------------------------------------------------------------------------
                  const SizedBox(width: 10),
                  //*etiqueta materia -----------------------------------------------------------------------
                  Text(materia, style: TextStyle(fontWeight: FontWeight.bold)),
                  //*----------------------------------------------------------------------------------------
                ],
              ),
              const SizedBox(height: 18),
              //* etiqueta nombre de la tarea----------------------------------------------------------------
              Text(nombre),

              //*--------------------------------------------------------------------------------------------
              const SizedBox(height: 6),
              Row(
                children: [
                  //* etiqueta fecha limite de la tarea------------------------------------------------------
                  Text(
                    "vence: $fechaLimite",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 1,
                    color: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  //* etiqueta horas dedicadas a la tarea------------------------------------------------------
                  if (horasDedicadas != null)
                    Text(
                      "$horasDedicadas ${int.parse(horasDedicadas) > 1 ? 'hrs' : 'hr'}",
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Color _getBarColor(int prioridad) {
  if (prioridad == 1) {
    return Colors.redAccent;
  } else if (prioridad == 2) {
    return Colors.amberAccent;
  } else {
    return Colors.greenAccent;
  }
}
