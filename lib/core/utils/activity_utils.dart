import 'package:planificador_academico_inteligente/entities/activity.dart';

const _ordenPrioridad = {'alta': 0, 'media': 1, 'baja': 2};

List<Activity> sortByPriority(List<Activity> activities) {
  return [...activities]
    ..sort((a, b) =>
      (_ordenPrioridad[a.prioridad] ?? 3)
      .compareTo(_ordenPrioridad[b.prioridad] ?? 3));
}