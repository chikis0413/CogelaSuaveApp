import 'package:flutter/material.dart';
import 'audio_sensor.dart';
import 'db_helper.dart';

typedef ActivitySaveCallback = void Function(bool saved);

class ActivityEntryForm extends StatefulWidget {
  final int userId;
  final ActivitySaveCallback? onSaved;
  const ActivityEntryForm({super.key, required this.userId, this.onSaved});

  @override
  State<ActivityEntryForm> createState() => _ActivityEntryFormState();
}

class _ActivityEntryFormState extends State<ActivityEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  Color _color = Colors.blue;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
    if (t != null) setState(() => _time = t);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final fecha = _date != null ? _date!.toIso8601String().split('T').first : '';
    final hora = _time != null ? _time!.format(context) : '';
    await DBHelper.insertActividad(
      userId: widget.userId,
      nombre: _titleController.text.trim(),
      fecha: fecha,
      hora: hora,
      descripcion: _descriptionController.text.trim(),
      color: _color.value,
      tag: null,
    );
    widget.onSaved?.call(true);
    // limpia y cierra
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final maxFormHeight = screenH * 0.7;
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxFormHeight),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // header
                Row(
                  children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 12),
                    const Text('Registrar actividad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un título' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () async {
                        final texto = await showAudioSensorBottomSheet(context);
                        if (texto != null && texto.isNotEmpty) {
                          final existing = _descriptionController.text;
                          _descriptionController.text = existing.isEmpty ? texto : '$existing\n$texto';
                        }
                      },
                    ),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_date != null ? _date!.toIso8601String().split('T').first : 'Seleccionar fecha'),
                        onPressed: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(_time != null ? _time!.format(context) : 'Seleccionar hora'),
                        onPressed: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // color choices
                Row(
                  children: [
                    _colorChoice(Colors.blue),
                    const SizedBox(width: 8),
                    _colorChoice(Colors.green),
                    const SizedBox(width: 8),
                    _colorChoice(Colors.orange),
                    const SizedBox(width: 8),
                    _colorChoice(Colors.purple),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar'))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Guardar'))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorChoice(Color c) {
    final selected = c.value == _color.value;
    return GestureDetector(
      onTap: () => setState(() => _color = c),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }
}

// Helper to show as bottom sheet if needed
Future<bool?> showActivityEntryBottomSheet(BuildContext context, {required int userId}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: MediaQuery.of(ctx).viewInsets,
      child: ActivityEntryForm(userId: userId),
    ),
  );
}
