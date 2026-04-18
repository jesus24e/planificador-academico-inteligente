import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/ui/widgets/actividades/materias_tab.dart';
import 'package:planificador_academico_inteligente/ui/widgets/actividades/tareas_tab.dart';

class ActivitieScreen extends StatelessWidget {  // ← StatelessWidget, ya no StatefulWidget
  const ActivitieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(        // ← maneja todo automáticamente
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Tabs ─────────────────────────────
              TabBar(
                labelStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Mis materias'),
                  Tab(text: 'Mis tareas'),
                ],
              ),

              // ── Contenido ────────────────────────
              const Expanded(
                child: TabBarView(
                  children: [
                    MateriasTab(),
                    TareasTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}