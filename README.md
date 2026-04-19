# planificador-academico-inteligente

App movil desarrollada en Flutter que genera automaticamente planes de estudio personalizados para estudiantes universitarios, distribuyendo la carga academica segun dificultad, fechas limite y disponibilidad horaria.

## Descripcion

Esta aplicacion ayuda a los estudiantes a planificar su tiempo de estudio de forma inteligente, evitando la acumulacion de trabajo en los dias previos a evaluaciones y reduciendo el estres academico.

## Funcionalidades principales

- Registro de materias y evaluaciones
- Asignacion de nivel de dificultad y fecha limite
- Registro de disponibilidad horaria del estudiante
- Generacion automatica de plan de estudio
- Visualizacion en calendario
- Panel resumen de proximas evaluaciones

## Tecnologias

- Flutter
- Dart

## Instalacion

1. Clona el repositorio:

```bash
git clone https://github.com/jesus24c/planificador-academico-inteligente.git
```

2. Entra a la carpeta del proyecto:

```bash
cd planificador-academico-inteligente
```

3. Instala las dependencias:

```bash
flutter pub get
```

4. Ejecuta la aplicacion:

```bash
flutter run
```

## Documentacion tecnica

### Vision general

`planificador_academico_inteligente` es una aplicacion Flutter orientada a estudiantes universitarios. Su objetivo es centralizar materias, tareas, proyectos y examenes para que el usuario visualice su carga academica desde varias vistas: inicio, calendario, actividades y ajustes.

La idea de producto es generar planes de estudio personalizados en funcion de dificultad, fechas limite y disponibilidad horaria. Sin embargo, el estado actual del codigo corresponde mas a un prototipo funcional de interfaz que a un planificador inteligente completo:

- Ya existe una entidad principal (`Activity`) y datos simulados para tareas y eventos.
- Ya existen pantallas para resumen, calendario, listado de actividades y configuracion.
- Todavia no hay persistencia, backend, repositorios, casos de uso ni generacion automatica real de planes.
- Varias acciones de UI siguen marcadas como `TODO` o usan valores quemados.

En otras palabras: el proyecto ya define la experiencia base de la app, pero la logica "inteligente" aun no esta implementada en capas de dominio o datos.

### Estructura del proyecto

#### Vista rapida del arbol

```text
planificador-academico-inteligente/
+-- android/                    # Runner y configuracion nativa para Android
+-- ios/                        # Runner y configuracion nativa para iOS
+-- linux/                      # Runner y build nativo para Linux
+-- macos/                      # Runner y build nativo para macOS
+-- web/                        # Entrada web (index, manifest, iconos)
+-- windows/                    # Runner y build nativo para Windows
+-- build/                      # Salida generada por compilaciones
+-- .dart_tool/                 # Archivos internos del toolchain de Dart/Flutter
+-- lib/
|   +-- app.dart                # Configura MaterialApp, tema y pantalla raiz
|   +-- main.dart               # Punto de entrada real de la aplicacion
|   +-- core/
|   |   +-- constants/
|   |   |   +-- app_colors.dart # Paleta central de colores
|   |   +-- simulations/
|   |   |   +-- actividades_sim.dart
|   |   |                         # Datos mock de actividades y calendario
|   |   +-- theme/
|   |   |   +-- app_theme.dart  # ThemeData global de Flutter
|   |   +-- utils/
|   |       +-- activity_utils.dart
|   |                         # Utilidades de ordenamiento para actividades
|   +-- entities/
|   |   +-- activity.dart      # Modelo principal compartido
|   +-- ui/
|       +-- navigation/
|       |   +-- main_scaffold.dart
|       |                         # Bottom navigation y orquestacion de pantallas
|       +-- screens/
|       |   +-- actividades/
|       |   |   +-- activities_screen.dart
|       |   +-- ajustes/
|       |   |   +-- settings_screen.dart
|       |   +-- calendario/
|       |   |   +-- calendar_screen.dart
|       |   +-- home/
|       |       +-- home_screen.dart
|       +-- widgets/
|           +-- actividades/
|           |   +-- materia_card.dart
|           |   +-- materias_tab.dart
|           |   +-- tarea_item.dart
|           |   +-- tareas_tab.dart
|           +-- calendario/
|           |   +-- activityCard.dart
|           +-- home/
|               +-- cardsRow.dart
|               +-- header.dart
|               +-- priorityList.dart
+-- test/
|   +-- widget_test.dart        # Smoke test basico
+-- pubspec.yaml                # Dependencias y metadatos del paquete
+-- pubspec.lock                # Versiones resueltas de dependencias
+-- analysis_options.yaml       # Reglas del analizador y lints
+-- README.md                   # Documento principal del proyecto
```

