import 'package:flutter/material.dart';
import 'db_helper.dart';

class ActivityEntryPage extends StatefulWidget {
  final int userId;
  const ActivityEntryPage({super.key, required this.userId});

  @override
  State<ActivityEntryPage> createState() => _ActivityEntryPageState();
}

class _ActivityEntryPageState extends State<ActivityEntryPage> {
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
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Actividad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
              const Text('Color'),
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
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Guardar')),
            ],
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
          borderRadius: BorderRadius.circular(6),
          border: selected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }
}
