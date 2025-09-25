import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'activity_entry.dart';
import 'emotion_entry.dart';
import 'calendar_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _selectedIndex = 0;
  
  final int _userId = 1; // Replace with real logged-in user id
  String? _displayName;
  bool _loadingDisplayName = true;
  String? _apodo;

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    try {
      final name = await DBHelper.getDisplayName(_userId);
      String? nickname;
      if (name == null) {
        nickname = await DBHelper.getApodo(_userId);
      }
      setState(() {
        _displayName = name;
        _apodo = nickname;
        _loadingDisplayName = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading display name: $e');
      setState(() {
        _displayName = null;
        _loadingDisplayName = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // If you have a user name available from auth or DB, replace the hardcoded value below.
        title: Row(
          children: [
            const Text('Mi Cuenta'),
            const SizedBox(width: 12),
            // Show the real user's name when available
            if (_loadingDisplayName) const SizedBox(width: 12, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            else if (_displayName != null) Text('— ${_displayName!}', style: const TextStyle(fontSize: 14))
            else if (_apodo != null) Text('— ${_apodo!}', style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          // Logout button on the right
          IconButton(
            tooltip: 'Salir',
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Replace with real logout logic if you have auth (clear tokens, session, etc.).
              // Navigate to the login screen and remove all previous routes.
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? ActivityRegistrationPage(userId: _userId)
          : _selectedIndex == 1
            ? CalendarPageWidget(userId: _userId)
            : EmotionRegistrationPage(userId: _userId, onSaved: () => setState(() {})),
      // No floating action button: remove the '+' button per request
      floatingActionButton: null,
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

// Full-screen activity registration page: form + history
class ActivityRegistrationPage extends StatelessWidget {
  final int userId;
  const ActivityRegistrationPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Text(
            'Bienvenido al organizador de actividades. Aquí puedes añadir nuevas actividades y revisar tu historial.',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<String>>(
            future: DBHelper.getTags(userId),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
              final tags = snap.data!;
              return Row(
                children: [
                  const Text('Etiquetas: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: tags.map((t) => ChoiceChip(label: Text(t), selected: false, onSelected: (_) {})).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ActivityEntryForm(
                userId: userId,
                onSaved: (saved) {
                  if (saved) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actividad guardada')));
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const Padding(padding: EdgeInsets.all(8.0), child: Text('Historial de actividades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper.getEventEntries(userId),
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