#### Carpetas de primer nivel

##### `lib/`

Contiene todo el codigo Dart propio de la aplicacion. La mayor parte de la logica real del proyecto esta aqui.

##### `lib/core/`

Agrupa piezas transversales reutilizables:

- `constants/`: valores globales estaticos, en este caso colores.
- `simulations/`: fuentes de datos mock usadas como sustituto temporal de base de datos o API.
- `theme/`: configuracion visual global.
- `utils/`: funciones auxiliares que no pertenecen a un widget concreto.

##### `lib/entities/`

Define los modelos compartidos por varias pantallas. Hoy solo existe `Activity`, que actua como contrato comun entre calendario, home y listas de tareas.

##### `lib/ui/`

Agrupa toda la capa de presentacion:

- `navigation/`: widget raiz de navegacion interna.
- `screens/`: pantallas completas que ocupan una seccion de la app.
- `widgets/`: componentes reutilizables usados dentro de las pantallas.

##### `test/`

Contiene pruebas automatizadas. En el estado actual solo hay un smoke test que monta `MyApp`, por lo que la cobertura funcional es minima.

##### `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/`

Son los runners de plataforma generados por Flutter. Su responsabilidad principal es empaquetar y lanzar la app en cada entorno. En la revision actual no contienen logica de negocio de la aplicacion; se comportan como scaffolding multiplataforma estandar.

##### `build/` y `.dart_tool/`

Son carpetas generadas automaticamente por Flutter y Dart. No se consideran parte de la arquitectura funcional del proyecto.

#### Archivos raiz

##### `pubspec.yaml`

Declara el nombre del paquete, version, SDK minimo, dependencias de runtime y dependencias de desarrollo. Tambien activa `uses-material-design`.

##### `pubspec.lock`

Congela versiones exactas de las dependencias instaladas para reproducibilidad local.

##### `analysis_options.yaml`

Importa las reglas de `flutter_lints`, lo que ayuda a mantener estilo y buenas practicas basicas.

##### `README.md`

Ahora actua como documento unico del proyecto: presentacion funcional al inicio y documentacion tecnica mas abajo.

### Arquitectura identificada

#### Patron real del proyecto

El proyecto no implementa Clean Architecture, MVC o MVVM de forma estricta. Lo que existe hoy se parece mas a una arquitectura por capas ligeras con organizacion por responsabilidad:

1. `entities`: modelo compartido.
2. `core`: configuracion, mocks, utilidades y tema.
3. `ui/navigation`: entrada a la navegacion de pantallas.
4. `ui/screens`: contenedores de cada vista.
5. `ui/widgets`: componentes visuales reutilizables.

Es una arquitectura sencilla y comun en prototipos Flutter: la UI consume directamente datos mock y utilidades sin pasar por servicios, controladores, providers activos o repositorios.

#### Como interactuan las capas

```text
main.dart
  -> app.dart
    -> ui/navigation/main_scaffold.dart
      -> ui/screens/*
        -> ui/widgets/*

entities/activity.dart
  -> core/simulations/actividades_sim.dart
  -> core/utils/activity_utils.dart
  -> widgets y screens que renderizan actividades
```

#### Observaciones importantes

- La entidad `Activity` es el centro de la informacion funcional.
- `core/simulations/actividades_sim.dart` actua como fuente de datos temporal.
- Las pantallas leen esos mocks de forma directa.
- `provider` esta declarado en `pubspec.yaml`, pero no se usa realmente; en `app.dart` hay un `MultiProvider` comentado, lo que sugiere una posible evolucion futura.
- La capa de configuracion (`SettingsScreen`) guarda su estado solo en memoria del widget; no lo persiste ni lo comparte con otras pantallas.

