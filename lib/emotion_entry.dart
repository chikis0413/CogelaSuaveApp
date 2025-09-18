import 'package:flutter/material.dart';
import 'db_helper.dart';

typedef EmotionSaveCallback = void Function(bool saved);

class EmotionEntryForm extends StatefulWidget {
  final int userId;
  final EmotionSaveCallback? onSaved;
  const EmotionEntryForm({super.key, required this.userId, this.onSaved});

  @override
  State<EmotionEntryForm> createState() => _EmotionEntryFormState();
}

class _EmotionEntryFormState extends State<EmotionEntryForm> {
  final _formKey = GlobalKey<FormState>();
  String _emotion = 'Feliz';
  double _intensity = 5;
  final TextEditingController _noteController = TextEditingController();

  static const Map<String, Color> _emotionColors = {
    'Feliz': Colors.yellow,
    'Triste': Colors.blue,
    'Ansioso': Colors.orange,
    'Enojado': Colors.red,
    'Neutral': Colors.grey,
  };

  Color get _selectedColor => _emotionColors[_emotion] ?? Colors.pink;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await DBHelper.insertEmocion(
      userId: widget.userId,
      emocion: _emotion,
      intensidad: _intensity.toInt(),
      notas: _noteController.text,
      color: _selectedColor.value,
    );
    widget.onSaved?.call(true);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _emotion,
                      items: _emotionColors.keys
                          .map((e) => DropdownMenuItem(value: e, child: Row(children: [Container(width:16,height:16,color:_emotionColors[e]), const SizedBox(width:8), Text(e)])))
                          .toList(),
                      onChanged: (v) => setState(() => _emotion = v ?? 'Feliz'),
                      decoration: const InputDecoration(labelText: 'Emoción'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: _selectedColor, borderRadius: BorderRadius.circular(6))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Intensidad'),
                  Expanded(
                    child: Slider(
                      value: _intensity,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _intensity.toInt().toString(),
                      onChanged: (v) => setState(() => _intensity = v),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Guardar Emoción'))),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper to show as bottom sheet
Future<bool?> showEmotionEntryBottomSheet(BuildContext context, {required int userId}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => EmotionEntryForm(userId: userId),
  );
}
