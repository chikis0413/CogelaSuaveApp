import 'package:flutter/material.dart';
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => _time = t);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final fecha = _date != null ? _date!.toIso8601String().split('T').first : '';
    final hora = _time != null ? _time!.format(context) : '';
    await DBHelper.insertActividad(
      userId: widget.userId,
      nombre: _titleController.text,
      fecha: fecha,
      hora: hora,
      descripcion: _descriptionController.text,
      color: _color.value,
      tag: null,
    );
    widget.onSaved?.call(true);
    // clear fields for convenience
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _date = null;
      _time = null;
      _color = Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final maxFormHeight = screenH * 0.45; // keep form compact on small screens
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxFormHeight),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingrese un título' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pickDate,
                        child: Text(_date == null ? 'Seleccionar fecha' : _date!.toLocal().toString().split(' ')[0]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pickTime,
                        child: Text(_time == null ? 'Seleccionar hora' : _time!.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                const Align(alignment: Alignment.centerLeft, child: Text('Color')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _colorChoice(Colors.blue),
                    _colorChoice(Colors.green),
                    _colorChoice(Colors.orange),
                    _colorChoice(Colors.purple),
                    _colorChoice(Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Guardar'))),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
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
          borderRadius: BorderRadius.circular(6),
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ActivityEntryForm(userId: userId),
        ),
      ),
    ),
  );
}