### Archivos clave

Esta seccion se centra en los archivos que estructuran la app o concentran comportamiento reutilizable.

#### Arranque y configuracion global

##### `lib/main.dart`

- Responsabilidad: punto de entrada; inicializa Flutter, bloquea la orientacion en vertical, prepara localizacion de fechas en espanol y ejecuta `MyApp`.
- Importa:
  - `flutter/material.dart`: infraestructura base de widgets.
  - `flutter/services.dart`: `SystemChrome` y orientacion.
  - `intl/date_symbol_data_local.dart`: soporte de formato de fechas en `es_ES`.
  - `app.dart`: widget raiz de la app.
- Dependen de el: nadie dentro de `lib`; es el archivo que lanza todo desde el runtime.

##### `lib/app.dart`

- Responsabilidad: define `MyApp`, crea `MaterialApp`, aplica tema global y establece `MainScaffold` como `home`.
- Importa:
  - `flutter/material.dart`: `StatelessWidget` y `MaterialApp`.
  - `core/theme/app_theme.dart`: tema visual global.
  - `ui/navigation/main_scaffold.dart`: contenedor principal con navegacion.
- Dependen de el:
  - `lib/main.dart`
  - `test/widget_test.dart`

##### `lib/core/theme/app_theme.dart`

- Responsabilidad: construye `ThemeData` centralizado con colores, tipografia, cards, botones y bottom navigation.
- Importa:
  - `flutter/material.dart`: `ThemeData`, `ColorScheme`, `TextTheme`, etc.
  - `../constants/app_colors.dart`: paleta reutilizable.
- Dependen de el:
  - `lib/app.dart`

##### `lib/core/constants/app_colors.dart`

- Responsabilidad: declarar una paleta semantica para fondos, texto, estados y tarjetas del home.
- Importa:
  - `flutter/material.dart`: tipo `Color`.
- Dependen de el:
  - `lib/core/theme/app_theme.dart`

#### Navegacion

##### `lib/ui/navigation/main_scaffold.dart`

- Responsabilidad: mantener el indice actual de la navegacion inferior y renderizar una pantalla por pestana usando `IndexedStack`.
- Importa:
  - `flutter/material.dart`: `Scaffold`, `BottomNavigationBar`, `StatefulWidget`.
  - `activities_screen.dart`, `settings_screen.dart`, `calendar_screen.dart`, `home_screen.dart`: las cuatro vistas principales.
- Dependen de el:
  - `lib/app.dart`

El uso de `IndexedStack` es relevante: conserva el estado interno de cada pantalla al cambiar de tab.

#### Modelo y fuente de datos

##### `lib/entities/activity.dart`

- Responsabilidad: definir la estructura de una actividad academica.
- Importa: nada; es un modelo puro.
- Dependen de el:
  - `lib/core/simulations/actividades_sim.dart`
  - `lib/core/utils/activity_utils.dart`
  - `lib/ui/screens/home/home_screen.dart`
  - `lib/ui/screens/calendario/calendar_screen.dart`
  - `lib/ui/widgets/home/priorityList.dart`
  - `lib/ui/widgets/calendario/activityCard.dart`
  - `lib/ui/widgets/actividades/tarea_item.dart`

##### `lib/core/simulations/actividades_sim.dart`

- Responsabilidad: simular datos de actividades en dos formatos:
  - `mapDateActivity`: calendario por fecha.
  - `activityList`: lista plana para vistas de tareas y prioridades.
- Importa:
  - `entities/activity.dart`: para instanciar el modelo.
- Dependen de el:
  - `lib/ui/screens/home/home_screen.dart`
  - `lib/ui/screens/calendario/calendar_screen.dart`
  - `lib/ui/widgets/home/priorityList.dart`
  - `lib/ui/widgets/actividades/tareas_tab.dart`

##### `lib/core/utils/activity_utils.dart`

- Responsabilidad: ordenar listas de `Activity` por prioridad (`alta`, `media`, `baja`).
- Importa:
  - `entities/activity.dart`: tipo de entrada y salida.
