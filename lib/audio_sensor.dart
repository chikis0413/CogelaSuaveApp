import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Muestra un bottom sheet con reconocimiento de voz y devuelve el texto transcrito.
Future<String?> showAudioSensorBottomSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: MediaQuery.of(ctx).viewInsets,
      child: SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.45,
        child: _AudioSensorSheet(),
      ),
    ),
  );
}

class _AudioSensorSheet extends StatefulWidget {
  @override
  State<_AudioSensorSheet> createState() => _AudioSensorSheetState();
}

class _AudioSensorSheetState extends State<_AudioSensorSheet> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;
  bool _listening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(onStatus: _onStatus, onError: _onError);
      setState(() => _available = available);
    } catch (_) {
      setState(() => _available = false);
    }
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      setState(() => _listening = false);
    }
  }

  void _onError(dynamic err) {
    // No causar crash; sólo parar escucha y mostrar fallback si es necesario
    setState(() => _listening = false);
  }

  void _startListening() {
    if (!_available) return;
    setState(() {
      _text = '';
      _listening = true;
    });
    // Evitar usar parámetros que no existan en versiones diferentes
    _speech.listen(onResult: (result) {
      setState(() {
        _text = result.recognizedWords;
      });
    });
  }

  void _stopListening() {
    if (!_listening) return;
    _speech.stop();
    setState(() => _listening = false);
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: Text('Sensor de voz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                  icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                  color: _listening ? Colors.red : Colors.black54,
                  onPressed: () {
                    if (_listening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _available
                        ? (_text.isEmpty ? (_listening ? 'Escuchando...' : 'Presiona el mic para empezar') : _text)
                        : 'Reconocimiento no disponible en este dispositivo',
                    style: TextStyle(fontSize: 16, color: _available ? Colors.black87 : Colors.red),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(), // cancelar sin retorno
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _stopListening();
                      Navigator.of(context).pop(_text.trim().isEmpty ? null : _text.trim());
                    },
                    child: const Text('Insertar texto'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}