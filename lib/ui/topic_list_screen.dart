import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import '../models/domain.dart';
import '../models/subtopic.dart';
import '../models/topic.dart';
import '../providers/domain_provider.dart';
import '../providers/gamification_provider.dart';

enum SortStrategy { custom, name, dueDate, completion }

class TopicListScreen extends ConsumerStatefulWidget {
  final DomainModel domain;
  final Subtopic subtopic;

  const TopicListScreen({super.key, required this.domain, required this.subtopic});

  @override
  ConsumerState<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends ConsumerState<TopicListScreen> {
  late ConfettiController _confettiController;
  SortStrategy _sortStrategy = SortStrategy.custom;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  DomainModel _getDomain() {
    final domains = ref.watch(domainListProvider);
    return domains.firstWhere((d) => d.id == widget.domain.id, orElse: () => widget.domain);
  }

  Subtopic? _getSubtopic(DomainModel domain) {
    try {
      return domain.subtopics.firstWhere((s) => s.id == widget.subtopic.id);
    } catch (_) {
      return null;
    }
  }

  List<Topic> _getSortedTopics(List<Topic> topics) {
    List<Topic> sorted = List.from(topics);
    switch (_sortStrategy) {
      case SortStrategy.name:
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortStrategy.dueDate:
        sorted.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortStrategy.completion:
        sorted.sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));
        break;
      case SortStrategy.custom:
        sorted.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        break;
    }
    // Pinned always bubble to top
    sorted.sort((a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final domain = _getDomain();
    final subtopic = _getSubtopic(domain);

    if (subtopic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Subtopic not found')),
      );
    }

    final displayedTopics = _getSortedTopics(subtopic.topics);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(subtopic.name),
            actions: [
              PopupMenuButton<SortStrategy>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort Options',
                onSelected: (val) => setState(() => _sortStrategy = val),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: SortStrategy.custom, child: Text('Custom Order')),
                  PopupMenuItem(value: SortStrategy.name, child: Text('Alphabetical')),
                  PopupMenuItem(value: SortStrategy.dueDate, child: Text('Due Date')),
                  PopupMenuItem(value: SortStrategy.completion, child: Text('Completion %')),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Mark All Topics as Done',
                onPressed: () async {
                  await ref.read(domainListProvider.notifier).markAllTopicsDone(domain, subtopic);
                  ref.read(gamificationProvider.notifier).addXP(subtopic.topics.length * 5);
                  ref.read(gamificationProvider.notifier).updateStreak();
                  _confettiController.play();
                },
              )
            ],
          ),
          body: subtopic.topics.isEmpty
              ? const Center(child: Text('No topics yet.\nAdd one below!'))
              : _sortStrategy == SortStrategy.custom
                  ? ReorderableListView.builder(
                      itemCount: displayedTopics.length,
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final item = displayedTopics[oldIndex];
                        displayedTopics.removeAt(oldIndex);
                        displayedTopics.insert(newIndex, item);
                        // Update the real list
                        subtopic.topics = List.from(displayedTopics);
                        for (int i = 0; i < subtopic.topics.length; i++) {
                          subtopic.topics[i].orderIndex = i;
                        }
                        ref.read(domainListProvider.notifier).updateDomain(domain);
                      },
                      itemBuilder: (context, index) => _buildTopicTile(context, displayedTopics[index], domain, subtopic),
                    )
                  : ListView.builder(
                      itemCount: displayedTopics.length,
                      itemBuilder: (context, index) => _buildTopicTile(context, displayedTopics[index], domain, subtopic),
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTopicDialog(context, ref, domain, subtopic),
            child: const Icon(Icons.add),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicTile(BuildContext context, Topic topic, DomainModel domain, Subtopic subtopic) {
    bool isOverdue = false;
    if (topic.dueDate != null && !topic.isCompleted) {
      isOverdue = topic.dueDate!.isBefore(DateTime.now());
    }

    return Padding(
      key: ValueKey(topic.id),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: CheckboxListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                topic.name,
                style: TextStyle(
                  decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
                  color: topic.isCompleted ? Colors.grey : Colors.white,
                  fontWeight: topic.isPinned ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (topic.dueDate != null)
              Text(
                DateFormat('MMM d').format(topic.dueDate!),
                style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? Colors.redAccent : Colors.grey,
                  fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            if (isOverdue)
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(Icons.warning, color: Colors.redAccent, size: 16),
              )
          ],
        ),
        subtitle: topic.notes != null ? Text(topic.notes!) : null,
        value: topic.isCompleted,
        onChanged: (val) async {
          if (val != null) {
            final wasCompleted = subtopic.isCompleted;
            await ref.read(domainListProvider.notifier).updateTopicStatus(domain, subtopic, topic, val);
            if (val) {
              ref.read(gamificationProvider.notifier).addXP(10);
              ref.read(gamificationProvider.notifier).updateStreak();
              if (!wasCompleted && subtopic.isCompleted) {
                _confettiController.play();
              }
            }
          }
        },
        secondary: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                topic.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: topic.isPinned ? Colors.amber : Colors.grey,
              ),
              onPressed: () {
                topic.isPinned = !topic.isPinned;
                ref.read(domainListProvider.notifier).updateDomain(domain);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () {
                final removedIndex = subtopic.topics.indexOf(topic);
                subtopic.topics.remove(topic);
                ref.read(domainListProvider.notifier).updateDomain(domain);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${topic.name} deleted'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        subtopic.topics.insert(removedIndex, topic);
                        ref.read(domainListProvider.notifier).updateDomain(domain);
                      },
                    ),
                  )
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context, WidgetRef ref, DomainModel domain, Subtopic subtopic) {
    final controller = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDate;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Topic'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Topic Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(hintText: 'Notes (optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(selectedDate == null ? 'No due date' : DateFormat('MMM d, yyyy').format(selectedDate!)),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                        child: const Text('Select'),
                      )
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      final newTopic = Topic(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: controller.text.trim(),
                        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        dueDate: selectedDate,
                        createdAt: DateTime.now(),
                        orderIndex: subtopic.topics.length,
                        isPinned: false,
                      );
                      subtopic.topics.add(newTopic);
                      ref.read(domainListProvider.notifier).updateDomain(domain);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