- Dependen de el:
  - `lib/ui/widgets/home/priorityList.dart`
  - `lib/ui/widgets/actividades/tareas_tab.dart`

#### Pantallas principales

##### `lib/ui/screens/home/home_screen.dart`

- Responsabilidad: mostrar el dashboard principal con encabezado, mini calendario de dos semanas, resumen numerico, lista de prioridades y boton para agregar tarea.
- Importa:
  - `flutter/material.dart`: estructura de UI.
  - `core/simulations/actividades_sim.dart`: mapa de eventos para el calendario.
  - `entities/activity.dart`: tipo de los eventos.
  - `ui/widgets/home/cardsRow.dart`: tarjetas resumen.
  - `ui/widgets/home/header.dart`: encabezado con saludo y fecha.
  - `ui/widgets/home/priorityList.dart`: lista priorizada.
  - `table_calendar/table_calendar.dart`: calendario semanal.
- Dependen de el:
  - `lib/ui/navigation/main_scaffold.dart`

##### `lib/ui/screens/calendario/calendar_screen.dart`

- Responsabilidad: mostrar el calendario mensual y, debajo, la lista de eventos del dia seleccionado.
- Importa:
  - `flutter/material.dart`: widgets base.
  - `core/simulations/actividades_sim.dart`: mapa de actividades por fecha.
  - `entities/activity.dart`: tipo de los eventos.
  - `ui/widgets/calendario/activityCard.dart`: tarjeta visual por actividad.
  - `table_calendar/table_calendar.dart`: calendario mensual interactivo.
- Dependen de el:
  - `lib/ui/navigation/main_scaffold.dart`

##### `lib/ui/screens/actividades/activities_screen.dart`

- Responsabilidad: componer la seccion de actividades con dos pestanas: materias y tareas.
- Importa:
  - `flutter/material.dart`: `DefaultTabController`, `TabBar`, `TabBarView`.
  - `ui/widgets/actividades/materias_tab.dart`: tab de materias.
  - `ui/widgets/actividades/tareas_tab.dart`: tab de tareas.
- Dependen de el:
  - `lib/ui/navigation/main_scaffold.dart`

##### `lib/ui/screens/ajustes/settings_screen.dart`

- Responsabilidad: capturar preferencias locales de estudio y notificaciones.
- Importa:
  - `flutter/material.dart`: formulario visual, switches, dropdown y `showTimePicker`.
- Dependen de el:
  - `lib/ui/navigation/main_scaffold.dart`

#### Widgets reutilizables

##### `lib/ui/widgets/home/header.dart`

- Responsabilidad: mostrar saludo y fecha actual en espanol.
- Importa:
  - `flutter/material.dart`: texto y layout.
  - `intl/intl.dart`: formateo de fecha localizado.
- Dependen de el:
  - `lib/ui/screens/home/home_screen.dart`

##### `lib/ui/widgets/home/cardsRow.dart`

- Responsabilidad: renderizar tres tarjetas resumen con metricas del home.
- Importa:
  - `flutter/material.dart`: contenedores y texto.
- Dependen de el:
  - `lib/ui/screens/home/home_screen.dart`

Nota: los valores actuales (`2`, `0`, `4`) estan hardcodeados.

##### `lib/ui/widgets/home/priorityList.dart`

- Responsabilidad: mostrar una lista de actividades ordenadas por prioridad.
- Importa:
  - `flutter/material.dart`: UI base.
  - `core/simulations/actividades_sim.dart`: fuente mock.
  - `core/utils/activity_utils.dart`: ordenamiento.
  - `entities/activity.dart`: tipo de cada item.
- Dependen de el:
  - `lib/ui/screens/home/home_screen.dart`

##### `lib/ui/widgets/calendario/activityCard.dart`

- Responsabilidad: renderizar el detalle visual de una `Activity` dentro del calendario.
- Importa:
  - `flutter/material.dart`: UI base.
  - `entities/activity.dart`: datos a mostrar.
- Dependen de el:
  - `lib/ui/screens/calendario/calendar_screen.dart`

##### `lib/ui/widgets/actividades/materias_tab.dart`

