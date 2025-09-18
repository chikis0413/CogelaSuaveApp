import 'package:flutter/material.dart';
import 'db_helper.dart';

class NewEntryPage extends StatefulWidget {
  final int userId;
  final int? eventId;

  const NewEntryPage({Key? key, required this.userId, this.eventId}) : super(key: key);

  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  Color _pickedColor = Colors.blue;
  String? _selectedTag;
  final List<String> _availableTags = ['Personal', 'Trabajo', 'Salud', 'Estudio', 'Otro'];

  @override
  void dispose() {
    _nombreController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry({bool popAfter = false}) async {
    if (!_formKey.currentState!.validate()) return;

    final entry = {
      'event_id': widget.eventId ?? 0,
      'user_id': widget.userId,
      'nombre': _nombreController.text.trim(),
      'fecha': _fechaController.text.trim(),
      'hora': _horaController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'color': _pickedColor.value,
      'tag': _selectedTag,
    };

    try {
      await DBHelper.insertEventEntry(entry);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actividad guardada')));
      // refrescar el historial en esta pantalla en lugar de cerrar inmediatamente
      setState(() {
        // limpiar campos
        _nombreController.clear();
        _fechaController.clear();
        _horaController.clear();
        _descripcionController.clear();
        _selectedTag = null;
        _pickedColor = Colors.blue;
      });
      if (popAfter && mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) _fechaController.text = picked.toIso8601String().split('T').first;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) _horaController.text = picked.format(context);
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
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.isEmpty) ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Fecha'),
                onTap: _pickDate,
                validator: (v) => (v == null || v.isEmpty) ? 'Seleccione una fecha' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _horaController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Hora'),
                onTap: _pickTime,
                validator: (v) => (v == null || v.isEmpty) ? 'Seleccione una hora' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTag,
                decoration: const InputDecoration(labelText: 'Etiqueta'),
                items: _availableTags.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedTag = v),
                validator: (v) => (v == null || v.isEmpty) ? 'Selecciona una etiqueta' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveEntry(popAfter: false),
                      child: const Text('Guardar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveEntry(popAfter: true),
                      child: const Text('Guardar y cerrar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Historial de actividades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: DBHelper.getEventEntries(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('No hay actividades registradas.');
                  final entries = snapshot.data!;
                  return Column(
                    children: entries.map((e) {
                      final colorInt = e['color'] as int? ?? 0xFF2196F3;
                      final color = Color(colorInt);
                      return ListTile(
                        leading: Container(width: 12, height: 36, color: color),
                        title: Text(e['nombre'] ?? ''),
                        subtitle: Text('${e['fecha'] ?? ''} ${e['hora'] ?? ''}'),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
