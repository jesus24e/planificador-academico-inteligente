import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/theme/app_theme.dart';
import 'package:planificador_academico_inteligente/presentation/navigation/main_scaffold.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Planificador academico",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScaffold(),
      );
    /*return MultiProvider(
      providers: [],
      child: MaterialApp(
        title: "Planificador academico",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScaffold(),
      ),
    );*/
  }
}
