import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'activity_entry.dart';
import 'emotion_entry.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _selectedIndex = 0;
  String? _selectedTag;
  final int _userId = 1; // Replace with real logged-in user id

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Cuenta"),
      ),
      body: _selectedIndex == 0
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: Text(
                    'Bienvenido al organizador de actividades. Aquí podrás encontrar diferentes etiquetas diseñadas para ti y tus actividades diarias.',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Etiquetas: '),
                      const SizedBox(width: 8),
                      FutureBuilder<List<String>>(
                        future: DBHelper.getTags(_userId),
                        builder: (context, snap) {
                          if (!snap.hasData || snap.data!.isEmpty) return const Text('No hay etiquetas');
                          final tags = snap.data!;
                          return Wrap(
                            spacing: 8,
                            children: tags.map((t) {
                              final selected = t == _selectedTag;
                              return ChoiceChip(
                                label: Text(t),
                                selected: selected,
                                onSelected: (_) => setState(() => _selectedTag = selected ? null : t),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildActivityArea(),
                ),
              ],
            )
          : _selectedIndex == 1
            ? const Center(child: Text("Calendario"))
            : EmotionRegistrationPage(userId: _userId, onSaved: () => setState(() {})),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ActivityEntryPage(userId: _userId),
                ));
                // refresh the page to reload tags and history
                setState(() {});
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actividad guardada')));
                }
              },
              child: const Icon(Icons.add),
            )
          : _selectedIndex == 2
              ? FloatingActionButton(
                  onPressed: () {
                    // Scroll to top or open the embedded form's save action
                    // For simplicity, open the emotion form as a full page modal
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EmotionRegistrationPage(userId: _userId, onSaved: () => setState(() {}))));
                  },
                  child: const Icon(Icons.add),
                )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Registrar Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Registrar Emociones',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityArea() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _selectedTag == null ? DBHelper.getEventEntries(_userId) : DBHelper.getEventEntriesByTag(_userId, _selectedTag!),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('No hay actividades registradas.'));
        final entries = snap.data!;
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final e = entries[index];
            final colorInt = e['color'] as int? ?? 0xFF2196F3;
            return ListTile(
              leading: Container(width: 12, height: 36, color: Color(colorInt)),
              title: Text(e['nombre'] ?? ''),
              subtitle: Text('${e['fecha'] ?? ''} ${e['hora'] ?? ''}'),
            );
          },
        );
      },
    );
  }
}

// Full-screen emotion registration page that shows the form and the history below
class EmotionRegistrationPage extends StatelessWidget {
  final int userId;
  final VoidCallback? onSaved;
  const EmotionRegistrationPage({super.key, required this.userId, this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Text(
            'Registrar y revisar emociones. Usa el formulario para guardar una nueva emoción y revisa el historial abajo.',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        // The form
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: EmotionEntryForm(
                userId: userId,
                onSaved: (saved) {
                  if (saved) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emoción guardada')));
                    onSaved?.call();
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const Padding(padding: EdgeInsets.all(8.0), child: Text('Historial de emociones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper.getEventEntriesByTag(userId, 'emocion'),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('No hay emociones registradas.'));
              final entries = snap.data!;
              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  final colorInt = e['color'] as int? ?? 0xFFE91E63;
                  return ListTile(
                    leading: Container(width: 12, height: 36, color: Color(colorInt)),
                    title: Text(e['nombre'] ?? ''),
                    subtitle: Text('${e['fecha'] ?? ''} ${e['hora'] ?? ''}\n${e['descripcion'] ?? ''}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}