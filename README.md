# planificador-academico-inteligente

Aplicacion movil desarrollada en Flutter para organizar actividades academicas como tareas, proyectos y examenes en una vista de calendario y un conjunto de pantallas de seguimiento.

## Descripcion

La app busca ayudar a estudiantes universitarios a visualizar su carga academica y sus fechas limite en un solo lugar. El proyecto ya cuenta con interfaz funcional, calendario interactivo y persistencia local con SQLite para actividades.

## Funcionalidades principales

- Registro y lectura de actividades academicas.
- Clasificacion por materia, tipo, prioridad y fecha limite.
- Visualizacion en calendario mensual con eventos por dia.
- Lista de actividades y widgets de resumen en la interfaz.
- Base de datos local SQLite inicializada al arrancar la app.

## Tecnologias

- Flutter
- Dart
- `sqflite`
- `path`
- `table_calendar`
- `intl`

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

## Estado actual

El proyecto ya no es solo un prototipo visual. Actualmente existe una capa de persistencia local para `Activity`, aunque todavia conviven partes con datos simulados.

- `CalendarScreen` ya obtiene sus eventos desde `ActivityRepository.getAll()`.
- Existe una base de datos SQLite local con una tabla `actividades`.
- El proyecto usa un `DAO` para encapsular el acceso SQL.
- El proyecto usa un `Repository` para exponer operaciones de datos a la UI.
- Todavia hay componentes que siguen leyendo mocks desde `core/simulations/actividades_sim.dart`, por ejemplo algunas listas y widgets del home.

## Documentacion tecnica

### Vision general

La app esta organizada en capas ligeras:

1. `entities`: modelos compartidos.
2. `data/database`: inicializacion de SQLite y acceso SQL.
3. `data/repositories`: capa intermedia que expone operaciones a la UI.
4. `core`: tema, utilidades y datos semilla/mock.
5. `ui`: pantallas, navegacion y widgets.

No es una Clean Architecture estricta, pero ya existe una separacion clara entre modelo, persistencia y presentacion.

### Estructura del proyecto

```text
planificador-academico-inteligente/
+-- lib/
|   +-- app.dart
|   +-- main.dart
|   +-- core/
|   |   +-- constants/
|   |   +-- simulations/
|   |   |   +-- actividades_sim.dart
|   |   +-- theme/
|   |   +-- utils/
|   +-- data/
|   |   +-- database/
|   |   |   +-- database_helper.dart
|   |   |   +-- dataAccessObject/
|   |   |       +-- activity_dao.dart
|   |   +-- repositories/
|   |       +-- activity_repository.dart
|   +-- entities/
|   |   +-- activity.dart
|   +-- ui/
|       +-- navigation/
|       +-- screens/
|       +-- widgets/
+-- test/
+-- pubspec.yaml
+-- README.md
```

### Modelo principal

#### `Activity`

Archivo: `lib/entities/activity.dart`

Representa una actividad academica y es el contrato comun entre base de datos, repositorio y UI.

| Campo | Tipo | Descripcion |
| --- | --- | --- |
| `id` | `int?` | Identificador opcional, asignado por SQLite. |
| `nombre` | `String` | Titulo de la actividad. |
| `materia` | `String` | Materia a la que pertenece. |
| `tipo` | `String` | Categoria, por ejemplo `tarea`, `examen` o `proyecto`. |
| `descripcion` | `String` | Descripcion adicional. |
| `prioridad` | `String` | Nivel de prioridad (`alta`, `media`, `baja`). |
| `horasDedicadas` | `int` | Tiempo estimado o registrado. |
| `fechaLimite` | `DateTime` | Fecha limite de la actividad. |

## Base de datos

### Como funciona la persistencia

La persistencia local se implementa con SQLite usando el paquete `sqflite`.

El flujo real es este:

```text
main.dart
  -> DatabaseHelper
  -> ActivityRepository
    -> ActivityDao
      -> tabla SQLite "actividades"
```

### `DatabaseHelper`

Archivo: `lib/data/database/database_helper.dart`

Su responsabilidad es:

