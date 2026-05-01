import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/domain.dart';
import '../models/subtopic.dart';
import '../providers/domain_provider.dart';
import 'topic_list_screen.dart';

class SubtopicListScreen extends ConsumerStatefulWidget {
  final DomainModel domain;

  const SubtopicListScreen({super.key, required this.domain});

  @override
  ConsumerState<SubtopicListScreen> createState() => _SubtopicListScreenState();
}

class _SubtopicListScreenState extends ConsumerState<SubtopicListScreen> {
  DomainModel _getDomain() {
    final domains = ref.watch(domainListProvider);
    return domains.firstWhere((d) => d.id == widget.domain.id, orElse: () => widget.domain);
  }

  @override
  Widget build(BuildContext context) {
    final domain = _getDomain();

    return Scaffold(
      appBar: AppBar(
        title: Text(domain.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Domain Completion: ${(domain.completionPercentage * 100).toInt()}%')),
              );
            },
          )
        ],
      ),
      body: domain.subtopics.isEmpty
          ? const Center(child: Text('No subtopics yet.'))
          : ReorderableListView.builder(
              itemCount: domain.subtopics.length,
              onReorder: (oldIndex, newIndex) {
                 if (oldIndex < newIndex) newIndex -= 1;
                 final subtopics = domain.subtopics;
                 final item = subtopics.removeAt(oldIndex);
                 subtopics.insert(newIndex, item);
                 for (int i=0; i<subtopics.length; i++) { subtopics[i].orderIndex = i; }
                 ref.read(domainListProvider.notifier).updateDomain(domain);
              },
              itemBuilder: (context, index) {
                final subtopic = domain.subtopics[index];
                return SubtopicTile(
                  key: ValueKey(subtopic.id),
                  domain: domain,
                  subtopic: subtopic,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubtopicDialog(context, ref, domain),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSubtopicDialog(BuildContext context, WidgetRef ref, DomainModel domain) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtopic'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Phase 1, UI, Backend, etc.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newSubtopic = Subtopic(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: controller.text.trim(),
                  topics: [],
                  createdAt: DateTime.now(),
                  orderIndex: domain.subtopics.length,
                );
                domain.subtopics.add(newSubtopic);
                ref.read(domainListProvider.notifier).updateDomain(domain);
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

class SubtopicTile extends StatelessWidget {
  final DomainModel domain;
  final Subtopic subtopic;

  const SubtopicTile({super.key, required this.domain, required this.subtopic});

  @override
  Widget build(BuildContext context) {
    bool isDone = subtopic.isCompleted && subtopic.topics.isNotEmpty;
    double percent = subtopic.completionPercentage;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          subtopic.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${subtopic.topics.length} Topics'),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: percent,
              progressColor: isDone ? Colors.green : Colors.deepPurpleAccent,
              backgroundColor: Colors.grey.shade800,
              barRadius: const Radius.circular(4),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 4),
          ],
        ),
        trailing: isDone ? const Icon(Icons.done_all, color: Colors.green) : null,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TopicListScreen(domain: domain, subtopic: subtopic)));
        },
      ),
    );
  }
}