- Responsabilidad: renderizar la pestana de materias dentro de `ActivitiesScreen`.
- Importa:
  - `flutter/material.dart`: layout y boton.
  - `materia_card.dart`: tarjeta individual de materia.
- Dependen de el:
  - `lib/ui/screens/actividades/activities_screen.dart`

##### `lib/ui/widgets/actividades/materia_card.dart`

- Responsabilidad: mostrar nombre, profesor, horario y acciones basicas de una materia.
- Importa:
  - `flutter/material.dart`: estructura visual e iconos.
- Dependen de el:
  - `lib/ui/widgets/actividades/materias_tab.dart`

##### `lib/ui/widgets/actividades/tareas_tab.dart`

- Responsabilidad: mostrar buscador, filtros y listado de actividades.
- Importa:
  - `flutter/material.dart`: inputs, dropdowns y layout.
  - `core/simulations/actividades_sim.dart`: lista mock.
  - `core/utils/activity_utils.dart`: ordenamiento por prioridad.
  - `tarea_item.dart`: tarjeta individual de tarea.
- Dependen de el:
  - `lib/ui/screens/actividades/activities_screen.dart`

##### `lib/ui/widgets/actividades/tarea_item.dart`

- Responsabilidad: representar una actividad resumida dentro del listado de tareas.
- Importa:
  - `flutter/material.dart`: UI base.
  - `entities/activity.dart`: datos que se renderizan.
- Dependen de el:
  - `lib/ui/widgets/actividades/tareas_tab.dart`

#### Otros archivos relevantes

##### `test/widget_test.dart`

- Responsabilidad: validar que `MyApp` puede montarse en un entorno de prueba.
- Importa:
  - `flutter_test/flutter_test.dart`: framework de testing.
  - `app.dart`: widget raiz a probar.
- Dependen de el: nadie; se ejecuta desde `flutter test`.

### Flujo de datos

El flujo actual es directo porque no existe una capa intermedia de estado global.

#### Flujo 1: datos del calendario

```text
core/simulations/actividades_sim.dart
  -> mapDateActivity
  -> CalendarScreen.initState()
  -> TableCalendar.eventLoader
  -> _buildEventList()
  -> ActivityCard(activity: ...)
```

Detalle:

1. `actividades_sim.dart` define `mapDateActivity` como `Map<DateTime, List<Activity>>`.
2. `CalendarScreen` copia ese mapa a `eventosCalendario` en `initState`.
3. `TableCalendar` llama a `_getEventosDelDia(day)` para saber si una fecha tiene eventos.
4. Cuando el usuario selecciona un dia, `_selectedDay` cambia con `setState`.
5. `_buildEventList()` toma la fecha seleccionada y crea una lista de `ActivityCard`.

Fragmento simplificado:

```dart
List<Activity> _getEventosDelDia(DateTime day) {
  final key = DateTime.utc(day.year, day.month, day.day);
  return eventosCalendario[key] ?? [];
}
```

#### Flujo 2: prioridades del home

```text
core/simulations/actividades_sim.dart
  -> activityList
  -> core/utils/activity_utils.dart
  -> sortByPriority(activityList)
  -> buildPrioritiesList()
  -> buildPriorityItem(activity)
```

Detalle:

1. `activityList` contiene una lista plana de actividades.
2. `sortByPriority` crea una copia ordenada segun el mapa interno `_ordenPrioridad`.
3. `priorityList.dart` calcula `sortedList`.
4. `HomeScreen` llama `buildPrioritiesList()`.
5. Cada actividad se representa como un bloque con color lateral segun prioridad.

#### Flujo 3: listado de tareas

```text
activityList
  -> TareasTab.sortedList
  -> ListView
  -> TareaItem(activity: e)
```

`TareasTab` reutiliza exactamente la misma fuente mock del home, pero cambia la presentacion: anade buscador y filtros visuales antes de renderizar cada `TareaItem`.

#### Flujo 4: dashboard de inicio

`HomeScreen` combina tres fuentes de contenido:

- `buildHeader()`: fecha actual y saludo.
- `mapDateActivity`: alimenta el calendario de dos semanas.
- `buildCardsRow()` y `buildPrioritiesList()`: resumen y lista priorizada.

