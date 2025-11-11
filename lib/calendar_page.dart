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
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dateStr = _selectedDate.toIso8601String().split('T').first;

    return Column(
      children: [
        // Calendario mejorado
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header del calendario
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A73E8),
                      const Color(0xFF4285F4),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMonthName(_focusedDate.month),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_focusedDate.year}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _focusedDate = DateTime(
                                _focusedDate.year,
                                _focusedDate.month - 1,
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _focusedDate = DateTime(
                                _focusedDate.year,
                                _focusedDate.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Calendario
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildCustomCalendar(),
              ),
            ],
          ),
        ),

        // Título de actividades del día
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumen del ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202124),
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Lista de actividades y emociones
        Expanded(
          child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
            future: _loadDayData(dateStr),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF1A73E8),
                  ),
                );
              }

              if (!snap.hasData) {
                return _buildEmptyState();
              }

              final activities = snap.data!['activities'] ?? [];
              final emotions = snap.data!['emotions'] ?? [];

              if (activities.isEmpty && emotions.isEmpty) {
                return _buildEmptyState();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Actividades
                    if (activities.isNotEmpty) ...[
                      _buildSectionHeader('Actividades', Icons.event_note_rounded),
                      const SizedBox(height: 12),
                      ...activities.map((activity) => _buildActivityCard(activity)),
                      const SizedBox(height: 16),
                    ],

                    // Emociones
                    if (emotions.isNotEmpty) ...[
                      _buildSectionHeader('Registro Emocional', Icons.mood_rounded),
                      const SizedBox(height: 12),
                      ...emotions.map((emotion) => _buildEmotionCard(emotion)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> _loadDayData(String dateStr) async {
    final activities = await DBHelper.getEventEntries(widget.userId);
    final emotions = await DBHelper.getEmotionEntries(widget.userId);

    final dayActivities = activities.where((e) => (e['fecha'] ?? '') == dateStr).toList();
    final dayEmotions = emotions.where((e) {
      final timestamp = e['timestamp'] as String?;
      if (timestamp == null) return false;
      final emotionDate = timestamp.split('T').first;
      return emotionDate == dateStr;
    }).toList();

    return {
      'activities': dayActivities,
      'emotions': dayEmotions,
    };
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A73E8)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5F6368),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final colorInt = activity['color'] as int? ?? 0xFF2196F3;
    final color = Color(colorInt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity['hora'] ?? 'Sin hora',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      activity['nombre'] ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF202124),
                      ),
                    ),
                    if ((activity['descripcion'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        activity['descripcion'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionCard(Map<String, dynamic> emotion) {
    final emotionName = emotion['emotion'] ?? '';
    final intensity = emotion['intensity'] ?? 0;
    final notes = emotion['notes'] ?? '';
    final timestamp = DateTime.parse(emotion['timestamp']);

    Color getEmotionColor() {
      switch (emotionName) {
        case 'Feliz':
          return Colors.yellow[700]!;
        case 'Triste':
          return Colors.blue[600]!;
        case 'Enojado':
          return Colors.red[600]!;
        case 'Ansioso':
          return Colors.orange[600]!;
        case 'Calmado':
          return Colors.green[600]!;
        case 'Cansado':
          return Colors.purple[600]!;
        default:
          return Colors.grey[600]!;
      }
    }

    final color = getEmotionColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  emotionName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Intensidad: ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              ...List.generate(
                10,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: i < intensity ? color : Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$intensity/10',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                notes,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay registros para esta fecha',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega actividades o emociones',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCalendar() {
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Días de la semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['D', 'L', 'M', 'M', 'J', 'V', 'S'].map((day) {
            return SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Días del mes
        Wrap(
          spacing: 0,
          runSpacing: 8,
          children: List.generate(42, (index) {
            if (index < firstWeekday || index >= firstWeekday + daysInMonth) {
              return const SizedBox(width: 40, height: 40);
            }
            final day = index - firstWeekday + 1;
            final date = DateTime(_focusedDate.year, _focusedDate.month, day);
            final isSelected = date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;
            final isToday = date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1A73E8)
                      : isToday
                          ? const Color(0xFF1A73E8).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(color: const Color(0xFF1A73E8), width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFF202124),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month - 1];
  }
}
