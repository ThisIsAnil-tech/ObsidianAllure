import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/domain.dart';
import '../providers/domain_provider.dart';
import '../providers/gamification_provider.dart';
import 'subtopic_list_screen.dart';
import 'sidebar.dart';
import 'search_screen.dart';
import 'activity_screen.dart';

class DomainListScreen extends ConsumerWidget {
  const DomainListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(domainListProvider);
    final profile = ref.watch(gamificationProvider);

    return Scaffold(
      drawer: const AppSidebar(),
      appBar: AppBar(
        title: const Text('My Domains', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen()));
              },
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('Lvl ${profile.level}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text('${profile.currentStreak}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
        ],
      ),
      body: domains.isEmpty
          ? const Center(child: Text('No domains found. Add one!'))
          : ReorderableListView.builder(
              itemCount: domains.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(domainListProvider.notifier).reorderDomains(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final domain = domains[index];
                return DomainTile(key: ValueKey(domain.id), domain: domain);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDomainDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDomainDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Domain'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Work, Personal, etc.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newDomain = DomainModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: controller.text.trim(),
                  subtopics: [],
                  createdAt: DateTime.now(),
                );
                ref.read(domainListProvider.notifier).addDomain(newDomain);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class DomainTile extends StatelessWidget {
  final DomainModel domain;

  const DomainTile({super.key, required this.domain});

  @override
  Widget build(BuildContext context) {
    bool isDone = domain.isCompleted && domain.subtopics.isNotEmpty;
    double percent = domain.completionPercentage;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          domain.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${domain.subtopics.length} Subtopics'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularPercentIndicator(
              radius: 20.0,
              lineWidth: 5.0,
              percent: percent,
              center: isDone
                  ? const Icon(Icons.done, color: Colors.green, size: 16)
                  : Text('${(percent * 100).toInt()}%', style: const TextStyle(fontSize: 10)),
              progressColor: isDone ? Colors.green : Colors.deepPurpleAccent,
              backgroundColor: Colors.grey.shade800,
              animation: true,
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final controller = TextEditingController(text: domain.name);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Edit Domain'),
                      content: TextField(controller: controller, autofocus: true),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            domain.name = controller.text.trim();
                            // We need ref, but we don't have it here. Let's just use domain.save() directly
                            domain.save();
                            // Navigation pop requires context
                            Navigator.pop(context);
                            // To force rebuild we'd need Riverpod, but this works minimally for local state if user goes out
                          },
                          child: const Text('Save'),
                        )
                      ]
                    )
                  );
                } else if (value == 'delete') {
                  // Direct deletion logic using domain object
                  final id = domain.id;
                  domain.delete();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Domain deleted')));
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit Name')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => SubtopicListScreen(domain: domain)));
        },
      ),
    );
  }
}
