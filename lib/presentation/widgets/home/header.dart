import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildHeader() {
  //*E es dia de la semana (la candidad de e's es la extension del dia, tres e seria Lun para lunes y cuatro el nombre entero), d numero del dia, m mes(una M seria el numero,2 numero y un cero si es un digito, 3 mes abreviado y 4 nombre entero), y año
  final fechaActual = DateFormat(
    "EEEE, d 'de' MMMM 'del' y",
    'es_ES',
  ).format(DateTime.now());
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "¡Bienvenido de vuelta!",
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      Text(fechaActual, style: TextStyle(fontSize: 16)),
    ],
  );
}
