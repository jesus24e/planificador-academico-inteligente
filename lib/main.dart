import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:planificador_academico_inteligente/core/simulations/actividades_sim.dart';
import 'package:planificador_academico_inteligente/data/database/database_helper.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);


  await initializeDateFormatting('es_ES',"");
  await DatabaseHelper.instance.database;
  await deleteAllActivities();
  await insertActivities();

  runApp(const MyApp());
}
