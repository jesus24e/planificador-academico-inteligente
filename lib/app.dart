import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/core/theme/app_theme.dart';
import 'package:planificador_academico_inteligente/ui/navigation/main_scaffold.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: appNavigatorKey,
        title: "Planificador academico",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScaffold(),
      );
  }
}