- crear una unica instancia compartida de la base de datos
- construir la ruta fisica del archivo `planificador.db`
- abrir la base
- crear las tablas la primera vez

Puntos importantes:

- Usa un patron singleton con `DatabaseHelper.instance`.
- Guarda internamente el objeto `Database` en `_database`.
- Si la base ya esta abierta, la reutiliza.
- En `onCreate` crea la tabla `actividades`.

Tabla creada actualmente:

```sql
CREATE TABLE actividades (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  materia TEXT NOT NULL,
  tipo TEXT NOT NULL,
  descripcion TEXT DEFAULT '',
  prioridad TEXT NOT NULL,
  horas_dedicadas INTEGER DEFAULT 0,
  fecha_limite TEXT NOT NULL
)
```

### `ActivityDao`

Archivo: `lib/data/database/dataAccessObject/activity_dao.dart`

El `DAO` encapsula todas las operaciones SQL sobre la tabla `actividades`.

Funciones actuales:

- `getAll()`: obtiene todas las actividades.
- `getById(int id)`: obtiene una actividad por id.
- `getBySubject(String subject)`: filtra por materia.
- `insert(Activity activity)`: inserta un registro.
- `update(Activity activity)`: actualiza un registro existente.
- `deleteById(int id)`: elimina una actividad por id.
- `deleteAll()`: elimina todos los registros.

Ademas, el DAO contiene el mapeo entre el modelo Dart y la base:

- `_toMap(Activity activity)`: convierte `Activity` a `Map<String, dynamic>` para guardar en SQLite.
- `_fromMap(Map<String, dynamic>)`: reconstruye una instancia de `Activity` desde una fila de la base.

Un detalle importante es que `fechaLimite` se guarda como `String` con `toIso8601String()` y se recupera con `DateTime.parse(...)`.

### `ActivityRepository`

Archivo: `lib/data/repositories/activity_repository.dart`

El repositorio actua como capa intermedia entre la UI y el DAO.

Su funcion principal hoy es delegar las operaciones del `ActivityDao`:

- `getAll()`
- `getById(...)`
- `getBySubject(...)`
- `insert(...)`
- `update(...)`
- `delete(...)`
- `deleteAll()`

Aunque por ahora es una capa delgada, es util porque:

- evita que la UI conozca detalles SQL
- permite cambiar la fuente de datos mas adelante sin reescribir pantallas
- deja un punto claro para agregar validaciones o reglas de negocio futuras

## Inicializacion y carga de datos

### `main.dart`

Archivo: `lib/main.dart`

En el arranque de la app se hace lo siguiente:

1. Se inicializa Flutter con `WidgetsFlutterBinding.ensureInitialized()`.
2. Se fija la orientacion vertical.
3. Se inicializa la configuracion regional `es_ES`.
4. Se abre la base de datos con `DatabaseHelper.instance.database`.
5. Se eliminan todas las actividades existentes.
6. Se insertan actividades semilla.
7. Se ejecuta `runApp`.

Esto significa que actualmente la base se repuebla en cada arranque usando los datos de `core/simulations/actividades_sim.dart`.

### `core/simulations/actividades_sim.dart`

Este archivo sigue teniendo dos roles:

- contiene datos semilla (`activityList`)
- contiene un mapa por fecha (`mapDateActivity`) que aun usan algunas pantallas o widgets legacy

Ademas define:

- `insertActivities()`: inserta las actividades semilla usando `ActivityRepository`
- `deleteAllActivities()`: limpia la tabla antes de insertar

Importante: por esta razon, la base de datos actual no conserva cambios entre ejecuciones si `main.dart` sigue llamando a `deleteAllActivities()` y `insertActivities()`.

## Flujo de datos actual

### Flujo del calendario

El flujo nuevo del calendario mensual es:

```text
SQLite
  -> ActivityDao.getAll()
  -> ActivityRepository.getAll()
  -> CalendarScreen._loadActivities()
  -> Map<DateTime, List<Activity>>
  -> TableCalendar.eventLoader
  -> lista de ActivityCard
```

Detalle:

