import 'package:flutter/material.dart';
import 'package:planificador_academico_inteligente/data/repositories/activity_repository.dart';
import 'package:planificador_academico_inteligente/entities/activity.dart';

class TareaDetailDialog extends StatefulWidget {
  final Activity activity;
  final VoidCallback onChanged;

  const TareaDetailDialog({
    super.key,
    required this.activity,
    required this.onChanged,
  });

  @override
  State<TareaDetailDialog> createState() => _TareaDetailDialogState();
}

class _TareaDetailDialogState extends State<TareaDetailDialog> {
  final ActivityRepository _repo = ActivityRepository();

  late String _prioridad;
  late int _horas;
  late DateTime _fecha;
  late bool _completada;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prioridad = widget.activity.prioridad;
    _horas = widget.activity.horasDedicadas;
    _fecha = widget.activity.fechaLimite;
    _completada = widget.activity.completada;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _fecha = DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    if (widget.activity.id == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    final actualizada = widget.activity.copyWith(
      prioridad: _prioridad,
      horasDedicadas: _horas,
      fechaLimite: _fecha,
      completada: _completada,
    );
    try {
      await _repo.update(actualizada);
      widget.onChanged();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar la tarea')),
        );
      }
    }
  }

  String _formatFecha(DateTime f) {
    const meses = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${f.day} ${meses[f.month - 1]} ${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      a.nombre,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Materia: ${a.materia}', style: const TextStyle(color: Color(0xFF6B7280))),
              Text('Tipo: ${a.tipo}', style: const TextStyle(color: Color(0xFF6B7280))),
              if (a.descripcion.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(a.descripcion, style: const TextStyle(fontSize: 13)),
              ],
              const Divider(height: 24),

              const Text('Prioridad', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ['alta', 'media', 'baja'].map((p) {
                  final selected = _prioridad == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: selected,
                    onSelected: (_) => setState(() => _prioridad = p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Text('Horas estimadas: ', style: TextStyle(fontWeight: FontWeight.w600)),
                  IconButton(
                    onPressed: _horas > 0 ? () => setState(() => _horas--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_horas', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: () => setState(() => _horas++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Text('Fecha de entrega: ', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Expanded(child: Text(_formatFecha(_fecha))),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Completada', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_completada ? 'Marcada como completada' : 'Pendiente'),
                value: _completada,
                onChanged: (v) => setState(() => _completada = v),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A5F),
                      foregroundColor: Colors.white,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
