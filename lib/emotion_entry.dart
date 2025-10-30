import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'audio_sensor.dart';

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

  static const List<String> _emotions = ['Feliz', 'Triste', 'Ansioso', 'Enojado', 'Neutral'];

  static const Map<String, Color> _emotionColors = {
    'Feliz': Colors.yellow,
    'Triste': Colors.blue,
    'Ansioso': Colors.orange,
    'Enojado': Colors.red,
    'Neutral': Colors.grey,
  };

  static const Map<String, String> _emotionEmojis = {
    'Feliz': '😄',
    'Triste': '😢',
    'Ansioso': '😬',
    'Enojado': '😡',
    'Neutral': '😐',
  };

  Color get _selectedColor => _emotionColors[_emotion] ?? Colors.pink;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final emoji = _emotionEmojis[_emotion] ?? '';
    final emocionConEmoji = emoji.isNotEmpty ? '$emoji $_emotion' : _emotion;
    await DBHelper.insertEmocion(
      userId: widget.userId,
      emocion: emocionConEmoji,
      intensidad: _intensity.toInt(),
      notas: _noteController.text.trim(),
      color: _selectedColor.value,
    );
    widget.onSaved?.call(true);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final maxFormHeight = screenH * 0.6;
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
                // Encabezado con color y título
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: _selectedColor, borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Registrar emoción',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Selector de emoción
                DropdownButtonFormField<String>(
                  value: _emotion,
                  items: _emotions.map((e) => DropdownMenuItem(value: e, child: Text('${_emotionEmojis[e] ?? ''} $e'))).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _emotion = v);
                  },
                  decoration: const InputDecoration(labelText: 'Emoción'),
                ),
                const SizedBox(height: 12),
                // Intensidad
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Intensidad'),
                    Slider(
                      value: _intensity,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: _intensity.toInt().toString(),
                      onChanged: (v) => setState(() => _intensity = v),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Notas con micrófono
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Notas (opcional)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () async {
                        final texto = await showAudioSensorBottomSheet(context);
                        if (texto != null && texto.isNotEmpty) {
                          final existing = _noteController.text;
                          _noteController.text = existing.isEmpty ? texto : '$existing\n$texto';
                        }
                      },
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
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
