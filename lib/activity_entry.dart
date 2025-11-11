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

  final List<Map<String, dynamic>> _colorOptions = [
    {'color': Color(0xFF4285F4), 'label': 'Azul'},
    {'color': Color(0xFF34A853), 'label': 'Verde'},
    {'color': Color(0xFFFBBC04), 'label': 'Amarillo'},
    {'color': Color(0xFFEA4335), 'label': 'Rojo'},
    {'color': Color(0xFF9C27B0), 'label': 'Morado'},
    {'color': Color(0xFFFF6D00), 'label': 'Naranja'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1A73E8),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1A73E8),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
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

    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _date = null;
      _time = null;
      _color = Color(0xFF4285F4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Nueva Actividad',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202124),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Registra tus actividades diarias',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),

              // Título
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej: Reunión de equipo',
                  prefixIcon: const Icon(Icons.title_rounded),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFEA4335), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Ingrese un título' : null,
              ),
              const SizedBox(height: 20),

              // Fecha y Hora
              const Text(
                'Fecha y Hora',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF1A73E8)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _date == null
                                    ? 'Fecha'
                                    : '${_date!.day}/${_date!.month}/${_date!.year}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _date == null ? Colors.grey[600] : Color(0xFF202124),
                                  fontWeight: _date == null ? FontWeight.w400 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 20, color: Color(0xFF1A73E8)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _time == null ? 'Hora' : _time!.format(context),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _time == null ? Colors.grey[600] : Color(0xFF202124),
                                  fontWeight: _time == null ? FontWeight.w400 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Agrega detalles sobre la actividad...',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),

              // Color
              const Text(
                'Categoría de Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorOptions.map((option) {
                  final isSelected = option['color'].value == _color.value;
                  return GestureDetector(
                    onTap: () => setState(() => _color = option['color']),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? option['color'].withOpacity(0.15)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? option['color']
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: option['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? option['color'] : Color(0xFF5F6368),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Guardar Actividad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
