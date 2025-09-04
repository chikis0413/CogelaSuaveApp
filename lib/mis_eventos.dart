import 'package:flutter/material.dart';
import 'db_helper.dart';

class Evento {
  final String titulo;
  final DateTime fecha;
  final Color color;

  Evento({required this.titulo, required this.fecha, required this.color});
}

class MisEventosPage extends StatefulWidget {
  @override
  State<MisEventosPage> createState() => _MisEventosPageState();
}

class _MisEventosPageState extends State<MisEventosPage> {
  List<Evento> eventos = [];
  int userId = 1; // Usa el id del usuario actual
  final _formKey = GlobalKey<FormState>();
  String titulo = '';
  DateTime? fecha;
  Color color = const Color(0xFF7C9A92);

  final Map<String, Color> colores = {
    'Verde': Color(0xFF7C9A92),
    'Rojo': Color(0xFFE57373),
    'Azul': Color(0xFF64B5F6),
    'Naranja': Color(0xFFFFB74D),
    'Morado': Color(0xFFBA68C8),
  };

  Future<void> cargarEventos() async {
    final eventosDb = await DBHelper.getEventos(userId);
    setState(() {
      eventos = eventosDb
          .map(
            (e) => Evento(
              titulo: e['titulo'],
              fecha: DateTime.parse(e['fecha']),
              color: Color(e['color']),
            ),
          )
          .toList();
    });
  }

  Future<void> agregarEvento() async {
    if (_formKey.currentState?.validate() ?? false && fecha != null) {
      _formKey.currentState?.save();
      final evento = {
        'user_id': userId,
        'titulo': titulo,
        'fecha': fecha!.toIso8601String(),
        'color': color.value,
      };
      await DBHelper.insertEvento(evento);
      await cargarEventos();
      setState(() {
        titulo = '';
        fecha = null;
        color = const Color(0xFF7C9A92);
      });
      _formKey.currentState?.reset();
    }
  }

  @override
  void initState() {
    super.initState();
    cargarEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FA), // secondary-color
      appBar: AppBar(
        title: const Text('Mis eventos'),
        backgroundColor: const Color(0xFFB3D1E6), // primary-color
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 900),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7), // accent-color
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis eventos',
                style: TextStyle(
                  color: Color(0xFFB3D1E6), // primary-color
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Título del evento',
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Campo requerido' : null,
                        onSaved: (value) => titulo = value ?? '',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                fecha = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            fecha == null
                                ? 'Fecha y hora'
                                : '${fecha!.toLocal()}'.split('.')[0],
                            style: TextStyle(
                              color: fecha == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<Color>(
                        value: color,
                        items: colores.entries
                            .map((e) => DropdownMenuItem<Color>(
                                  value: e.value,
                                  child: Text(e.key),
                                ))
                            .toList(),
                        onChanged: (c) => setState(() => color = c ?? color),
                        decoration: const InputDecoration(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB3D1E6), // primary-color
                      ),
                      onPressed: () {
                        agregarEvento();
                      },
                      child: const Text('Agregar Evento'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: eventos.isEmpty
                      ? const Center(child: Text('No tienes eventos aún.'))
                      : ListView.builder(
                          itemCount: eventos.length,
                          itemBuilder: (context, i) {
                            final e = eventos[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: e.color,
                              ),
                              title: Text(e.titulo),
                              subtitle: Text(
                                '${e.fecha.day}/${e.fecha.month}/${e.fecha.year} ${e.fecha.hour.toString().padLeft(2, '0')}:${e.fecha.minute.toString().padLeft(2, '0')}',
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(e.titulo),
                                    content: Text(
                                      'Fecha: ${e.fecha.day}/${e.fecha.month}/${e.fecha.year} ${e.fecha.hour.toString().padLeft(2, '0')}:${e.fecha.minute.toString().padLeft(2, '0')}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}