1. `CalendarScreen` crea una instancia de `ActivityRepository`.
2. En `initState()` llama `_loadActivities()`.
3. `_loadActivities()` ejecuta `getAll()`.
4. Las actividades obtenidas se agrupan por dia usando `fechaLimite`.
5. `eventLoader` consulta ese mapa para saber que eventos tiene cada fecha.
6. La lista inferior del calendario usa la misma fuente para mostrar los detalles del dia seleccionado.

Fragmento conceptual:

```dart
final actividades = await _activityRepository.getAll();

for (final actividad in actividades) {
  final key = DateTime.utc(
    actividad.fechaLimite.year,
    actividad.fechaLimite.month,
    actividad.fechaLimite.day,
  );
  eventosAgrupados.putIfAbsent(key, () => []).add(actividad);
}
```

### Flujo SQL de una actividad

```text
Activity
  -> ActivityRepository.insert(activity)
  -> ActivityDao.insert(activity)
  -> _toMap(activity)
  -> INSERT en SQLite
```

Y al leer:

```text
SELECT en SQLite
  -> Map<String, dynamic>
  -> ActivityDao._fromMap(...)
  -> Activity
  -> Repository
  -> UI
```

## Pantallas principales

### `CalendarScreen`

Archivo: `lib/ui/screens/calendario/calendar_screen.dart`

Responsabilidad actual:

- mostrar un calendario mensual
- cargar actividades desde `ActivityRepository`
- agruparlas por fecha
- mostrar los eventos del dia seleccionado

Ya no depende directamente de `mapDateActivity` para el `eventLoader`.

### `HomeScreen`

Archivo: `lib/ui/screens/home/home_screen.dart`

Sigue funcionando principalmente con mocks y helpers de `core/simulations`. Aun no esta conectado de forma completa al repositorio ni a la base local.

### `ActivitiesScreen`

Archivo: `lib/ui/screens/actividades/activities_screen.dart`

Agrupa las pestanas de materias y tareas. Parte de su contenido sigue siendo visual o basado en datos simulados.

### `SettingsScreen`

Archivo: `lib/ui/screens/ajustes/settings_screen.dart`

Gestiona ajustes locales de interfaz, pero esos cambios todavia no se persisten en base de datos ni en almacenamiento local.

## Dependencias

### Runtime

| Paquete | Uso actual |
| --- | --- |
| `flutter` | Base de toda la UI y del framework. |
| `table_calendar` | Calendarios en home y calendario mensual. |
| `intl` | Localizacion y formato de fechas. |
| `sqflite` | Persistencia SQLite local. |
| `path` | Construccion de la ruta del archivo de base de datos. |
| `provider` | Declarado, pero aun no integrado al flujo principal. |
| `cupertino_icons` | Iconografia base del scaffold Flutter. |

### Desarrollo

| Paquete | Uso actual |
| --- | --- |
| `flutter_test` | Pruebas de widgets. |
| `flutter_lints` | Reglas de analisis estatico. |

## Estado actual y limitaciones

- Ya existe persistencia local para actividades.
- El calendario mensual ya usa datos reales desde la base.
- La base se borra y repuebla en cada arranque de la app.
- Algunas pantallas todavia consumen mocks directamente.
- Aun no existe una capa de estado compartido con `provider`.
- No hay migraciones de base de datos ni multiples tablas.
- El test actual sigue siendo minimo.

## Siguientes mejoras recomendadas

1. Dejar de borrar y reinsertar datos en cada arranque.
2. Conectar `HomeScreen` y `TareasTab` al repositorio en lugar de usar mocks.
3. Agregar formularios reales para crear, editar y eliminar actividades.
4. Introducir manejo de estado compartido.
5. Separar datos semilla de datos de prueba para no mezclar entorno real con prototipo.

## Resumen

El proyecto ya dio un paso importante: paso de un prototipo totalmente basado en mocks a una app con persistencia local basica. La pieza clave nueva es la cadena `DatabaseHelper -> ActivityDao -> ActivityRepository -> CalendarScreen`, que permite leer actividades reales desde SQLite y mostrarlas en `TableCalendar`.
