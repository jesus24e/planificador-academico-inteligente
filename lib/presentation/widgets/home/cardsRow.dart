import 'package:flutter/material.dart';

Widget buildCardsRow() {
  return Row(
    children: [
      Expanded(child: buildCard("actividades\npendientes", "2")),
      const SizedBox(width: 12),
      Expanded(child: buildCard("vencen\nhoy", "0")),
      const SizedBox(width: 12),
      Expanded(child: buildCard("materias\nactivas", "4")),
    ],
  );
}

Widget buildCard(label, value) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.amberAccent,
    ),

    padding: EdgeInsets.all(12),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, textAlign: TextAlign.center),
        Text(value, textAlign: TextAlign.center),
      ],
    ),
  );
}