Esto significa que el home funciona como una pantalla compuesta: no posee una sola fuente de datos, sino varias piezas conectadas desde mocks y helpers.

### Catalogo de widgets

#### Pantallas

| Widget | Tipo | Props publicas | Donde se usa | Comentario |
| --- | --- | --- | --- | --- |
| `MyApp` | `StatelessWidget` | `key` | `main.dart`, `widget_test.dart` | Configura `MaterialApp`. |
| `MainScaffold` | `StatefulWidget` | `key` | `app.dart` | Navegacion inferior principal. |
| `HomeScreen` | `StatefulWidget` | `key` | `MainScaffold` | Dashboard principal. |
| `CalendarScreen` | `StatefulWidget` | `key` | `MainScaffold` | Calendario mensual con eventos. |
| `ActivitieScreen` | `StatelessWidget` | `key` | `MainScaffold` | Contenedor con tabs de materias y tareas. |
| `SettingsScreen` | `StatefulWidget` | `key` | `MainScaffold` | Ajustes locales del usuario. |

#### Widgets reutilizables por funcionalidad

| Widget o helper | Tipo | Props publicas | Donde se usa | Comentario |
| --- | --- | --- | --- | --- |
| `ActivityCard` | `StatelessWidget` | `activity` (`Activity`) | `CalendarScreen` | Muestra detalle completo de una actividad. |
| `MateriasTab` | `StatelessWidget` | `key` | `ActivitieScreen` | Pestana de materias. |
| `MateriaCard` | `StatelessWidget` | `nombre`, `profesor`, `horario` | `MateriasTab` | Tarjeta individual de materia. |
| `TareasTab` | `StatefulWidget` | `key` | `ActivitieScreen` | Pestana de tareas con filtros y buscador. |
| `TareaItem` | `StatelessWidget` | `activity` (`Activity`) | `TareasTab` | Item resumido de actividad. |
| `buildHeader()` | funcion que retorna `Widget` | ninguna | `HomeScreen` | Encabezado del home. |
| `buildCardsRow()` | funcion que retorna `Widget` | ninguna | `HomeScreen` | Fila de metricas resumen. |
| `buildCard()` | helper interno | `label`, `value` | `cardsRow.dart` | Constructor visual de cada tarjeta resumen. |
| `buildPrioritiesList()` | funcion que retorna `Column` | ninguna | `HomeScreen` | Lista de prioridades. |
| `buildPriorityItem()` | helper interno | `activity` (`Activity`) | `priorityList.dart` | Item individual de prioridad. |

#### Builders privados dentro de pantallas

No son widgets reutilizables globales, pero conviene conocerlos porque concentran bastante UI:

- `HomeScreen`: `_buildWeekcalendar()`, `buildAddTaskBtn()`, `_getEventosDelDia()`
- `CalendarScreen`: `_buildMonthCalendar()`, `_buildEventList()`, `_getEventosDelDia()`
- `TareasTab`: `_buildFiltros()`, `_buildDropdown()`
- `SettingsScreen`: `_titulo()`, `_seccion()`, `_horasEstudio()`, `_diasDisponibles()`, `_horarioPreferente()`, `_toggle()`, `_horaNotificaciones()`

### Entidades y modelos

#### `Activity`

Archivo: `lib/entities/activity.dart`

| Campo | Tipo | Obligatorio | Descripcion |
| --- | --- | --- | --- |
| `nombre` | `String` | si | Titulo o nombre corto de la actividad. |
| `materia` | `String` | si | Asignatura a la que pertenece. |
| `tipo` | `String` | si | Categoria como `tarea`, `examen` o `proyecto`. |
| `descripcion` | `String` | no | Texto descriptivo adicional. Default: `""`. |
| `prioridad` | `String` | si | Nivel de prioridad. El proyecto asume `alta`, `media` o `baja`. |
| `horasDedicadas` | `int` | no | Horas estimadas o registradas. Default: `0`. |
| `fechaLimite` | `DateTime` | si | Fecha tope de entrega o evaluacion. |

#### Rol del modelo en la app

