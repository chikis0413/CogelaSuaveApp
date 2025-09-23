import 'package:flutter/material.dart';
import 'db_helper.dart';

class CalendarPageWidget extends StatefulWidget {
  final int userId;
  const CalendarPageWidget({super.key, required this.userId});

  @override
  State<CalendarPageWidget> createState() => _CalendarPageWidgetState();
}

class _CalendarPageWidgetState extends State<CalendarPageWidget> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dateStr = _selectedDate.toIso8601String().split('T').first;
    final screenH = MediaQuery.of(context).size.height;
    final calendarHeight = screenH * 0.35; // smaller calendar on small screens
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: calendarHeight,
                child: Column(
                  children: [
                    Expanded(
                      child: CalendarDatePicker(
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onDateChanged: (d) => setState(() => _selectedDate = d),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Actividades para: $dateStr'),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper.getEventEntries(widget.userId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('No hay actividades registradas.'));
              final entries = snap.data!.where((e) => (e['fecha'] ?? '') == dateStr).toList();
              if (entries.isEmpty) return const Center(child: Text('No hay actividades para esta fecha.'));
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  final colorInt = e['color'] as int? ?? 0xFF2196F3;
                  return ListTile(
                    leading: Container(width: 12, height: 36, color: Color(colorInt)),
                    title: Text(e['nombre'] ?? ''),
                    subtitle: Text('${e['hora'] ?? ''} ${e['descripcion'] ?? ''}'),
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
