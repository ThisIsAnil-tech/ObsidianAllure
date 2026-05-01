import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/gamification_provider.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.deepPurpleAccent.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Level', profile.level.toString(), Colors.amber),
                _buildStatColumn('Total XP', profile.xp.toString(), Colors.blueAccent),
                _buildStatColumn('Curr Streak', '${profile.currentStreak} 🔥', Colors.orange),
                _buildStatColumn('Max Streak', '${profile.highestStreak} ⚡', Colors.redAccent),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Colors.deepPurpleAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.purple.shade300,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              if (profile.lastCompletedDate != null && isSameDay(day, profile.lastCompletedDate)) {
                return ['Completed Task'];
              }
              return [];
            },
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Your daily activity is mapped above. Consistently mark topics as complete to maintain your streak!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