`Activity` funciona como contrato transversal:

- alimenta calendarios,
- se ordena por prioridad,
- se transforma en tarjetas de detalle,
- se transforma en items resumidos,
- y actua como unica "entidad de dominio" real del proyecto actual.

### Dependencias

#### Dependencias de runtime

| Paquete | Para que sirve | Donde se usa |
| --- | --- | --- |
| `flutter` | SDK principal para widgets, rendering, Material, estado local y servicios del framework. | En todos los archivos de UI y configuracion. |
| `cupertino_icons` | Paquete de iconos estilo iOS. | No aparece usado directamente en el codigo revisado; probablemente quedo del scaffold inicial de Flutter. |
| `provider` | Libreria de gestion de estado y DI ligera. | No se usa activamente. En `app.dart` existe un `MultiProvider` comentado, senal de que se penso como parte de una evolucion futura. |
| `table_calendar` | Calendario interactivo reutilizable para Flutter. | `lib/ui/screens/home/home_screen.dart` y `lib/ui/screens/calendario/calendar_screen.dart`. |
| `intl` | Formateo e internacionalizacion de fechas. | `lib/main.dart` para `initializeDateFormatting` y `lib/ui/widgets/home/header.dart` para `DateFormat`. |

#### Dependencias de desarrollo

| Paquete | Para que sirve | Donde se usa |
| --- | --- | --- |
| `flutter_test` | Framework oficial de pruebas para widgets y utilidades de testing. | `test/widget_test.dart`. |
| `flutter_lints` | Reglas de estilo y buenas practicas recomendadas por Flutter. | `analysis_options.yaml`. |

### Relacion entre pantallas y componentes

#### Navegacion principal

`MainScaffold` monta cuatro pantallas en este orden:

1. `CalendarScreen`
2. `ActivitieScreen`
3. `HomeScreen`
4. `SettingsScreen`

El indice inicial es `2`, por lo que la app abre en `HomeScreen`.

#### Relaciones mas importantes

- `HomeScreen` depende de `header.dart`, `cardsRow.dart` y `priorityList.dart`.
- `CalendarScreen` depende de `ActivityCard`.
- `ActivitieScreen` depende de `MateriasTab` y `TareasTab`.
- `MateriasTab` depende de `MateriaCard`.
- `TareasTab` depende de `TareaItem`.
- Home, calendario y tareas dependen de los mocks de `actividades_sim.dart`.

### Estado actual y notas para nuevos desarrolladores

Estas observaciones ayudan a entender rapidamente que partes son definitivas y cuales aun son temporales:

- La app usa datos simulados; no existe almacenamiento local ni remoto.
- `cardsRow.dart` usa contadores fijos, no calculados desde `activityList`.
- `TareasTab` muestra buscador y filtros, pero actualmente no filtra los datos.
- `MateriasTab` renderiza 5 tarjetas iguales con informacion hardcodeada.
- `SettingsScreen` mantiene preferencias solo mientras el widget vive en memoria.
- En `HomeScreen`, el boton "Anadir tarea" aun no ejecuta una accion real.
- `provider` esta listo para integrarse, pero todavia no forma parte del flujo.
- El test actual solo valida que la app pueda montarse; no cubre flujos funcionales.

### Sugerencias de evolucion arquitectonica

Si el proyecto va a crecer, la evolucion mas natural seria:

1. Sustituir `core/simulations` por una capa de datos real.
2. Introducir un estado compartido con `provider` o similar.
3. Separar logica de negocio de widgets, por ejemplo con controladores o view models.
4. Convertir metricas y filtros hardcodeados en calculos reales sobre `Activity`.
5. Persistir ajustes y actividades con base local o backend.

### Resumen ejecutivo

El proyecto ya tiene una base visual bien separada por pantallas y widgets, con una entidad comun (`Activity`) y dos vistas fuertes sobre la misma informacion: calendario y listados. La arquitectura actual es simple, directa y adecuada para prototipado rapido. Su siguiente salto de madurez no pasa por mas UI, sino por introducir una fuente de datos real, estado compartido y reglas de negocio para convertir el prototipo en un planificador academico verdaderamente inteligente.
