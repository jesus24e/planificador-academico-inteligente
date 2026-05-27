import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planificador_academico_inteligente/data/repositories/study_session_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';
import 'package:planificador_academico_inteligente/entities/study_session.dart';

class ContadorSesionDialog extends StatefulWidget {
  final StudySession session;
  final Activity? actividad;
  final int? indiceActual;
  final int? totalSesiones;
  final VoidCallback onSesionCompletada;

  const ContadorSesionDialog({
    super.key,
    required this.session,
    required this.actividad,
    required this.onSesionCompletada,
    this.indiceActual,
    this.totalSesiones,
  });

  @override
  State<ContadorSesionDialog> createState() => _ContadorSesionDialogState();
}

class _ContadorSesionDialogState extends State<ContadorSesionDialog> {
  static const int _umbralFinalizarSegundos = 20 * 60;

  final StudySessionRepository _sessionRepo = StudySessionRepository();

  late int _segundosTotales;
  late int _segundosRestantes;
  Timer? _timer;
  bool _iniciado = false;
  bool _pausado = false;
  bool _finalizado = false;
  int _segundosTranscurridos = 0;

  @override
  void initState() {
    super.initState();
    final mins = _toMin(widget.session.horaFin) -
        _toMin(widget.session.horaInicio);
    _segundosTotales = mins * 60;
    _segundosRestantes = _segundosTotales;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _toMin(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  String get _tituloSesion {
    final a = widget.actividad;
    if (a == null) return 'Sesión de estudio';
    if (a.tipo.toLowerCase() == 'examen') {
      return 'Estudio para examen ${a.nombre}';
    }
    return a.nombre;
  }

  String _formatTiempo(int segundos) {
    final s = segundos < 0 ? 0 : segundos;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sg = s % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = sg.toString().padLeft(2, '0');
    if (h > 0) {
      return '$h:$mm:$ss';
    }
    return '$mm:$ss';
  }

  bool get _puedeFinalizar =>
      _segundosTotales >= _umbralFinalizarSegundos &&
      _segundosTranscurridos >= _umbralFinalizarSegundos;

  void _iniciar() {
    setState(() {
      _iniciado = true;
      _pausado = false;
    });
    _arrancarTimer();
  }

  void _arrancarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _segundosRestantes--;
        _segundosTranscurridos++;
      });
      if (_segundosRestantes <= 0) {
        _completarPorTiempo();
      }
    });
  }

  void _pausar() {
    _timer?.cancel();
    setState(() => _pausado = true);
  }

  void _reanudar() {
    setState(() => _pausado = false);
    _arrancarTimer();
  }

  Future<void> _editarDuracion() async {
    final restanteMin = (_segundosRestantes / 60).ceil().clamp(1, 9999);
    final nuevoMin = await showDialog<int>(
      context: context,
      builder: (_) => _EditarTiempoDialog(minutosIniciales: restanteMin),
    );

    if (nuevoMin == null) return;
    final nuevoSeg = nuevoMin * 60;
    setState(() {
      _segundosRestantes = nuevoSeg;
      _segundosTotales = nuevoSeg + _segundosTranscurridos;
    });
  }

  Future<void> _completarPorTiempo() async {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) HapticFeedback.heavyImpact();
    });
    await _persistirCompletada();
    if (!mounted) return;
    setState(() => _finalizado = true);
    await _dialogoSesionExitosa();
  }

  Future<void> _finalizarManual() async {
    _timer?.cancel();
    HapticFeedback.mediumImpact();
    await _persistirCompletada();
    if (!mounted) return;
    setState(() => _finalizado = true);
    await _dialogoSesionExitosa();
  }

  Future<void> _persistirCompletada() async {
    if (widget.session.id == null) return;
    try {
      await _sessionRepo.setCompletada(widget.session.id!, true);
      widget.onSesionCompletada();
    } catch (_) {}
  }

  Future<void> _dialogoSesionExitosa() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("¡Sesión exitosa!"),
        content: Text(
          'Terminaste tu sesión de "$_tituloSesion".',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  Future<bool> _confirmarSalida() async {
    if (!_iniciado || _finalizado) return true;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(
          "¿Abandonar la sesión? Tu progreso de esta corrida se perderá "
          "y la sesión seguirá pendiente.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Seguir"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Abandonar"),
          ),
        ],
      ),
    );
    return confirmar == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmarSalida();
        if (ok && mounted) Navigator.pop(context, false);
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: double.maxFinite,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.indiceActual != null && widget.totalSesiones != null)
                  Text(
                    'Sesión ${widget.indiceActual} de ${widget.totalSesiones}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  _tituloSesion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.actividad != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.actividad!.materia,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
                if (widget.session.emergencia) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'emergencia',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                Text(
                  _formatTiempo(_segundosRestantes),
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _iniciado
                      ? (_pausado ? "pausado" : "concéntrate")
                      : "listo para iniciar",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),

                if (!_iniciado) _buildAccionesPreInicio(),
                if (_iniciado && !_finalizado) _buildAccionesEnCurso(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccionesPreInicio() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _iniciar,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Iniciar",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _editarDuracion,
          icon: const Icon(Icons.edit, size: 16),
          label: const Text("Editar"),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () async {
            final ok = await _confirmarSalida();
            if (ok && mounted) Navigator.pop(context, false);
          },
          child: const Text("Cerrar"),
        ),
      ],
    );
  }

  Widget _buildAccionesEnCurso() {
    return Column(
      children: [
        if (_puedeFinalizar)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _finalizarManual,
              icon: const Icon(Icons.check),
              label: const Text("Finalizar actividad"),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          )
        else if (_segundosTotales >= _umbralFinalizarSegundos)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Podrás finalizar manualmente tras 20 min '
              '(faltan ${_formatTiempo(_umbralFinalizarSegundos - _segundosTranscurridos)})',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _pausado ? _reanudar : _pausar,
              icon: Icon(_pausado ? Icons.play_arrow : Icons.pause),
              label: Text(_pausado ? "Reanudar" : "Pausa"),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () async {
                final ok = await _confirmarSalida();
                if (ok && mounted) Navigator.pop(context, false);
              },
              child: const Text("Salir"),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditarTiempoDialog extends StatefulWidget {
  final int minutosIniciales;

  const _EditarTiempoDialog({required this.minutosIniciales});

  @override
  State<_EditarTiempoDialog> createState() => _EditarTiempoDialogState();
}

class _EditarTiempoDialogState extends State<_EditarTiempoDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.minutosIniciales.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _parsed => int.tryParse(_controller.text.trim());
  bool get _valido => (_parsed ?? 0) > 0;

  void _aceptar() {
    if (_valido) Navigator.pop(context, _parsed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar tiempo"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Solo cambia el tiempo de esta corrida. "
            "La sesión planificada queda igual.",
            style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _aceptar(),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "mins",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _valido ? _aceptar : null,
          child: const Text("Aceptar"),
        ),
      ],
    );
  }
}
