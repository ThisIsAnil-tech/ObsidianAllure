import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/gamification_provider.dart';
import '../providers/todo_provider.dart';

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
    final nodes = ref.watch(todoListProvider);

    int totalLeaves = 0;
    int completedLeaves = 0;
    for (var node in nodes) {
      final leaves = node.leafNodes;
      totalLeaves += leaves.length;
      completedLeaves += leaves.where((l) => l.isCompleted).length;
    }
    double overallProgress = totalLeaves == 0 ? 0 : completedLeaves / totalLeaves;

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Tasks: $totalLeaves', style: const TextStyle(color: Colors.grey)),
                      Text('Completed: $completedLeaves', style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      minHeight: 12,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 12),
                  ...nodes.map((node) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(node.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('${(node.completionPercentage * 100).toInt()}%', style: TextStyle(color: Theme.of(context).primaryColor)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: node.completionPercentage,
                              minHeight: 6,
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
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
